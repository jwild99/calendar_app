import 'package:calendar_app/models/menu_model.dart';
import 'package:flutter/material.dart';

class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icons.home, title: 'Home'),
    MenuModel(icon: Icons.checklist, title: 'To-Do'),
    MenuModel(icon: Icons.calendar_today, title: 'Calendar'),
    MenuModel(icon: Icons.timer, title: 'Pomodoro'),
    MenuModel(icon: Icons.logout, title: 'Add More'),
  ];
}
