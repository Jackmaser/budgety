import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  final VoidCallback onShowCategories;
  final VoidCallback onShowSettings;

  const MainDrawer({
    super.key,
    required this.onShowCategories,
    required this.onShowSettings,
  });

  @override
  Widget build(BuildContext context) {
    // Erkennt, ob der Dark Mode aktiv ist
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          // HEADER: Farbe jetzt synchron zum Home-Screen
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: isDarkMode
                ? const Color(0xFF003333) // Dunkles Teal für Dark Mode
                : Theme.of(context)
                    .colorScheme
                    .primary, // Normales Teal für Light Mode
            alignment: Alignment.centerLeft,
            child: const Text('Budgety',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                    color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Übersicht'),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Kategorien verwalten'),
            onTap: () {
              Navigator.of(context).pop();
              onShowCategories();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Einstellungen'),
            onTap: () {
              Navigator.of(context).pop();
              onShowSettings();
            },
          ),
        ],
      ),
    );
  }
}
