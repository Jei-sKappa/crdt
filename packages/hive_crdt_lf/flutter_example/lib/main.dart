import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_crdt_flutter_example/core/utils/dual_box.dart';
import 'package:hive_crdt_flutter_example/database/hive/hive_registrar.g.dart';
import 'package:hive_crdt_flutter_example/database/todo.dart';
import 'package:hive_crdt_flutter_example/shared/network.dart';
import 'package:hive_crdt_flutter_example/todo_list/todo_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Hive.registerAdapters();

  final author1TodoBox = await Hive.openBox<Todo>('author1_example');
  final author2TodoBox = await Hive.openBox<Todo>('author2_example');

  final author1TodoChangesBox = await Hive.openBox<String>(
    'author1_changes_example',
  );
  final author2TodoChangesBox = await Hive.openBox<String>(
    'author2_changes_example',
  );

  // await author1TodoBox.clear();
  // await author2TodoBox.clear();
  // await author1TodoChangesBox.clear();
  // await author2TodoChangesBox.clear();

  runApp(
    MyApp(
      author1TodoBox: author1TodoBox,
      author2TodoBox: author2TodoBox,
      author1TodoChangesBox: author1TodoChangesBox,
      author2TodoChangesBox: author2TodoChangesBox,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    required this.author1TodoBox,
    required this.author2TodoBox,
    required this.author1TodoChangesBox,
    required this.author2TodoChangesBox,
    super.key,
  });

  final Box<Todo> author1TodoBox;
  final Box<Todo> author2TodoBox;
  final Box<String> author1TodoChangesBox;
  final Box<String> author2TodoChangesBox;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Network()),
        Provider.value(
          value: DualBox<Todo>(
            box1: widget.author1TodoBox,
            box2: widget.author2TodoBox,
          ),
        ),
        Provider.value(
          value: DualBox<String>(
            box1: widget.author1TodoChangesBox,
            box2: widget.author2TodoChangesBox,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CRDT LF Example',
        theme: ThemeData(primarySwatch: Colors.blue),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        initialRoute: 'todo-list',
        routes: {
          '/': (context) => const Examples(),
          'todo-list': (context) => const TodoList(),
        },
      ),
    );
  }
}

class Examples extends StatelessWidget {
  const Examples({super.key});

  Widget _listTile(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      onTap: () => Navigator.of(context).pushNamed(route),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text('CRDT LF Examples'),
      ),
      body: ListView(children: [_listTile(context, 'Todo List', 'todo-list')]),
    );
  }
}
