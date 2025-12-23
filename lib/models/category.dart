import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final DateTime lastModified; // Neu für die Sortierung

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.lastModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['iconCode'], fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue']),
      lastModified: DateTime.parse(
          map['lastModified'] ?? DateTime.now().toIso8601String()),
    );
  }
}
