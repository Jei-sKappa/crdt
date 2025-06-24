import 'package:crdt_lf/crdt_lf.dart';
import 'package:hive_crdt_flutter_example/core/utils/dual_box.dart';
import 'package:hive_crdt_flutter_example/database/todo.dart';
import 'package:hive_crdt_flutter_example/shared/layout.dart';
import 'package:hive_crdt_flutter_example/shared/network.dart';
import 'package:hive_crdt_flutter_example/todo_list/_add_item_dialog.dart';
import 'package:hive_crdt_flutter_example/todo_list/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final author1 = PeerId.parse('79a716de-176e-4347-ba6e-1d9a2de02e15');
final author2 = PeerId.parse('79a716de-176e-4347-ba6e-1d9a2de02e16');

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final dualTodoBox = context.read<DualBox<Todo>>();
    final dualChangesBox = context.read<DualBox<String>>();

    return AppLayout(
      example: 'Todo List',
      leftBody: ChangeNotifierProvider<DocumentState>(
        create:
            (context) => DocumentState.create(
              author1,
              network: context.read<Network>(),
              todoBox: dualTodoBox.box1,
              changesBox: dualChangesBox.box1,
            ),
        child: TodoDocument(author: author1),
      ),
      rightBody: ChangeNotifierProvider<DocumentState>(
        create:
            (context) => DocumentState.create(
              author2,
              network: context.read<Network>(),
              todoBox: dualTodoBox.box2,
              changesBox: dualChangesBox.box2,
            ),
        child: TodoDocument(author: author2),
      ),
    );
  }
}

class TodoDocument extends StatelessWidget {
  const TodoDocument({super.key, required this.author});

  final PeerId author;

  Future<void> _showAddTodoDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return AddItemDialog(
          onAdd: (text) {
            context.read<DocumentState>().addTodo(text);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DocumentState>(
        builder: (context, state, child) {
          return FutureBuilder<List<Todo>>(
            future: state.getTodos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No todos yet. Add one using the button below!'),
                );
              }
              // Update the state with the fetched todos
              final todos = snapshot.data!;
              // Build the list if not empty
              return ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];

                  return _item(context, todo);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: _fab(context),
    );
  }

  Widget _item(BuildContext context, Todo todo) {
    return ListTile(
      title: Text(todo.title),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Delete Todo',
        onPressed: () {
          context.read<DocumentState>().removeTodo(todo.id);
        },
      ),
    );
  }

  Widget _fab(BuildContext context) {
    return FloatingActionButton(
      heroTag: author.toString(),
      onPressed: () => _showAddTodoDialog(context),
      tooltip: 'Add Todo',
      child: const Icon(Icons.add),
    );
  }
}
