import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Für themeNotifier

enum CategorySortOption { alphabetical, custom, lastModified }

class SettingsScreen extends StatefulWidget {
  final VoidCallback onDataReset;
  final CategorySortOption currentSort;
  final Function(CategorySortOption) onSortChanged;

  const SettingsScreen({
    super.key,
    required this.onDataReset,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Lokaler State für die Auswahl, damit der Punkt sofort springt
  late CategorySortOption _tempSelectedSort;

  @override
  void initState() {
    super.initState();
    // Initialisierung mit dem Wert vom HomeScreen
    _tempSelectedSort = widget.currentSort;
  }

  void _toggleTheme(bool isDark) async {
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {}); // UI aktualisieren für den Switch
  }

  void _handleSortChange(CategorySortOption? newValue) {
    if (newValue == null) return;

    setState(() {
      _tempSelectedSort = newValue;
    });

    // Den HomeScreen im Hintergrund informieren
    widget.onSortChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Design',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: themeNotifier.value == ThemeMode.dark,
            onChanged: _toggleTheme,
          ),
          const Divider(),
          const ListTile(
            title: Text('Kategorien Sortierung',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          ),
          RadioListTile<CategorySortOption>(
            title: const Text('Alphabetisch'),
            value: CategorySortOption.alphabetical,
            groupValue: _tempSelectedSort, // Nutzt den lokalen State
            onChanged: _handleSortChange,
          ),
          RadioListTile<CategorySortOption>(
            title: const Text('Erstellungsdatum'),
            value: CategorySortOption.custom,
            groupValue: _tempSelectedSort, // Nutzt den lokalen State
            onChanged: _handleSortChange,
          ),
          RadioListTile<CategorySortOption>(
            title: const Text('Zuletzt geändert'),
            value: CategorySortOption.lastModified,
            groupValue: _tempSelectedSort, // Nutzt den lokalen State
            onChanged: _handleSortChange,
          ),
          const Divider(),
          const ListTile(
            title: Text('Datenverwaltung',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('App zurücksetzen',
                style: TextStyle(color: Colors.red)),
            subtitle: const Text('Löscht alle Kategorien und Buchungen'),
            onTap: widget.onDataReset,
          ),
          const Divider(),
          const ListTile(
            title: Text('Info',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
