import 'package:hive_ce/hive.dart';

class DualBox<T> {
  const DualBox({required this.box1, required this.box2});

  final Box<T> box1;
  final Box<T> box2;
}
