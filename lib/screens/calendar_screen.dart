import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../const/constant.dart';
import '../models/event_model.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
                _loadEvents();
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
                                                                final hasEvent = _events.any((e) =>
                                                                        e.date.year == date.year &&
                                                                        e.date.month == date.month &&
                                                                        e.date.day == date.day);
                                                                final eventCount = _events.where((e) =>
                                                                        e.date.year == date.year &&
                                                                        e.date.month == date.month &&
                                                                        e.date.day == date.day).length;

                                                                final eventLabel = '$eventCount ${eventCount == 1 ? 'event' : 'events'}';


                                                                return Padding(
                                                                        padding: const EdgeInsets.all(4.0),
                                                                        child: GestureDetector(
                                                                                onTap: () {
                                                                                        // When tapping on a day, show the dialog to add an event
                                                                                        _showAddEventDialog(date);
                                                                                },
                                                                                onLongPress: () {
                                                                                        // When long-pressing on a day, show events for that day
                                                                                        final dayEvents = _events
                                                                                        .where((e) =>
                                                                                        e.date.year == date.year &&
                                                                                        e.date.month == date.month &&
                                                                                        e.date.day == date.day)
                                                                                        .toList();

                                                                                        if (dayEvents.isNotEmpty) {
                                                                                                showDialog(
                                                                                                        context: context,
                                                                                                        builder: (_) => AlertDialog(
                                                                                                                title: Text("Events"),
                                                                                                                content: Column(
                                                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                                                        children: dayEvents
                                                                                                                        .map((e) => ListTile(
                                                                                                                                title: Text(e.title),
                                                                                                                                trailing: IconButton(
                                                                                                                                        icon: Icon(Icons.delete),
                                                                                                                                        onPressed: () {
                                                                                                                                                // Handle event deletion
                                                                                                                                                setState(() {
                                                                                                                                                        _events.removeWhere((ev) => ev.id == e.id);
                                                                                                                                                });
                                                                                                                                                _saveEvents();
                                                                                                                                                Navigator.of(context).pop();
                                                                                                                                        },
                                                                                                                                ),
                                                                                                                        ))
                                                                                                                        .toList(),
                                                                                                                ),
                                                                                                        ),
                                                                                                );
                                                                                        }
                                                                                },
                                                                                child: Container(
                                                                                        decoration: BoxDecoration(
                                                                                                color: isCurrentMonth ? cardBackgroundColor : Colors.transparent,
                                                                                                borderRadius: BorderRadius.circular(4),
                                                                                        ),
                                                                                        padding: const EdgeInsets.only(top: 2, left: 8),
                                                                                        child: Stack(
                                                                                                children: [
                                                                                                        Align(
                                                                                                                alignment: Alignment.topLeft,
                                                                                                                child: Text(
                                                                                                                        date.day.toString(),
                                                                                                                        style: GoogleFonts.teko(
                                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                                fontSize: 20,
                                                                                                                                color: isCurrentMonth ? Colors.white : Colors.grey,
                                                                                                                        ),
                                                                                                                ),
                                                                                                        ),
                                                                                                        // Show event count if there are any
                                                                                                        if (hasEvent)
                                                                                                                Positioned(
                                                                                                                        bottom: 0,
                                                                                                                        left: 95,
                                                                                                                        child: Container(
                                                                                                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                                                                                                decoration: BoxDecoration(
                                                                                                                                        color:  cardBackgroundColor,
                                                                                                                                        borderRadius: BorderRadius.circular(4),
                                                                                                                                ),

                                                                                                                                child: Text(
                                                                                                                                        eventLabel,
                                                                                                                                        style: TextStyle(
                                                                                                                                                fontSize: 20,
                                                                                                                                                color: Colors.white,
                                                                                                                                        ),
                                                                                                                                ),
                                                                                                                        ),
                                                                                                                ),
                                                                                                ],
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
                                children: [
                                  Text("Calendar"), // Or your custom title
                                ],
                        ),
                );
        }

        List<CalendarEvent> _events = [];

        Future<File> _getEventFile() async {
                final dir = await getApplicationDocumentsDirectory();
                final eventDir = Directory('${dir.path}/calendar_data');

                if (!await eventDir.exists()) {
                        await eventDir.create(recursive: true);
                }

                return File('${eventDir.path}/events.json');
        }

        Future<void> _saveEvents() async {
                final file = await _getEventFile();
                final jsonList = jsonEncode(_events.map((e) => e.toJson()).toList());
                await file.writeAsString(jsonList);
        }

        Future<void> _loadEvents() async {
                try {
                        final file = await _getEventFile();
                        if (await file.exists()) {
                                final jsonData = await file.readAsString();
                                final List<dynamic> decoded = jsonDecode(jsonData);
                                setState(() {
                                        _events = decoded.map((e) => CalendarEvent.fromJson(e)).toList();
                                });
                        }
                } catch (e) {
                        print("Error loading events: $e");
                }
        }

        void _showAddEventDialog(DateTime selectedDate) {
                final controller = TextEditingController();
                final dayEvents = _events.where((e) =>
                        e.date.year == selectedDate.year &&
                        e.date.month == selectedDate.month &&
                        e.date.day == selectedDate.day).toList();

                showDialog(
                        context: context,
                        builder: (context) {
                                return AlertDialog(
                                        title: Text("Events for ${selectedDate.month}/${selectedDate.day}"),
                                        backgroundColor: cardBackgroundColor,
                                        content: SingleChildScrollView(
                                        child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                        // Existing events
                                                        if (dayEvents.isNotEmpty) ...dayEvents.map((e) => ListTile(
                                                                title: Text(
                                                                        e.title,
                                                                        style: TextStyle(color: Colors.white),
                                                                ),
                                                                trailing: IconButton(
                                                                        icon: Icon(Icons.delete, color: Colors.red),
                                                                        onPressed: () {
                                                                                        setState(() {
                                                                                                _events.removeWhere((ev) => ev.id == e.id);
                                                                                        });
                                                                                _saveEvents();
                                                                                Navigator.of(context).pop(); // Close and reopen to update list
                                                                                _showAddEventDialog(selectedDate);
                                                                        },
                                                                ),
                                                        )) else
                                                        Padding(
                                                                padding: const EdgeInsets.only(bottom: 8.0),
                                                                child: Text(
                                                                        "No events yet.",
                                                                        style: TextStyle(color: Colors.grey),
                                                                ),
                                                        ),

                                                        // Input for new event
                                                        TextField(
                                                                controller: controller,
                                                                cursorColor: Colors.white,
                                                                style: TextStyle(color: Colors.white),
                                                                decoration: InputDecoration(
                                                                        hintText: 'New Event Title',
                                                                        hintStyle: TextStyle(color: Colors.grey),
                                                                        focusedBorder: UnderlineInputBorder(
                                                                                borderSide: BorderSide(color: Colors.white),
                                                                        ),
                                                                        enabledBorder: UnderlineInputBorder(
                                                                                borderSide: BorderSide(color: Colors.grey),
                                                                        ),
                                                                ),
                                                        ),
                                                ],
                                        ),
                                ),
                                actions: [
                                        ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                        foregroundColor: Colors.white,
                                                        backgroundColor: backgroundColor,
                                                ),
                                                onPressed: () {
                                                        Navigator.of(context).pop();
                                                },
                                                child: Text("Close"),
                                        ),
                                        ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                        foregroundColor: Colors.white,
                                                        backgroundColor: backgroundColor,
                                                ),
                                                onPressed: () {
                                                        final event = CalendarEvent(
                                                                id: DateTime.now().microsecondsSinceEpoch.toString(),
                                                                title: controller.text,
                                                                date: selectedDate,
                                                        );

                                                        setState(() {
                                                                _events.add(event);
                                                        });

                                                        _saveEvents();
                                                        Navigator.of(context).pop();
                                                        _showAddEventDialog(selectedDate); // Refresh to show new event
                                                },
                                                child: Text("Add"),
                                        ),
                                ],
                                );
                        },
                        );
        }
}
