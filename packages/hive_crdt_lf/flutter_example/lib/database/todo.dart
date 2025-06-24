import 'package:hive_crdt_lf/hive_crdt_lf.dart';

class Todo with CRDT<Todo> {
  Todo({required this.id, required this.title});

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(id: map['id'] as String, title: map['title'] as String);
  }

  final String id;
  final String title;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo &&
        runtimeType == other.runtimeType &&
        id == other.id &&
        title == other.title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  Todo clone() {
    return Todo(id: id, title: title);
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title)';
  }

  @override
  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title};
  }
}
