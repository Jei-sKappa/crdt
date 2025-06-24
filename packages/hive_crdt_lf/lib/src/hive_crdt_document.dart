import 'dart:convert';

import 'package:crdt_lf/crdt_lf.dart';
import 'package:hive_ce/hive.dart';

class HiveCRDTDocument extends CRDTDocument {
  HiveCRDTDocument({
    required Box<String> changesBox,
    super.peerId,
  }) : _changesBox = changesBox {
    print('Initializing HiveCRDTDocument for peer $peerId');

    final changes = _changesBox.values
        .map((e) => Change.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList(growable: false);
    print(
      '  - Importing ${changes.length} changes for peer $peerId',
    );

    final applied = importChanges(changes);
    print(
      '  - Applied $applied changes for peer $peerId from storage',
    );
  }

  final Box<String> _changesBox;

  @override
  bool applyChange(Change change) {
    // TODO: This should be awaited
    _changesBox.put(change.id.toString(), jsonEncode(change.toJson()));
    return super.applyChange(change);
  }
}
