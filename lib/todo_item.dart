import 'package:hive/hive.dart';

part 'todo_item.g.dart';

@HiveType(typeId: 1)
class TodoItem {
  @HiveField(0)
  final String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  DateTime? dueDate; 

  TodoItem(this.title, {this.isCompleted = false, this.dueDate});
}
