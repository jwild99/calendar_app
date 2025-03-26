import 'package:calendar_app/models/widget_model.dart';
import 'package:flutter/material.dart';

class ScreenWidgetModel {
  final String label;
  final Color color;
  final List<WidgetModel> graph;

  const ScreenWidgetModel(
      {required this.label, required this.color, required this.graph});
}
