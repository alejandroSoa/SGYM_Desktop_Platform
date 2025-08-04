import 'package:flutter/material.dart';
import '../interfaces/bussiness/diet_interface.dart';
// Asegúrate de tener un DietService con los métodos necesarios
import '../services/DietService.dart';
import '../services/UserService.dart';
import '../services/FoodService.dart';

class DietsScreen extends StatefulWidget {
  @override
  _DietsScreenState createState() => _DietsScreenState();
}

class _DietsScreenState extends State<DietsScreen> {
  Future<void> _showAssignDietDialog(Diet diet) async {
    int? selectedUserId;
    String? errorMessage;
    String? day;
    final List<String> daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    List<Map<String, dynamic>> users = [];
    bool isLoading = true;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (isLoading) {
              // Cargar usuarios solo la primera vez
              UserService.fetchUserProfiles().then((result) {
                setDialogState(() {
                  users = result ?? [];
                  isLoading = false;
                });
              }).catchError((e) {
                setDialogState(() {
                  isLoading = false;
                  errorMessage = 'Error al cargar usuarios: $e';
                });
              });
              return AlertDialog(
                title: Text('Asignar dieta a usuario'),
                content: Container(
                  width: 350,
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                ],
              );
            }
            return AlertDialog(
              title: Text('Asignar dieta a usuario'),
              content: Container(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (users.isEmpty)
                      const Text('No hay usuarios disponibles'),
                    if (users.isNotEmpty)
                      DropdownButtonFormField<int>(
                        value: selectedUserId,
                        items: users.map((user) {
                          return DropdownMenuItem<int>(
                            value: user['user_id'],
                            child: Text(user['full_name'] ?? 'Usuario'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedUserId = val;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Usuario',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: day,
                      items: daysOfWeek.map((d) => DropdownMenuItem<String>(
                        value: d,
                        child: Text(d[0].toUpperCase() + d.substring(1)),
                      )).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          day = val;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Día',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
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
                  onPressed: users.isEmpty
                      ? null
                      : () async {
                          if (selectedUserId == null) {
                            setDialogState(() => errorMessage = 'Seleccione un usuario');
                            return;
                          }
                          if (day == null || day!.trim().isEmpty) {
                            setDialogState(() => errorMessage = 'Ingrese el día');
                            return;
                          }
                          setDialogState(() => errorMessage = null);
                          try {
                            final result = await DietService.assignDietToUser(
                              dietId: diet.id,
                              userId: selectedUserId!,
                              day: day!,
                            );
                            Navigator.pop(context);
                            if (result != null) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text('Dieta asignada exitosamente', style: TextStyle(color: Colors.white)),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('Error al asignar dieta', style: TextStyle(color: Colors.white)),
                                ),
                              );
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
                  child: Text('Asignar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<void> _showManageFoodsDialog(Diet diet) async {
    List<Map<String, dynamic>>? foodsOfDiet;
    List<dynamic>? allFoods;
    int? selectedFoodId;
    String? errorMessage;
    bool isLoading = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Cargar alimentos solo la primera vez
            if (isLoading) {
              Future.wait([
                DietService.fetchFoodsOfDiet(diet.id),
                FoodService.fetchFoods(),
              ]).then((results) {
                setDialogState(() {
                  foodsOfDiet = results[0] as List<Map<String, dynamic>>?;
                  allFoods = results[1] as List<dynamic>?;
                  isLoading = false;
                });
              });
              return AlertDialog(
                title: Text('Gestionar alimentos de "${diet.name}"'),
                content: Container(
                  width: 400,
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cerrar'),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: Text('Gestionar alimentos de "${diet.name}"'),
              content: Container(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (foodsOfDiet == null || foodsOfDiet!.isEmpty)
                      const Text('No hay alimentos asignados a esta dieta'),
                    if (foodsOfDiet != null && foodsOfDiet!.isNotEmpty)
                      ...foodsOfDiet!.map((food) {
                        final foodObj = food['food'];
                        final foodName = foodObj != null ? (foodObj['name'] ?? 'Sin nombre') : (food['name'] ?? 'Sin nombre');
                        final foodCalories = foodObj != null ? foodObj['calories'] : food['calories'];
                        return ListTile(
                          title: Text(foodName),
                          subtitle: Text('Calorías: ${foodCalories ?? ''}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Eliminar alimento',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Eliminar alimento'),
                                  content: Text('¿Eliminar "$foodName" de la dieta?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await DietService.removeFoodFromDiet(
                                  dietId: diet.id,
                                  dietFoodId: food['id'],
                                );
                                final updatedFoods = await DietService.fetchFoodsOfDiet(diet.id);
                                setDialogState(() {
                                  foodsOfDiet = updatedFoods;
                                });
                              }
                            },
                          ),
                        );
                      }),
                    Divider(),
                    DropdownButtonFormField<int>(
                      value: selectedFoodId,
                      items: (allFoods ?? []).map<DropdownMenuItem<int>>((food) {
                        return DropdownMenuItem<int>(
                          value: food.id,
                          child: Text(food.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedFoodId = val;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Selecciona un alimento para añadir',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Añadir alimento'),
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7710D4), foregroundColor: Colors.white),
                      onPressed: () async {
                        if (selectedFoodId == null) {
                          setDialogState(() => errorMessage = 'Seleccione un alimento');
                          return;
                        }
                        setDialogState(() => errorMessage = null);
                        await DietService.addFoodsToDiet(
                          dietId: diet.id,
                          foodIds: [selectedFoodId!],
                        );
                        final updatedFoods = await DietService.fetchFoodsOfDiet(diet.id);
                        setDialogState(() {
                          foodsOfDiet = updatedFoods;
                          selectedFoodId = null;
                        });
                      },
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
    setState(() {}); // Refrescar pantalla principal si es necesario
  }
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
                  final desc = _descController.text.trim();
                  if (name.isEmpty ) {
                    setDialogState(() {
                      errorMessage = 'Nombre es obligatorio';
                    });
                    return;
                  }
                  setDialogState(() {
                    errorMessage = null;
                  });
                  try {
                    if (isEdit) {
                      final result = await DietService.updateDiet(
                        id: diet.id,
                        name: name,
                        description: desc,
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
                      final result = await DietService.createDiet(
                        name: name,
                        description: desc,
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
        if (result == true) {
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
                        : diets.where((d) => (d.name).toLowerCase().contains(_search.toLowerCase())).toList();
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
                              Expanded(child: Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                              Expanded(child: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 12))),
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
                                        child: Text(diet.description ?? ''),
                                      )),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              ElevatedButton.icon(
                                                icon: Icon(Icons.food_bank),
                                                label: Text('Ver'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.deepPurple,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                ),
                                                onPressed: () => _showManageFoodsDialog(diet),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                icon: Icon(Icons.person_add),
                                                label: Text('Asignar'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.deepPurple.shade200,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                ),
                                                onPressed: () => _showAssignDietDialog(diet),
                                              ),
                                            ],
                                          ),
                                        ),
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
