import 'package:calendar_app/widgets/custom_card_widget.dart';
import 'package:calendar_app/const/constant.dart';
import 'package:calendar_app/screens/todo_screen.dart';
import 'package:calendar_app/models/todo_model.dart';
import 'package:calendar_app/screens/calendar_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:calendar_app/models/event_model.dart';

class ScreenCard extends StatefulWidget {
  const ScreenCard({super.key});

  @override
  State<ScreenCard> createState() => _ScreenCardState();
}

class _ScreenCardState extends State<ScreenCard> {
  List<ToDo> upcomingTodos = [];
  List<CalendarEvent> upcomingEvents = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadTodos() async {
    final file = await _getTodoFile();
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);

      final List<ToDo> todos = jsonData.map((item) => ToDo.fromJson(item)).toList();

      final List<ToDo> sortedTodos = todos
          .where((todo) => todo.dueDate != null)
          .toList()
        ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

      setState(() {
        upcomingTodos = sortedTodos.take(7).toList();
      });
    }
  }

  Future<void> loadEvents() async {
    final file = await _getEventFile();
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);

      final List<CalendarEvent> events = jsonData.map((item) => CalendarEvent.fromJson(item)).toList();

      final List<CalendarEvent> sortedEvents = events
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      setState(() {
        upcomingEvents = sortedEvents.take(7).toList();
      });
    }
  }


  Future<File> _getTodoFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final userDataPath = Directory('${directory.path}/user_data');

    if (!await userDataPath.exists()) {
      await userDataPath.create(recursive: true);
    }

    return File('${userDataPath.path}/todo_list.json');
  }

  Future<File> _getEventFile() async {
                final dir = await getApplicationDocumentsDirectory();
                final eventDir = Directory('${dir.path}/calendar_data');

                if (!await eventDir.exists()) {
                        await eventDir.create(recursive: true);
                }

                return File('${eventDir.path}/events.json');
    }



  @override
  Widget build(BuildContext context) {
    loadTodos();
    loadEvents();

    final List<String> titles = [todoTitle, calendarTitle];

    // List of corresponding screens
    final List<Widget> screens = [
      TodoScreen(),
      const CalendarScreen(),
    ];

    return GridView.builder(
      itemCount: 2,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 12.0,
        childAspectRatio: 5 / 6,
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
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (index == 0) ...[
                  // Display upcoming to-do items if the screen is for to-dos
                  _buildUpcomingTodos(upcomingTodos),
                ],
                if (index == 1) ...[
                  // Display upcoming events if the screen is for events
                  _buildUpcomingEvents(upcomingEvents),
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

  Widget _buildUpcomingEvents(List<CalendarEvent> upcomingEvents) {
    if (upcomingEvents.isEmpty) {
      return const Text("No upcoming events");
    }

    return Column(
      children: upcomingEvents.map((event) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: Text(event.title),
          subtitle: Text('Start: ${_formatDate(event.date)}'),
        );
      }).toList(),
    );
  }

}
