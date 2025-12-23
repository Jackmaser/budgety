import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  final List<Category> categories;
  final Function(Category) onAddCategory;
  final Function(Category) onUpdateCategory;
  final Function(String) onDeleteCategory;

  const CategoryScreen({
    super.key,
    required this.categories,
    required this.onAddCategory,
    required this.onUpdateCategory,
    required this.onDeleteCategory,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.teal;
  IconData _selectedIcon = Icons.star;

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
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];

  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.icecream,
    Icons.fastfood,
    Icons.shopping_cart,
    Icons.shopping_bag,
    Icons.payments,
    Icons.credit_card,
    Icons.savings,
    Icons.account_balance,
    Icons.directions_car,
    Icons.directions_bus,
    Icons.pedal_bike,
    Icons.flight,
    Icons.hotel,
    Icons.commute,
    Icons.home,
    Icons.lightbulb,
    Icons.electrical_services,
    Icons.water_drop,
    Icons.wifi,
    Icons.cleaning_services,
    Icons.inventory,
    Icons.movie,
    Icons.sports_esports,
    Icons.fitness_center,
    Icons.brush,
    Icons.music_note,
    Icons.camera_alt,
    Icons.theater_comedy,
    Icons.medical_services,
    Icons.healing,
    Icons.spa,
    Icons.psychology,
    Icons.work,
    Icons.laptop,
    Icons.school,
    Icons.menu_book,
    Icons.pets,
    Icons.child_friendly,
    Icons.redeem,
    Icons.celebration,
    Icons.star,
    Icons.build,
    Icons.checkroom
  ];

  void _showCategoryDialog({Category? categoryToEdit}) {
    if (categoryToEdit != null) {
      _nameController.text = categoryToEdit.name;
      _selectedColor = categoryToEdit.color;
      _selectedIcon = categoryToEdit.icon;
    } else {
      _nameController.clear();
      _selectedColor = Colors.teal;
      _selectedIcon = Icons.star;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(categoryToEdit != null
              ? 'Kategorie bearbeiten'
              : 'Neue Kategorie'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: 'Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 25),
                  const Text('Farbe wählen',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _availableColors
                        .map((color) => GestureDetector(
                              onTap: () =>
                                  setDialogState(() => _selectedColor = color),
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _selectedColor == color
                                          ? Colors.black
                                          : Colors.transparent,
                                      width: 2),
                                ),
                                child: _selectedColor == color
                                    ? const Icon(Icons.check,
                                        size: 20, color: Colors.white)
                                    : null,
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 25),
                  const Text('Icon wählen',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableIcons
                        .map((icon) => GestureDetector(
                              onTap: () =>
                                  setDialogState(() => _selectedIcon = icon),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _selectedIcon == icon
                                      ? _selectedColor.withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: _selectedIcon == icon
                                          ? _selectedColor
                                          : Colors.grey.shade300),
                                ),
                                child: Icon(icon,
                                    color: _selectedIcon == icon
                                        ? _selectedColor
                                        : Colors.grey[600],
                                    size: 28),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Abbrechen')),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isEmpty) return;

                final newCat = Category(
                  id: categoryToEdit?.id ?? DateTime.now().toString(),
                  name: _nameController.text,
                  icon: _selectedIcon,
                  color: _selectedColor,
                  lastModified: DateTime.now(),
                );

                // Hier rufen wir NUR die Callbacks auf.
                // Da der HomeScreen setState() macht und die Liste manipuliert,
                // müssen wir hier nichts mehr manuell hinzufügen.
                if (categoryToEdit != null) {
                  widget.onUpdateCategory(newCat);
                } else {
                  widget.onAddCategory(newCat);
                }

                Navigator.of(ctx).pop();

                // Wir triggern ein lokales Neuzeichnen, damit die Liste
                // die Änderungen aus dem HomeScreen sofort anzeigt.
                setState(() {});
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
      appBar: AppBar(title: const Text('Kategorien verwalten')),
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
                        child: Icon(cat.icon, color: Colors.white)),
                    title: Text(cat.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showCategoryDialog(categoryToEdit: cat)),
                        IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () {
                              // Auch hier: Nur den Callback rufen.
                              widget.onDeleteCategory(cat.id);
                              setState(() {});
                            }),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Neue Kategorie'),
      ),
    );
  }
}
