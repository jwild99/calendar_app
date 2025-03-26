import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../const/constant.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => CalendarScreenState();
}

// State Class
class CalendarScreenState extends State<CalendarScreen> {
  late DateTime currentMonth;
  late List<DateTime> datesGrid;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    datesGrid = _generateDatesGrid(currentMonth);
  }

  // _generateDatesGrid Function
  List<DateTime> _generateDatesGrid(DateTime month) {
    int numDays =
        DateTime(month.year, month.month + 1, 0).day; // days in current month
    int firstWeekday = DateTime(month.year, month.month, 1).weekday %
        7; //day of week in which first month falls on
    List<DateTime> dates = []; // holds all dates in the month in list

    //fill previous month
    DateTime previousMonth =
        DateTime(month.year, month.month - 1, 0); // current month -1
    int previousMonthLastDay =
        DateTime(previousMonth.year, previousMonth.month + 1, 0)
            .day; // last day of previous month
    for (int i = firstWeekday - 1; i > 0; i--) {
      dates.add(DateTime(previousMonth.year, previousMonth.month,
          previousMonthLastDay - i + 1));
    }

    //fill current month
    for (int day = 1; day <= numDays; day++) {
      dates.add(DateTime(month.year, month.month, day));
    }

    //fill next month
    int remainingBoxes =
        42 - dates.length; // 42 is the number of days in a 6 week month
    for (int day = 1; day <= remainingBoxes; day++) {
      dates.add(DateTime(month.year, month.month + 1, day));
    }

    return dates;
  }

  //_changeMonth Function - Takes in offeset from current month
  void _changeMonth(int offset) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + offset);
      datesGrid = _generateDatesGrid(currentMonth);
    });
  }

  //
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                '${_monthName(currentMonth.month)} ${currentMonth.year}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const Gap(12),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                  7,
                  (index) => Text(
                        ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][index],
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.white),
                      )),
            ),
          ),
          const Gap(12),
          Flexible(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7),
              itemCount: datesGrid.length,
              itemBuilder: (context, index) {
                DateTime date = datesGrid[index];
                bool isCurrentMonth = date.month == currentMonth.month;
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CircleAvatar(
                    backgroundColor:
                        isCurrentMonth ? cardBackgroundColor : Colors.transparent,
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: isCurrentMonth ? Colors.white : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int monthNumber) {
    return [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ][monthNumber - 1];
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }
}
