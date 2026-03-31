import 'package:flutter/material.dart';

class KalkulatorItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget page;
  final bool isIconData;
  final bool isFree;

  KalkulatorItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.page,
    this.isIconData = false,
    this.isFree = false,
  });
}
