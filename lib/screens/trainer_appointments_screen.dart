import 'package:flutter/material.dart';
import '../services/AppointmentService.dart';
import '../services/UserService.dart';
import '../interfaces/bussiness/appointment_interface.dart';

class TrainerAppointmentsScreen extends StatefulWidget {
  const TrainerAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<TrainerAppointmentsScreen> createState() => _TrainerAppointmentsScreenState();
}

class _TrainerAppointmentsScreenState extends State<TrainerAppointmentsScreen> {
  late Future<TrainerAppointmentList?> _appointmentsFuture = Future.value(null);
  int? trainerId;
  List<Map<String, dynamic>>? userProfiles;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    final results = await Future.wait([
      UserService.fetchUserProfiles(),
      UserService.getUser(),
    ]);
    final profiles = results[0] as List<Map<String, dynamic>>?;
    final user = results[1] as Map<String, dynamic>?;
    int? uid = user != null && user['id'] != null ? user['id'] as int : null;
    setState(() {
      userProfiles = profiles;
      trainerId = uid;
    print('User object from UserService.getUser(): $user');
      _appointmentsFuture = (uid != null)
        ? AppointmentService.fetchTrainerAppointments(trainerId: uid)
        : Future.value([]);
    });
  }

  void _fetchAppointments() {
    print('Fetching appointments for trainerId: $trainerId');
    if (trainerId == null) {
      UserService.getUser().then((user) {
        if (user != null && user['user_id'] != null) {
          trainerId = user['user_id'];
        } 
        setState(() {
          _appointmentsFuture = AppointmentService.fetchTrainerAppointments(trainerId: trainerId!);
        });
      });
    } else {
      setState(() {
        _appointmentsFuture = AppointmentService.fetchTrainerAppointments(trainerId: trainerId!);
      });
    }
  }

  Future<void> _showEditDialog(TrainerAppointment appointment) async {
    final dateController = TextEditingController(text: appointment.date);
    final startTimeController = TextEditingController(text: appointment.startTime);
    final endTimeController = TextEditingController(text: appointment.endTime);
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Editar Cita'),
            content: Container(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: startTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Hora inicio (HH:mm)',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: endTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Hora fin (HH:mm)',
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
                        style: const TextStyle(color: Color(0xFFFF617F)),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7710D4),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final date = dateController.text.trim();
                  final startTime = startTimeController.text.trim();
                  final endTime = endTimeController.text.trim();
                  if (date.isEmpty || startTime.isEmpty || endTime.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'Todos los campos son obligatorios';
                    });
                    return;
                  }
                  setDialogState(() {
                    errorMessage = null;
                  });
                  try {
                    final updatedAppointment = await AppointmentService.updateTrainerAppointment(
                      id: appointment.id,
                      date: date,
                      startTime: startTime,
                      endTime: endTime,
                    );
                    if (updatedAppointment != null) {
                      if (context.mounted) {
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Cita actualizada exitosamente', style: TextStyle(color: Colors.white)),
                          ),
                        );
                      }
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFFFF617F),
                          content: Text('Error al actualizar cita', style: TextStyle(color: Colors.black)),
                        ),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFFFF617F),
                        content: Text('Error: $e', style: const TextStyle(color: Colors.black)),
                      ),
                    );
                  }
                  _fetchAppointments();
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
      },
    );
    _fetchAppointments();
  }

  Future<void> _showDeleteDialog(TrainerAppointment appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Cita'),
        content: Text('¿Estás seguro de eliminar la cita del usuario ${appointment.userId} el ${appointment.date}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7710D4),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final success = await AppointmentService.deleteTrainerAppointment(appointment.id);
        if (success) {
          _fetchAppointments();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Cita eliminada correctamente', style: TextStyle(color: Colors.white)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFFFF617F),
              content: Text('Error al eliminar cita', style: TextStyle(color: Colors.black)),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFFF617F),
            content: Text('Error: $e', style: const TextStyle(color: Colors.black)),
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
        child: FutureBuilder<TrainerAppointmentList?>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            }
            final appointments = snapshot.data;
            if (appointments == null || appointments.isEmpty) {
              return const Center(child: Text('No hay citas registradas.'));
            }
            return Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                border: Border.all(color: Color(0xFF7A5AF8)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Encabezado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: const [
                        Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                        Expanded(child: Text('Usuario', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                        Expanded(child: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
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
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final a = appointments[index];
                        String userName = a.userId.toString();
                        if (userProfiles != null) {
                          final user = userProfiles!.firstWhere(
                            (u) => u['userId'] == a.userId,
                            orElse: () => {},
                          );
                          if (user.isNotEmpty) {
                            userName = user['full_name'] ?? user['name'] ?? user['email'] ?? userName;
                          }
                        }
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(a.id.toString()),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(userName),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(a.date),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(a.startTime),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(a.endTime),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Color(0xFF7710D4)),
                                      onPressed: () => _showEditDialog(a),
                                      tooltip: 'Editar',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _showDeleteDialog(a),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
