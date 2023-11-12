// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'todo_item.dart';
import 'todo_service.dart';
import 'package:intl/intl.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter((await getApplicationDocumentsDirectory()).path);
  Hive.registerAdapter(TodoItemAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final TodoService _todoService = TodoService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sucalit - ToDo App',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _todoService.getAllTodos(),
        builder: (context, AsyncSnapshot<List<TodoItem>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return TodoListPage(snapshot.data ?? []);
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class TodoListPage extends StatefulWidget {
  final List<TodoItem> todos;

  const TodoListPage(this.todos, {super.key});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TodoService _todoService = TodoService();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hive To-Do List"),
        backgroundColor: Colors.amber[600],
      ),


      body: ValueListenableBuilder(
        valueListenable: Hive.box<TodoItem>('todoBox').listenable(),
        builder: (context, Box<TodoItem> box, _) {
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              var todo = box.getAt(index);
              return TodoListItem(
                todo: todo!,
                onDelete: () => _todoService.deleteTodo(index),
                onCheckboxChanged: (bool? val) => _todoService.updateIsCompleted(index, todo),
              );
            },
          );
        },
      ),


      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 36, 58, 37),
        onPressed: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2101),
          );

          if (pickedDate != null) {
            showDialog(
              context: context,
              builder: (context) {
                return Center( 
                  child: SizedBox(
                    width: 300, 
                    child: AlertDialog(
                      title: const Text('Add Task'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min, 
                        children: [
                          TextField(
                            controller: _controller,
                            decoration: const InputDecoration(labelText: 'Task Title'),
                          ),
                          const SizedBox(height: 10),
                          Text('Due Date: ${DateFormat('MM/dd/yyyy').format(pickedDate)}'),
                        ],
                      ),

                      actions: [
                        ElevatedButton(
                          child: const Text('Add'),
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              var todo = TodoItem(_controller.text, dueDate: pickedDate);
                              _todoService.addTodo(todo);
                              _controller.clear();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                   
                    ),
                  ),
                );
              },
            );
          }
        },
 
        child: const Icon(Icons.add),
      ),

    );
  }
}

class TodoListItem extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onDelete;
  final void Function(bool?) onCheckboxChanged; 

  const TodoListItem({
    Key? key,
    required this.todo,
    required this.onDelete,
    required this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            if (todo.dueDate != null)
              Text(
                'Due Date: ${DateFormat('MM/dd/yyyy').format(todo.dueDate!)}',
                style: TextStyle(
                  color: todo.isCompleted ? Colors.grey : const Color.fromARGB(255, 194, 88, 81),
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: onCheckboxChanged, // No need for () => onCheckboxChanged()
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
