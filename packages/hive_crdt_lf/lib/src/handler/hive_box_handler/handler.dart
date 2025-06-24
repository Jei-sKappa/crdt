import 'dart:async';

import 'package:crdt_lf/crdt_lf.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_crdt_lf/hive_crdt_lf.dart';

part 'operation.dart';

typedef ExternalSourceOfTruth = Map<void, void>;

class CRDTHiveBoxHandler<TData extends CRDT<TData>>
    extends Handler<ExternalSourceOfTruth> {
  CRDTHiveBoxHandler(HiveCRDTDocument super.doc, this._id, this._box);

  final String _id;
  final Box<TData> _box;

  @override
  HiveCRDTDocument get doc => super.doc as HiveCRDTDocument;

  @override
  String get id => _id;

  void insert(String id, TData data) {
    doc.createChange(
      _HiveBoxInsertOperation<TData>.fromHandler(this, dataId: id, data: data),
    );
    invalidateCache();
  }

  void delete(String id) {
    doc.createChange(_HiveBoxDeleteOperation.fromHandler(this, dataId: id));
    invalidateCache();
  }

  Future<List<TData>> getAll(
    TData Function(Map<String, dynamic>) dataFromMap,
  ) async {
    if (cachedState == null) {
      await _updateDatabase(dataFromMap);
    }

    final datas = _box.values.toList();

    return List.from(datas);
  }

  Future<void> _updateDatabase(
    TData Function(Map<String, dynamic>) dataFromMap,
  ) async {
    final changes = doc.exportChanges().sorted();

    final opFactory = _HiveBoxOperationFactory<TData>(this);

    for (final change in changes) {
      final payload = change.payload;
      final operation = opFactory.fromPayload(payload, dataFromMap);

      if (operation is _HiveBoxInsertOperation<TData>) {
        await _box.put(operation.dataId, operation.data);
      } else if (operation is _HiveBoxDeleteOperation) {
        await _box.delete(operation.dataId);
      }
    }
  }

  @override
  ExternalSourceOfTruth getSnapshotState() => {};

  @override
  String toString() {
    return 'CRDTHiveBoxHandler($id)';
  }
}
