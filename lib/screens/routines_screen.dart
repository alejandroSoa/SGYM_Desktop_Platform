import 'package:flutter/material.dart';
import '../services/RoutineService.dart';
import '../interfaces/bussiness/routine_interface.dart';

class RoutinesScreen extends StatefulWidget {
  @override
  _RoutinesScreenState createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  String _search = '';
  Future<RoutineList?>? _routinesFuture;

  @override
  void initState() {
    super.initState();
    _routinesFuture = RoutineService.fetchRoutines();
  }

  void _refreshRoutines() {
    setState(() {
      _routinesFuture = RoutineService.fetchRoutines();
    });
  }

  Future<void> _showRoutineDialog({Routine? routine}) async {
    final isEdit = routine != null;
    final _nameController = TextEditingController(text: routine?.name ?? '');
    final _dayController = TextEditingController(text: routine?.day ?? '');
    final _descController = TextEditingController(text: routine?.description ?? '');
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(isEdit ? 'Editar Rutina' : 'Crear Rutina'),
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
                      final result = await RoutineService.updateRoutine(
                        id: routine!.id,
                        name: name,
                        day: day,
                        description: desc,
                      );
                      Navigator.pop(context);
                      _refreshRoutines();
                      if (result != null) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Rutina actualizada exitosamente', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error al actualizar rutina', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      }
                    } else {
                      // Aquí debes obtener el userId real, este es un ejemplo
                      final userId = routine?.userId ?? 1;
                      final result = await RoutineService.createRoutine(
                        name: name,
                        day: day,
                        description: desc,
                        userId: userId,
                      );
                      Navigator.pop(context);
                      _refreshRoutines();
                      if (result != null) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Rutina creada exitosamente', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error al crear rutina', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    _refreshRoutines();
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

  Future<void> _confirmDeleteRoutine(Routine routine) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Rutina'),
        content: Text('¿Estás seguro de eliminar la rutina "${routine.name}"?'),
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
        final result = await RoutineService.deleteRoutine(routine.id);
        _refreshRoutines();
        if (result != null && result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Rutina eliminada correctamente', style: TextStyle(color: Colors.white)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error al eliminar rutina', style: TextStyle(color: Colors.white)),
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

  // Método para mostrar y gestionar ejercicios de una rutina
  Future<void> _showRoutineExercisesDialog(Routine routine) async {
    List<Map<String, dynamic>>? exercises = await RoutineService.fetchExercisesOfRoutine(routine.id);
    setState(() {}); // Para refrescar después de cambios

    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController _exerciseIdController = TextEditingController();
        String? errorMessage;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Ejercicios de "${routine.name}"'),
            content: Container(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (exercises == null || exercises?.isEmpty == true)
                    const Text('No hay ejercicios asignados'),
                  if (exercises != null && exercises!.isNotEmpty)
                    ...exercises!.map((ex) => ListTile(
                          title: Text(ex['name'] ?? 'Sin nombre'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Eliminar ejercicio',
                            onPressed: () async {
                              final routineExerciseId = ex['routine_exercise_id'] ?? ex['id'];
                              final ok = await RoutineService.removeExerciseFromRoutine(routineExerciseId);
                              if (ok) {
                                exercises = await RoutineService.fetchExercisesOfRoutine(routine.id);
                                setDialogState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ejercicio eliminado'), backgroundColor: Colors.green),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al eliminar ejercicio'), backgroundColor: Colors.red),
                                );
                              }
                            },
                          ),
                        )),
                  Divider(),
                  TextField(
                    controller: _exerciseIdController,
                    decoration: InputDecoration(
                      labelText: 'ID de ejercicio a añadir',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
                    ),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Añadir ejercicio'),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7710D4), foregroundColor: Colors.white),
                    onPressed: () async {
                      final idStr = _exerciseIdController.text.trim();
                      if (idStr.isEmpty) {
                        setDialogState(() => errorMessage = 'Ingrese un ID de ejercicio');
                        return;
                      }
                      final exerciseId = int.tryParse(idStr);
                      if (exerciseId == null) {
                        setDialogState(() => errorMessage = 'ID inválido');
                        return;
                      }
                      setDialogState(() => errorMessage = null);
                      final result = await RoutineService.assignExerciseToRoutine(
                        routineId: routine.id,
                        exerciseId: exerciseId,
                      );
                      if (result != null) {
                        exercises = await RoutineService.fetchExercisesOfRoutine(routine.id);
                        setDialogState(() {});
                        _exerciseIdController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ejercicio añadido'), backgroundColor: Colors.green),
                        );
                      } else {
                        setDialogState(() => errorMessage = 'No se pudo añadir el ejercicio');
                      }
                    },
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
          ),
        );
      },
    );
    setState(() {}); // Refrescar pantalla principal si es necesario
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
                    onPressed: () => _showRoutineDialog(),
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
                child: FutureBuilder<RoutineList?>(
                  future: _routinesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error al cargar rutinas'));
                    }
                    final routines = snapshot.data;
                    // Filtrar rutinas por nombre
                    final filtered = (routines == null)
                        ? []
                        : routines.where((r) => (r.name ?? '').toLowerCase().contains(_search.toLowerCase())).toList();
                    if (filtered.isEmpty) {
                      return const Center(child: Text('No hay rutinas disponibles'));
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
                              Expanded(child: Text('Ejercicios', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 12))),
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
                              final routine = filtered[index];
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(routine.id.toString()),
                                      )),
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(routine.name ?? ''),
                                      )),
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(routine.day ?? ''),
                                      )),
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(routine.description ?? ''),
                                      )),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton.icon(
                                            icon: Icon(Icons.fitness_center),
                                            label: Text('Ver'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.deepPurple,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            ),
                                            onPressed: () => _showRoutineExercisesDialog(routine),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Color(0xFF7710D4)),
                                            onPressed: () => _showRoutineDialog(routine: routine),
                                            tooltip: 'Editar',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => _confirmDeleteRoutine(routine),
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
                        // Footer paginación (dummy, igual que usuarios)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text('1-2${routines!.length} of ${routines!.length}', style: TextStyle(color: Colors.deepPurple)),
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
