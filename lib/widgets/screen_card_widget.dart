import 'package:calendar_app/widgets/custom_card_widget.dart';
import 'package:calendar_app/const/constant.dart';
import 'package:calendar_app/screens/todo_screen.dart';
import 'package:calendar_app/models/todo_model.dart';
import 'package:calendar_app/screens/calendar_screen.dart';
import 'package:calendar_app/screens/timer_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ScreenCard extends StatefulWidget {
  const ScreenCard({super.key});

  @override
  State<ScreenCard> createState() => _ScreenCardState();
}

class _ScreenCardState extends State<ScreenCard> {
  List<ToDo> upcomingTodos = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadTodos() async {
    final file = await _getFile();
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);

      final List<ToDo> todos = jsonData.map((item) => ToDo.fromJson(item)).toList();

      final List<ToDo> sortedTodos = todos
          .where((todo) => todo.dueDate != null)
          .toList()
        ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

      setState(() {
        upcomingTodos = sortedTodos.take(10).toList();
      });
    }
  }


  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final userDataPath = Directory('${directory.path}/user_data');

    if (!await userDataPath.exists()) {
      await userDataPath.create(recursive: true);
    }

    return File('${userDataPath.path}/todo_list.json');
  }

  loadTodosFromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      todoText: json['todoText'],
      isDone: json['isDone'],
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate']) // Parse the string back into DateTime
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    loadTodos();
    final List<String> titles = [todoTitle, calendarTitle, timerTitle];

    // List of corresponding screens
    final List<Widget> screens = [
      TodoScreen(),
      const CalendarScreen(),
      TimerScreen(),
    ];

    return GridView.builder(
      itemCount: 3,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 12.0,
        childAspectRatio: 5 / 4,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screens[index]),
            );
          },
          child: CustomCard(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[index], // Display the corresponding title
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (index == 0) ...[
                  // Display upcoming to-do items if the screen is for to-dos
                  _buildUpcomingTodos(upcomingTodos),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingTodos(List<ToDo> upcomingTodos) {
    if (upcomingTodos.isEmpty) {
      return const Text("No upcoming tasks");
    }

    return Column(
      children: upcomingTodos.map((todo) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: Text(todo.todoText ?? ''),
          subtitle: Text('Due: ${_formatDate(todo.dueDate)}'),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

}
