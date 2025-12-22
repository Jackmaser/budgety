import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  final List<Category> categories;
  final Function(Category) onAddCategory;
  final Function(String) onDeleteCategory; // Dieser Parameter hat gefehlt

  const CategoryScreen({
    super.key,
    required this.categories,
    required this.onAddCategory,
    required this.onDeleteCategory, // Im Konstruktor registrieren
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.teal;
  IconData _selectedIcon = Icons.star;

  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.movie,
    Icons.work,
    Icons.medical_services,
    Icons.shopping_cart,
    Icons.home,
    Icons.build,
    Icons.flight,
    Icons.payments,
    Icons.pets,
    Icons.school,
  ];

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Neue Kategorie'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Name der Kategorie'),
                ),
                const SizedBox(height: 20),
                const Text('Farbe wählen:'),
                BlockPicker(
                  pickerColor: _selectedColor,
                  onColorChanged: (color) {
                    setDialogState(() => _selectedColor = color);
                  },
                ),
                const SizedBox(height: 20),
                const Text('Icon wählen:'),
                Wrap(
                  spacing: 10,
                  children: _availableIcons
                      .map((icon) => IconButton(
                            icon: Icon(icon,
                                color: _selectedIcon == icon
                                    ? _selectedColor
                                    : Colors.grey),
                            onPressed: () =>
                                setDialogState(() => _selectedIcon = icon),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Abbrechen')),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isEmpty) return;
                widget.onAddCategory(Category(
                  id: DateTime.now().toString(),
                  name: _nameController.text,
                  icon: _selectedIcon,
                  color: _selectedColor,
                ));
                _nameController.clear();
                Navigator.of(ctx).pop();
                setState(() {}); // UI der Liste aktualisieren
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorien verwalten'),
      ),
      body: widget.categories.isEmpty
          ? const Center(child: Text('Keine Kategorien vorhanden.'))
          : ListView.builder(
              itemCount: widget.categories.length,
              itemBuilder: (ctx, i) {
                final cat = widget.categories[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cat.color,
                      child: Icon(cat.icon, color: Colors.white),
                    ),
                    title: Text(cat.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        widget.onDeleteCategory(cat.id);
                        setState(() {}); // UI nach Löschen aktualisieren
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
