import 'dart:async';

import 'package:crdt_lf/crdt_lf.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_crdt_flutter_example/core/utils/uuid.dart';
import 'package:hive_crdt_flutter_example/database/todo.dart';
import 'package:hive_crdt_flutter_example/shared/network.dart';
import 'package:flutter/material.dart';
import 'package:hive_crdt_lf/hive_crdt_lf.dart';

class DocumentState extends ChangeNotifier {
  DocumentState._(this._document, this._handler, this._network) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final changes = _document.exportChanges();
      for (final change in changes) {
        _sendChange(change);
      }
    });

    // After initializing, listen to network and local changes
    _listenToNetworkChanges();
    _listenToLocalChanges();
  }

  factory DocumentState.create(
    PeerId author, {
    required Network network,
    required Box<Todo> todoBox,
    required Box<String> changesBox,
  }) {
    final document = HiveCRDTDocument(peerId: author, changesBox: changesBox);
    final handler = CRDTHiveBoxHandler(document, 'todo_list', todoBox);
    return DocumentState._(document, handler, network);
  }

  final HiveCRDTDocument _document;
  final CRDTHiveBoxHandler<Todo> _handler;
  final Network _network;

  StreamSubscription<Change>? _networkChanges;
  StreamSubscription<Change>? _localChanges;

  void _listenToNetworkChanges() {
    _networkChanges = _network
        .stream(_document.peerId)
        .listen(_applyNetworkChanges);
  }

  void _listenToLocalChanges() {
    _localChanges = _document.localChanges.listen(_sendChange);
  }

  void _applyNetworkChanges(Change change) {
    _document.applyChange(change);
    notifyListeners();
  }

  void _sendChange(Change change) {
    _network.sendChange(change);
  }

  void addTodo(String title) {
    final id = uuid.v7();
    final todo = Todo(id: id, title: title);
    // NOTE: In a real application you **probabily** don't need to clone the
    // item, but here we do it to avoide Hive errors because we store the todo
    // multiple times in two different boxes.
    _handler.insert(id, todo.clone());
    notifyListeners();
  }

  void removeTodo(String todoId) {
    _handler.delete(todoId);
    notifyListeners();
  }

  Future<List<Todo>> getTodos() async => await _handler.getAll(Todo.fromMap);

  @override
  void dispose() {
    _networkChanges?.cancel();
    _localChanges?.cancel();
    super.dispose();
  }
}
