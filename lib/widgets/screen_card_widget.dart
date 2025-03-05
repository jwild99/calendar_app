import 'package:calendar_app/widgets/custom_card_widget.dart';
import 'package:calendar_app/const/constant.dart';
import 'package:calendar_app/screens/todo_screen.dart';
import 'package:calendar_app/screens/calendar_screen.dart';
import 'package:calendar_app/screens/timer_screen.dart';
import 'package:flutter/material.dart';

class ScreenCard extends StatelessWidget {
  const ScreenCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> titles = [todoTitle, calendarTitle, timerTitle];

    // List of corresponding screens
    final List<Widget> screens = [
      TodoScreen(),
      const CalendarScreen(),
      const TimerScreen(),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
