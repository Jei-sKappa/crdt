part of 'handler.dart';

class _HiveBoxOperationFactory<T extends CRDT> {
  _HiveBoxOperationFactory(this.handler);
  final Handler<dynamic> handler;

  Operation? fromPayload(
    Map<String, dynamic> payload,
    T Function(Map<String, dynamic>) dataFromMap,
  ) {
    if (payload['id'] != handler.id) {
      return null;
    }

    if (payload['type'] == OperationType.insert(handler).toPayload()) {
      return _HiveBoxInsertOperation<T>.fromPayload(payload, dataFromMap);
    } else if (payload['type'] == OperationType.delete(handler).toPayload()) {
      return _HiveBoxDeleteOperation.fromPayload(payload);
    }

    return null;
  }
}

class _HiveBoxInsertOperation<T extends CRDT> extends Operation {
  const _HiveBoxInsertOperation({
    required super.type,
    required super.id,
    required this.dataId,
    required this.data,
  });

  factory _HiveBoxInsertOperation.fromPayload(
    Map<String, dynamic> payload,
    T Function(Map<String, dynamic>) dataFromMap,
  ) => _HiveBoxInsertOperation<T>(
    type: OperationType.fromPayload(payload['type'] as String),
    id: payload['id'] as String,
    dataId: payload['data_id'] as String,
    data: dataFromMap(payload['data'] as Map<String, dynamic>),
  );

  factory _HiveBoxInsertOperation.fromHandler(
    Handler<dynamic> handler, {
    required String dataId,
    required T data,
  }) {
    return _HiveBoxInsertOperation(
      type: OperationType.insert(handler),
      id: handler.id,
      dataId: dataId,
      data: data,
    );
  }

  final String dataId;
  final T data;

  @override
  Map<String, dynamic> toPayload() => {
    'type': type.toPayload(),
    'id': id,
    'data_id': dataId,
    'data': data.toMap(),
  };
}

class _HiveBoxDeleteOperation extends Operation {
  const _HiveBoxDeleteOperation({
    required super.type,
    required super.id,
    required this.dataId,
  });

  factory _HiveBoxDeleteOperation.fromPayload(Map<String, dynamic> payload) =>
      _HiveBoxDeleteOperation(
        type: OperationType.fromPayload(payload['type'] as String),
        id: payload['id'] as String,
        dataId: payload['data_id'] as String,
      );

  factory _HiveBoxDeleteOperation.fromHandler(
    Handler<dynamic> handler, {
    required String dataId,
  }) {
    return _HiveBoxDeleteOperation(
      id: handler.id,
      type: OperationType.delete(handler),
      dataId: dataId,
    );
  }

  final String dataId;

  @override
  Map<String, dynamic> toPayload() => {
    'type': type.toPayload(),
    'id': id,
    'data_id': dataId,
  };
}
