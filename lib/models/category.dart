import 'package:flutter/material.dart';

class Category {
  final String id;
  String name;
  IconData icon;
  Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
