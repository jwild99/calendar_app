import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
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
                int firstWeekday = DateTime(month.year, month.month, 1).weekday % 7; //day of week in which first month falls on
                List<DateTime> dates = []; // holds all dates in the month in list

                //fill previous month
                DateTime previousMonth =
                DateTime(month.year, month.month - 1, 0); // current month -1
                int previousMonthLastDay =
                DateTime(previousMonth.year, previousMonth.month + 1, 0).day; // last day of previous month

                for (int i = firstWeekday - 1; i > 0; i--) {
                        dates.add(DateTime(previousMonth.year, previousMonth.month, previousMonthLastDay - i + 1));
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

        @override
        Widget build(BuildContext context) {
                final screenHeight = MediaQuery.of(context).size.height;
                final screenWidth = MediaQuery.of(context).size.width;
                final topPadding = MediaQuery.of(context).padding.top;

                final appBarHeight = kToolbarHeight;
                final monthSelectorHeight = 30 + 12 + 35 + 12; // rough estimate based on SizedBox and text
                final weekDaysHeight = 22 + 16; // text + padding
                final totalUsedHeight = topPadding + appBarHeight + monthSelectorHeight + weekDaysHeight;

                final remainingHeight = screenHeight - totalUsedHeight;
                final rowHeight = remainingHeight / 6; // 6 calendar rows
                final cellWidth = screenWidth / 7;
                final aspectRatio = cellWidth / rowHeight;

                return Scaffold(
                        appBar: _buildAppBar(),
                        backgroundColor: backgroundColor,
                        body: Column(
                                children: [
                                        const SizedBox(height: 30),
                                        Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                        IconButton(
                                                                icon: const Icon(Icons.arrow_back_ios),
                                                                onPressed: () => _changeMonth(-1),
                                                        ),
                                                        Text(
                                                                '${_monthName(currentMonth.month)} ${currentMonth.year}',
                                                                style: GoogleFonts.teko(fontSize: 35, fontWeight: FontWeight.w500),
                                                        ),
                                                        IconButton(
                                                                icon: const Icon(Icons.arrow_forward_ios),
                                                                onPressed: () => _changeMonth(1),
                                                        ),
                                                ],
                                        ),
                                        const Gap(12),
                                        Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                        child: Row(
                                                                children: List.generate(7, (index) {
                                                                        return Expanded(
                                                                                child: Center(
                                                                                        child: Text(
                                                                                                ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][index],
                                                                                                style: GoogleFonts.teko(
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontSize: 22,
                                                                                                        color: Colors.white,
                                                                                                ),
                                                                                        ),
                                                                                ),
                                                                        );
                                                                }),
                                                        ),
                                                ),
                                                const Gap(12),
                                                Expanded(
                                                        child: GridView.builder(
                                                                physics: const NeverScrollableScrollPhysics(),
                                                                padding: const EdgeInsets.all(4.0),
                                                                itemCount: datesGrid.length,
                                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                        crossAxisCount: 7,
                                                                        childAspectRatio: aspectRatio,
                                                                ),
                                                                itemBuilder: (context, index) {
                                                                        final date = datesGrid[index];
                                                                        final isCurrentMonth = date.month == currentMonth.month;

                                                                        return Padding(
                                                                                padding: const EdgeInsets.all(4.0),
                                                                                child: Container(
                                                                                        decoration: BoxDecoration(
                                                                                                color: isCurrentMonth ? cardBackgroundColor : Colors.transparent,
                                                                                                borderRadius: BorderRadius.circular(4),
                                                                                        ),
                                                                                        alignment: Alignment.center,
                                                                                        child: Text(
                                                                                                date.day.toString(),
                                                                                                style: GoogleFonts.teko(
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontSize: 22,
                                                                                                        color: isCurrentMonth ? Colors.white : Colors.grey,
                                                                                                ),
                                                                                        ),
                                                                                ),
                                                                        );
                                                                },
                                                        ),
                                                )
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
                        backgroundColor: backgroundColor,
                        elevation: 0,
                        title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                );
        }
}
