import 'package:flutter/material.dart';
import '../services/NotificationService.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _loading = true);
    _notifications = await NotificationService.fetchNotifications();
    setState(() => _loading = false);
  }

  void _showForm({Map<String, dynamic>? notification}) {
    final isEdit = notification != null;
    final _userIdController = TextEditingController(text: isEdit ? notification!['user_id'].toString() : '');
    final _titleController = TextEditingController(text: isEdit ? notification!['title'] ?? '' : '');
    final _bodyController = TextEditingController(text: isEdit ? notification!['body'] ?? '' : '');
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(isEdit ? 'Editar Notificación' : 'Crear Notificación'),
            content: Container(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _userIdController,
                    decoration: InputDecoration(
                      labelText: 'ID Usuario',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bodyController,
                    decoration: InputDecoration(
                      labelText: 'Mensaje',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
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
                onPressed: () async {
                  final userId = int.tryParse(_userIdController.text.trim());
                  final title = _titleController.text.trim();
                  final body = _bodyController.text.trim();
                  if (userId == null || title.isEmpty || body.isEmpty) {
                    setDialogState(() => errorMessage = 'Todos los campos son obligatorios');
                    return;
                  }
                  setDialogState(() => errorMessage = null);
                  Navigator.pop(context);
                  setState(() => _loading = true);
                  if (isEdit) {
                    // No hay endpoint para editar, solo reenviar como nueva
                    await NotificationService.sendNotificationToBackend(
                      userId: userId,
                      type: notification!['type'] ?? 'custom',
                      title: title,
                      body: body,
                    );
                  } else {
                    await NotificationService.sendNotificationToBackend(
                      userId: userId,
                      type: 'custom',
                      title: title,
                      body: body,
                    );
                  }
                  await _fetchNotifications();
                },
                child: Text(isEdit ? 'Actualizar' : 'Crear'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteNotification(Map<String, dynamic> notification) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Notificación'),
        content: Text('¿Estás seguro de eliminar la notificación "${notification['title'] ?? ''}"?'),
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
      setState(() => _loading = true);
      final ok = await NotificationService.deleteNotification(notification['id']);
      await _fetchNotifications();
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notificación eliminada correctamente'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar notificación'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _notifications.where((n) {
      final title = (n['title'] ?? '').toString().toLowerCase();
      final body = (n['body'] ?? '').toString().toLowerCase();
      return title.contains(_search.toLowerCase()) || body.contains(_search.toLowerCase());
    }).toList();

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
                    onPressed: () => _showForm(),
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
                child: _loading
                    ? Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? Center(child: Text('No hay notificaciones disponibles'))
                        : Column(
                            children: [
                              // Encabezado
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                child: Row(
                                  children: const [
                                    Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                    Expanded(child: Text('Título', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                    Expanded(child: Text('Mensaje', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                    Expanded(child: Text('Usuario', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
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
                                    final notif = filtered[index];
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(notif['id'].toString()),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(notif['title'] ?? ''),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(notif['body'] ?? ''),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(notif['user_id']?.toString() ?? ''),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit, color: Color(0xFF7710D4)),
                                                  onPressed: () => _showForm(notification: notif),
                                                  tooltip: 'Editar',
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete),
                                                  onPressed: () => _confirmDeleteNotification(notif),
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
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
