import 'package:calendar_app/models/menu_model.dart';
import 'package:flutter/material.dart';

class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icons.home, title: 'Dashboard'),
    MenuModel(icon: Icons.person, title: 'Profile'),
    MenuModel(icon: Icons.settings, title: 'Settings'),
    MenuModel(icon: Icons.logout, title: 'SignOut'),
  ];
}
