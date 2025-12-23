import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onDataReset;

  const SettingsScreen({super.key, required this.onDataReset});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false; // Platzhalter für spätere Theme-Logik

  // Funktion zum Löschen aller gespeicherten Daten
  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daten zurücksetzen?'),
        content: const Text(
            'Möchtest du wirklich alle Buchungen und Kategorien löschen? Dies kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Abbrechen')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Ja, alles löschen',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Löscht alles aus SharedPreferences
      widget.onDataReset(); // Benachrichtigt den HomeScreen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alle Daten wurden gelöscht.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Erscheinungsbild',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          ),
          SwitchListTile(
            title: const Text('Dunkles Design'),
            subtitle: const Text('Wechsle zwischen hellem und dunklem Modus'),
            value: _isDarkMode,
            onChanged: (val) {
              setState(() => _isDarkMode = val);
              // Hinweis: Für echten Dark Mode müssten wir einen ThemeProvider nutzen.
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Datenverwaltung',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('App zurücksetzen',
                style: TextStyle(color: Colors.red)),
            subtitle: const Text('Löscht alle Kategorien und Buchungen'),
            onTap: _confirmReset,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Über Budgety',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Entwickelt mit Flutter'),
          ),
        ],
      ),
    );
  }
}
