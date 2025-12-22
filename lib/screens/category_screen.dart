import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  final List<Category> categories;
  final Function(Category) onAddCategory;
  final Function(String) onDeleteCategory;

  const CategoryScreen({
    super.key,
    required this.categories,
    required this.onAddCategory,
    required this.onDeleteCategory,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _nameController = TextEditingController();

  // Standardwerte für neue Kategorien
  Color _selectedColor = Colors.teal;
  IconData _selectedIcon = Icons.star;

  // Kompakte Farbauswahl
  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
  ];

  // Kompakte Iconauswahl
  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.movie,
    Icons.work,
    Icons.medical_services,
    Icons.shopping_cart,
    Icons.home,
    Icons.flight,
    Icons.payments,
    Icons.pets,
    Icons.school,
    Icons.fitness_center,
  ];

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Neue Kategorie'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name der Kategorie',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LINKE SEITE: FARBEN
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Farbe',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _availableColors.map((color) {
                                final isSelected = _selectedColor == color;
                                return GestureDetector(
                                  onTap: () => setDialogState(
                                      () => _selectedColor = color),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              const BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4)
                                            ]
                                          : null,
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check,
                                            size: 16, color: Colors.white)
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      // RECHTE SEITE: ICONS
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Icon',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              children: _availableIcons.map((icon) {
                                final isSelected = _selectedIcon == icon;
                                return GestureDetector(
                                  onTap: () => setDialogState(
                                      () => _selectedIcon = icon),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _selectedColor.withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? _selectedColor
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Icon(
                                      icon,
                                      size: 24,
                                      color: isSelected
                                          ? _selectedColor
                                          : Colors.grey,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Abbrechen'),
            ),
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
                setState(() {}); // UI der Liste im Hintergrund aktualisieren
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cat.color,
                      child: Icon(cat.icon, color: Colors.white),
                    ),
                    title: Text(
                      cat.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      onPressed: () {
                        widget.onDeleteCategory(cat.id);
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        icon: const Icon(Icons.add),
        label: const Text('Kategorie'),
      ),
    );
  }
}
