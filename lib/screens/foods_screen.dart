import 'package:flutter/material.dart';
import '../services/FoodService.dart';
import '../interfaces/bussiness/food_interface.dart';
import 'dart:async';

class FoodsScreen extends StatefulWidget {
  const FoodsScreen({Key? key}) : super(key: key);

  @override
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen> {
  FoodList? foods;
  bool loading = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    setState(() => loading = true);
    foods = await FoodService.fetchFoods();
    setState(() => loading = false);
  }

  Future<void> showFoodDialog({Food? food}) async {
    final nameController = TextEditingController(text: food?.name ?? '');
    final gramsController = TextEditingController(text: food?.grams.toString() ?? '');
    final caloriesController = TextEditingController(text: food?.calories.toString() ?? '');
    final otherInfoController = TextEditingController(text: food?.otherInfo ?? '');
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(food == null ? 'Nuevo Alimento' : 'Editar Alimento'),
            content: Container(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: gramsController,
                    decoration: InputDecoration(
                      labelText: 'Gramos',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: caloriesController,
                    decoration: InputDecoration(
                      labelText: 'Calorías',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otherInfoController,
                    decoration: InputDecoration(
                      labelText: 'Otra información',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Color(0xFFFF617F)),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7710D4),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final name = nameController.text.trim();
                  final grams = double.tryParse(gramsController.text.trim()) ?? 0.0;
                  final calories = double.tryParse(caloriesController.text.trim()) ?? 0.0;
                  final otherInfo = otherInfoController.text.trim().isEmpty ? null : otherInfoController.text.trim();
                  if (name.isEmpty || grams <= 0 || calories < 0) {
                    setDialogState(() {
                      errorMessage = 'Todos los campos son obligatorios y deben ser válidos';
                    });
                    return;
                  }
                  setDialogState(() {
                    errorMessage = null;
                  });
                  try {
                    if (food == null) {
                      await FoodService.createFood(
                        name: name,
                        grams: grams,
                        calories: calories,
                        otherInfo: otherInfo,
                      );
                      if (context.mounted) {
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Alimento creado exitosamente', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      }
                    } else {
                      await FoodService.updateFood(
                        id: food.id,
                        name: name,
                        grams: grams,
                        calories: calories,
                        otherInfo: otherInfo,
                      );
                      if (context.mounted) {
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Alimento actualizado exitosamente', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        backgroundColor: Color(0xFFFF617F),
                        content: Text('Error: $e', style: TextStyle(color: Colors.black)),
                      ),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
      },
    );
    fetchAll();
  }

  Future<void> _confirmDeleteFood(Food food) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Alimento'),
        content: Text('¿Estás seguro de eliminar el alimento "${food.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7710D4),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await FoodService.deleteFood(food.id);
        fetchAll();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Alimento eliminado correctamente', style: TextStyle(color: Colors.white)),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color(0xFFFF617F),
            content: Text('Error: $e', style: TextStyle(color: Colors.black)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Barra de búsqueda y botón Añadir en la misma fila
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Buscar',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (val) => setState(() => _search = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Añadir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7710D4),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => showFoodDialog(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  border: Border.all(color: Color(0xFF7A5AF8)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : foods == null
                        ? const Center(child: Text('No se pudieron cargar los alimentos'))
                        : Builder(
                            builder: (context) {
                              final filtered = foods!
                                  .where((f) => f.name.toLowerCase().contains(_search.toLowerCase()))
                                  .toList();
                              if (filtered.isEmpty) {
                                return const Center(child: Text('No hay alimentos disponibles'));
                              }
                              return Column(
                                children: [
                                  // Encabezado
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                    child: Row(
                                      children: const [
                                        Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                        Expanded(child: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                        Expanded(child: Text('Gramos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                        Expanded(child: Text('Calorías', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                        Expanded(child: Text('Otra info', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 12))),
                                        SizedBox(width: 100), // espacio para botones
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1, color: Colors.deepPurpleAccent),
                                  // Lista
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) {
                                        final f = filtered[index];
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(f.id.toString()),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(f.name),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(f.grams.toString()),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(f.calories.toStringAsFixed(2)),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(f.otherInfo ?? ''),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.edit, color: Color(0xFF7710D4)),
                                                      onPressed: () => showFoodDialog(food: f),
                                                      tooltip: 'Editar',
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete),
                                                      onPressed: () => _confirmDeleteFood(f),
                                                      tooltip: 'Eliminar',
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const Divider(height: 1, color: Colors.deepPurpleAccent),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  // Footer paginación (dummy)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text('1-${filtered.length} de ${filtered.length}', style: TextStyle(color: Colors.deepPurple)),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.first_page, color: Colors.deepPurple),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.chevron_left, color: Colors.deepPurple),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.chevron_right, color: Colors.deepPurple),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.last_page, color: Colors.deepPurple),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
