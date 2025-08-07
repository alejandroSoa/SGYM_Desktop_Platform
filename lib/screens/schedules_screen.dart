import 'package:flutter/material.dart';
import '../services/ScheduleService.dart';
import '../services/UserService.dart';
import '../interfaces/bussiness/schedule_interface.dart';

class SchedulesScreen extends StatefulWidget {
  @override
  _SchedulesScreenState createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  ScheduleList? schedules;
  List<Map<String, dynamic>>? userProfiles;
  bool isLoading = true;
  String _search = '';

  // Form fields para modal
  int? selectedUserId;
  String? startTime;
  String? endTime;
  int? editingScheduleId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final profiles = await UserService.fetchUserProfiles();
    final scheds = await ScheduleService.fetchSchedules();
    setState(() {
      userProfiles = profiles;
      schedules = scheds;
      isLoading = false;
    });
  }

  String _getUserName(int userId) {
    final user = userProfiles?.firstWhere(
      (u) => u['user_id'] == userId,
      orElse: () => {},
    );
    return user != null && user.isNotEmpty
        ? (user['full_name'] ?? user['name'] ?? user['email'] ?? 'Desconocido')
        : 'Desconocido';
  }

  Future<void> _showScheduleDialog({Schedule? schedule}) async {
    final isEdit = schedule != null;
    selectedUserId = schedule?.userId;
    startTime = schedule?.startTime;
    endTime = schedule?.endTime;
    String? errorMessage;

    String formatHour(String? hour) {
      if (hour == null) return '';
      // Si viene como HH:mm:ss, lo recorta a HH:mm
      final parts = hour.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      return hour;
    }

    String timeOfDayToString(TimeOfDay tod) {
      return '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(isEdit ? 'Editar Horario' : 'Crear Horario'),
            content: Container(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedUserId,
                    hint: Text('Selecciona usuario'),
                    items: userProfiles?.map((user) {
                      String display;
                      if ((user['full_name'] != null && user['full_name'].toString().trim().isNotEmpty)) {
                        display = user['full_name'];
                      } else if ((user['name'] != null && user['name'].toString().trim().isNotEmpty)) {
                        display = user['name'];
                      } else if ((user['email'] != null && user['email'].toString().trim().isNotEmpty)) {
                        display = user['email'];
                      } else {
                        display = user.toString();
                      }
                      return DropdownMenuItem<int>(
                        value: user['user_id'],
                        child: Text(display),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() => selectedUserId = val);
                    },
                    decoration: InputDecoration(
                      labelText: 'Usuario',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: startTime != null && startTime!.contains(':')
                            ? TimeOfDay(
                                hour: int.tryParse(startTime!.split(':')[0]) ?? 8,
                                minute: int.tryParse(startTime!.split(':')[1]) ?? 0)
                            : TimeOfDay(hour: 8, minute: 0),
                      );
                      if (picked != null) {
                        setDialogState(() => startTime = timeOfDayToString(picked));
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Hora inicio (HH:mm)',
                        border: OutlineInputBorder(),
                        fillColor: Color(0xFFF2F2FE),
                        filled: true,
                      ),
                      child: Text(startTime ?? 'Selecciona hora'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: endTime != null && endTime!.contains(':')
                            ? TimeOfDay(
                                hour: int.tryParse(endTime!.split(':')[0]) ?? 17,
                                minute: int.tryParse(endTime!.split(':')[1]) ?? 0)
                            : TimeOfDay(hour: 17, minute: 0),
                      );
                      if (picked != null) {
                        setDialogState(() => endTime = timeOfDayToString(picked));
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Hora fin (HH:mm)',
                        border: OutlineInputBorder(),
                        fillColor: Color(0xFFF2F2FE),
                        filled: true,
                      ),
                      child: Text(endTime ?? 'Selecciona hora'),
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
                  if (selectedUserId == null) {
                    setDialogState(() => errorMessage = 'Seleccione un usuario');
                    return;
                  }
                  if (startTime == null || startTime!.trim().isEmpty) {
                    setDialogState(() => errorMessage = 'Ingrese la hora de inicio');
                    return;
                  }
                  if (endTime == null || endTime!.trim().isEmpty) {
                    setDialogState(() => errorMessage = 'Ingrese la hora de fin');
                    return;
                  }
                  setDialogState(() => errorMessage = null);
                  try {
                    if (isEdit) {
                      final result = await ScheduleService.updateSchedule(
                        id: schedule!.id,
                        userId: selectedUserId!,
                        startTime: formatHour(startTime!),
                        endTime: formatHour(endTime!),
                      );
                      Navigator.pop(context);
                      await _loadData();
                      if (result != null) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Horario actualizado exitosamente', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error al actualizar horario', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      }
                    } else {
                      final result = await ScheduleService.createSchedule(
                        userId: selectedUserId!,
                        startTime: formatHour(startTime!),
                        endTime: formatHour(endTime!),
                      );
                      Navigator.pop(context);
                      await _loadData();
                      if (result != null) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Horario creado exitosamente', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error al crear horario', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    await _loadData();
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

  Future<void> _confirmDeleteSchedule(Schedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Horario'),
        content: Text('¿Estás seguro de eliminar el horario de "${_getUserName(schedule.userId)}" de ${schedule.startTime} a ${schedule.endTime}?'),
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
        final result = await ScheduleService.deleteSchedule(schedule.id);
        await _loadData();
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Horario eliminado correctamente', style: TextStyle(color: Colors.white)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error al eliminar horario', style: TextStyle(color: Colors.white)),
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
            // Barra de búsqueda y botón Añadir
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
                    onPressed: () => _showScheduleDialog(),
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
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Builder(
                        builder: (context) {
                          final filtered = (schedules ?? [])
                              .where((s) =>
                                  _getUserName(s.userId)
                                      .toLowerCase()
                                      .contains(_search.toLowerCase()) ||
                                  (s.startTime ?? '')
                                      .toLowerCase()
                                      .contains(_search.toLowerCase()) ||
                                  (s.endTime ?? '')
                                      .toLowerCase()
                                      .contains(_search.toLowerCase()))
                              .toList();
                          if (filtered.isEmpty) {
                            return const Center(child: Text('No hay horarios disponibles'));
                          }
                          return Column(
                            children: [
                              // Encabezado
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                child: Row(
                                  children: const [
                                    Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                    Expanded(child: Text('Usuario', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                    Expanded(child: Text('Hora inicio', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                    Expanded(child: Text('Hora fin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                    SizedBox(width: 100), // espacio para botones
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Colors.deepPurpleAccent),
                              // Lista
                              Expanded(
                                child: ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, idx) {
                                    final sched = filtered[idx];
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(sched.id.toString()),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(_getUserName(sched.userId)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(sched.startTime),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(sched.endTime),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit, color: Color(0xFF7710D4)),
                                                  onPressed: () => _showScheduleDialog(schedule: sched),
                                                  tooltip: 'Editar',
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete),
                                                  onPressed: () => _confirmDeleteSchedule(sched),
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
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
