import 'package:flutter/material.dart';
import '../interfaces/payment/membership_interface.dart';
import '../services/MembershipService.dart';

class MembershipsScreen extends StatefulWidget {
  @override
  State<MembershipsScreen> createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends State<MembershipsScreen> {
  MembershipList? memberships;
  bool loading = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    setState(() => loading = true);
    memberships = await MembershipService.fetchMemberships();
    setState(() => loading = false);
  }

  Future<void> showMembershipDialog({Membership? membership}) async {
    final nameController = TextEditingController(text: membership?.name ?? '');
    final durationController = TextEditingController(text: membership?.durationDays.toString() ?? '');
    final priceController = TextEditingController(text: membership?.price.toString() ?? '');
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(membership == null ? 'Nueva Membresía' : 'Editar Membresía'),
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
                    controller: durationController,
                    decoration: InputDecoration(
                      labelText: 'Duración (días)',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Precio',
                      border: OutlineInputBorder(),
                      fillColor: Color(0xFFF2F2FE),
                      filled: true,
                    ),
                    keyboardType: TextInputType.number,
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
                  final duration = int.tryParse(durationController.text.trim()) ?? 0;
                  final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                  if (name.isEmpty || duration <= 0 || price < 0) {
                    setDialogState(() {
                      errorMessage = 'Todos los campos son obligatorios y deben ser válidos';
                    });
                    return;
                  }
                  setDialogState(() {
                    errorMessage = null;
                  });
                  if (membership == null) {
                    await MembershipService.createMembership(
                      name: name,
                      durationDays: duration,
                      price: price,
                    );
                  } else {
                    await MembershipService.updateMembership(
                      id: membership.id,
                      name: name,
                      durationDays: duration,
                      price: price,
                    );
                  }
                  if (context.mounted) Navigator.pop(context, true);
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

  Future<void> _confirmDeleteMembership(Membership membership) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Membresía'),
        content: Text('¿Estás seguro de eliminar la membresía "${membership.name}"?'),
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
      await MembershipService.deleteMembership(membership.id);
      fetchAll();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Membresía eliminada correctamente', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  onPressed: () => showMembershipDialog(),
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
                  : memberships == null
                      ? const Center(child: Text('No se pudieron cargar las membresías'))
                      : Builder(
                          builder: (context) {
                            final filtered = memberships!
                                .where((m) => m.name.toLowerCase().contains(_search.toLowerCase()))
                                .toList();
                            if (filtered.isEmpty) {
                              return const Center(child: Text('No hay membresías disponibles'));
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
                                      Expanded(child: Text('Duración (días)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                      Expanded(child: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
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
                                      final m = filtered[index];
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(m.id.toString()),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(m.name),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(m.durationDays.toString()),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(m.price.toStringAsFixed(2)),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit, color: Color(0xFF7710D4)),
                                                    onPressed: () => showMembershipDialog(membership: m),
                                                    tooltip: 'Editar',
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete),
                                                    onPressed: () => _confirmDeleteMembership(m),
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
    );
  }
}