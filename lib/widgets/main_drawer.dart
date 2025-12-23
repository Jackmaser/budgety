import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  final VoidCallback onShowCategories;
  final VoidCallback onShowSettings; // Neuer Callback

  const MainDrawer({
    super.key,
    required this.onShowCategories,
    required this.onShowSettings, // Im Konstruktor hinzufügen
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).colorScheme.primary,
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
          // NEUER MENÜPUNKT
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
