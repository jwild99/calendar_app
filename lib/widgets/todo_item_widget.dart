import '../models/todo_model.dart';
import 'package:flutter/material.dart';
import '../const/constant.dart';

class TodoItem extends StatelessWidget {
  final ToDo todo;
  final onToDoChanged;
  final onDeleteItem;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Container(
      color: todo.isDone ? Color(0xFFE6F7E1) : Colors.white,
      child: ListTile(
        onTap: () => onToDoChanged(todo),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Icon(
          todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: selectionColor,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.todoText!,
              style: TextStyle(
                fontSize: 16,
                color: tdBlack,
                decoration: todo.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            if (todo.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'Due: ${todo.dueDate!.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
        trailing: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: tdRed,
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
            icon: Icon(Icons.delete, color: Colors.white, size: 18),
            onPressed: () => onDeleteItem(todo.id),
          ),
        ),
      ),
    ),
  ),
);
  }
}
