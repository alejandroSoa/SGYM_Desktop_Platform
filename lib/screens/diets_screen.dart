import 'package:flutter/material.dart';
import '../interfaces/bussiness/diet_interface.dart';
// Asegúrate de tener un DietService con los métodos necesarios
import '../services/DietService.dart';

class DietsScreen extends StatefulWidget {
  @override
  _DietsScreenState createState() => _DietsScreenState();
}

class _DietsScreenState extends State<DietsScreen> {
  String _search = '';
  Future<DietList?>? _dietsFuture;

  @override
  void initState() {
    super.initState();
    _dietsFuture = DietService.fetchDiets();
  }

  void _refreshDiets() {
    setState(() {
      _dietsFuture = DietService.fetchDiets();
    });
  }

  Future<void> _showDietDialog({Diet? diet}) async {
    final isEdit = diet != null;
    final _nameController = TextEditingController(text: diet?.name ?? '');
    final _dayController = TextEditingController(text: diet?.day ?? '');
    final _descController = TextEditingController(text: diet?.description ?? '');
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(isEdit ? 'Editar Dieta' : 'Crear Dieta'),
            content: Container(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dayController,
                    decoration: InputDecoration(
                      labelText: 'Día',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
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
                  final name = _nameController.text.trim();
                  final day = _dayController.text.trim();
                  final desc = _descController.text.trim();
                  if (name.isEmpty || day.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'Nombre y día son obligatorios';
                    });
                    return;
                  }
                  setDialogState(() {
                    errorMessage = null;
                  });
                  try {
                    if (isEdit) {
                      final result = await DietService.updateDiet(
                        id: diet!.id,
                        name: name,
                        day: day,
                        description: desc,
                        userId: diet.userId,
                      );
                      Navigator.pop(context);
                      _refreshDiets();
                      if (result != null) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Dieta actualizada exitosamente', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error al actualizar dieta', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      }
                    } else {
                      // Aquí debes obtener el userId real, este es un ejemplo
                      final userId = diet?.userId ?? 1;
                      final result = await DietService.createDiet(
                        name: name,
                        day: day,
                        description: desc,
                        userId: userId,
                      );
                      Navigator.pop(context);
                      _refreshDiets();
                      if (result != null) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Dieta creada exitosamente', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error al crear dieta', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    _refreshDiets();
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        backgroundColor: Color(0xFFFF617F),
                        content: Text('Error: $e', style: TextStyle(color: Colors.black)),
                      ),
                    );
                  }
                },
                child: Text(isEdit ? 'Guardar' : 'Crear'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteDiet(Diet diet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Dieta'),
        content: Text('¿Estás seguro de eliminar la dieta "${diet.name}"?'),
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
        final result = await DietService.deleteDiet(diet.id);
        _refreshDiets();
        if (result != null && result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Dieta eliminada correctamente', style: TextStyle(color: Colors.white)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error al eliminar dieta', style: TextStyle(color: Colors.white)),
            ),
          );
        }
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
                    onPressed: () => _showDietDialog(),
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
                child: FutureBuilder<DietList?>(
                  future: _dietsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error al cargar dietas'));
                    }
                    final diets = snapshot.data;
                    // Filtrar dietas por nombre
                    final filtered = (diets == null)
                        ? []
                        : diets.where((d) => (d.name ?? '').toLowerCase().contains(_search.toLowerCase())).toList();
                    if (filtered.isEmpty) {
                      return const Center(child: Text('No hay dietas disponibles'));
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
                              Expanded(child: Text('Día', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                              Expanded(child: Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
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
                              final diet = filtered[index];
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(diet.id.toString()),
                                      )),
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(diet.name),
                                      )),
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(diet.day),
                                      )),
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(diet.description ?? ''),
                                      )),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Color(0xFF7710D4)),
                                            onPressed: () => _showDietDialog(diet: diet),
                                            tooltip: 'Editar',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => _confirmDeleteDiet(diet),
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
