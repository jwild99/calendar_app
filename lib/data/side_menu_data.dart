// side_menu_data.dart
import 'package:calendar_app/screens/todo_screen.dart';
import 'package:calendar_app/screens/calendar_screen.dart';
import 'package:calendar_app/screens/timer_screen.dart';
import 'package:calendar_app/screens/main_screen.dart';
import 'package:flutter/material.dart';

class MenuItemData {
  final String title;
  final IconData icon;
  final Widget screen; // ADD THIS

  MenuItemData({required this.title, required this.icon, required this.screen});
}

class SideMenuData {
  final List<MenuItemData> menu = [
    MenuItemData(title: 'Home', icon: Icons.home, screen: MainScreen()),
    MenuItemData(title: 'To-Do', icon: Icons.checklist, screen: TodoScreen()),
    MenuItemData(title: 'Calendar', icon: Icons.calendar_today, screen: CalendarScreen()),
    MenuItemData(title: 'Pomodoro', icon: Icons.timer, screen: TimerScreen())
  ];
}
