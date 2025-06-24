import 'package:hive_ce/hive.dart';
import 'package:hive_crdt_flutter_example/database/todo.dart';

@GenerateAdapters([AdapterSpec<Todo>()])
part 'hive_adapters.g.dart';
