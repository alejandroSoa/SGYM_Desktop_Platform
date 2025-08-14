import 'package:flutter/material.dart';
import '../services/StationService.dart';
import '../interfaces/bussiness/station_interface.dart';

class StationsScreen extends StatefulWidget {
  @override
  _StationsScreenState createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  List<Station> _stations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    setState(() => _loading = true);
    try {
      final stations = await StationService.getStations();
      setState(() {
        _stations = stations;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar estaciones: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditDialog(Station station) {
    final typeController = TextEditingController(text: station.type);
    final locationController = TextEditingController(text: station.location);
    final firmwareController = TextEditingController(text: station.firmwareVersion);
    final statusController = TextEditingController(text: station.status);
    final hardwareController = TextEditingController(text: station.hardwareId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar estación'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: 'Tipo'),
                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: 'Ubicación'),
                ),
                TextField(
                  controller: firmwareController,
                  decoration: InputDecoration(labelText: 'Firmware Version'),
                ),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(labelText: 'Status'),
                ),
                TextField(
                  controller: hardwareController,
                  decoration: InputDecoration(labelText: 'Hardware ID'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: Text('Guardar'),
              onPressed: () async {
                final ok = await StationService.updateStation(
                  id: station.id,
                  type: typeController.text,
                  location: locationController.text,
                  firmwareVersion: firmwareController.text,
                  status: statusController.text,
                  hardwareId: hardwareController.text,
                );
                Navigator.of(context).pop();
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Estación actualizada'), backgroundColor: Colors.green),
                  );
                  _fetchStations();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar estación'), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  border: Border.all(color: Color(0xFF7A5AF8)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Row(
                        children: const [
                          Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                          Expanded(child: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                          Expanded(child: Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                          Expanded(child: Text('Firmware', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                          Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                          Expanded(child: Text('Hardware', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                          SizedBox(width: 120),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.deepPurpleAccent),
                    Expanded(
                      child: _stations.isEmpty
                          ? const Center(child: Text('No hay estaciones'))
                          : ListView.builder(
                              itemCount: _stations.length,
                              itemBuilder: (context, i) {
                                final st = _stations[i];
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(st.id.toString()),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(st.type),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(st.location),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(st.firmwareVersion),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(st.status),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(st.hardwareId),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            ElevatedButton.icon(
                                              icon: Icon(Icons.edit, color: Colors.white),
                                              label: Text('Editar'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.deepPurple,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () => _showEditDialog(st),
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
              ),
            ),
    );
  }
}
