import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../services/ExerciseService.dart';
import '../interfaces/bussiness/excersice_interface.dart';

class ExercisesScreen extends StatefulWidget {
  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<Exercise> _exercises = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    setState(() => _loading = true);
    try {
      final exercises = await ExerciseService.getExercises();
      setState(() {
        _exercises = exercises;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar ejercicios: $e')),
      );
    }
  }

  void _showExerciseDialog({Exercise? exercise}) {
    final isEdit = exercise != null;
    final nameController = TextEditingController(text: exercise?.name ?? '');
    final descController = TextEditingController(text: exercise?.description ?? '');
    final videoController = TextEditingController(text: exercise?.videoUrl ?? '');
    EquipmentType selectedType = exercise?.equipmentType ?? EquipmentType.machine;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Editar Ejercicio' : 'Agregar Ejercicio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                DropdownButton<EquipmentType>(
                  value: selectedType,
                  onChanged: (val) {
                    if (val != null) {
                      selectedType = val;
                      setState(() {});
                    }
                  },
                  items: EquipmentType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: videoController,
                  decoration: InputDecoration(labelText: 'Video URL'),
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
              onPressed: () async {
                final name = nameController.text.trim();
                final desc = descController.text.trim();
                final video = videoController.text.trim();
                if (name.isEmpty || desc.isEmpty) return;
                try {
                  if (isEdit) {
                    await ExerciseService.updateExercise(
                      id: exercise.id,
                      name: name,
                      description: desc,
                      equipmentType: selectedType,
                      videoUrl: video,
                    );
                  } else {
                    await ExerciseService.createExercise(
                      name: name,
                      description: desc,
                      equipmentType: selectedType,
                      videoUrl: video,
                    );
                  }
                  Navigator.pop(context);
                  _fetchExercises();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Text(isEdit ? 'Guardar' : 'Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteExercise(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar ejercicio'),
        content: Text('¿Seguro que deseas eliminar este ejercicio?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ExerciseService.deleteExercise(id);
        _fetchExercises();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  void _showVideoDialog(String url) async {
    if (kIsWeb) {
      // Solo permitir MP4/HLS en web, si no, abrir en nueva pestaña
      if (url.endsWith('.mp4') || url.contains('.m3u8')) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _VideoPlayerWidget(videoUrl: url),
            ),
          ),
        );
      } else {
        // Abrir en nueva pestaña
        if (await canLaunchUrl(Uri.parse(url))) {
          launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Formato de video no soportado en web')),
          );
        }
      }
    } else {
      // En mobile/desktop, intentar reproducir normalmente
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _VideoPlayerWidget(videoUrl: url),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = ExerciseService.filterExercises(_exercises, _search);
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Barra de búsqueda y botón Añadir en la misma fila
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Barra de búsqueda expandible
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
                          onPressed: () => _showExerciseDialog(),
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
                      child: Column(
                        children: [
                          // Encabezado
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            child: Row(
                              children: const [
                                Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                Expanded(child: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                Expanded(child: Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                Expanded(child: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                Expanded(child: Text('Video', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                SizedBox(width: 100), // espacio para botones
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Colors.deepPurpleAccent),
                          // Lista de ejercicios
                          Expanded(
                            child: filtered.isEmpty
                                ? const Center(child: Text('No hay ejercicios disponibles'))
                                : ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (context, i) {
                                      final ex = filtered[i];
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(ex.id.toString()),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(ex.name),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(ex.description),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(ex.equipmentType.displayName),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: (ex.videoUrl.isNotEmpty)
                                                      ? TextButton.icon(
                                                          icon: Icon(Icons.play_circle, color: Colors.deepPurple),
                                                          label: Text('Ver video', style: TextStyle(color: Colors.deepPurple)),
                                                          onPressed: () => _showVideoDialog(ex.videoUrl),
                                                        )
                                                      : Text('-'),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit, color: Color(0xFF7710D4)),
                                                    onPressed: () => _showExerciseDialog(exercise: ex),
                                                    tooltip: 'Editar',
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete),
                                                    onPressed: () => _deleteExercise(ex.id),
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
                          // Footer paginación (dummy, igual que rutinas)
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
      // Eliminado FloatingActionButton
    );
  }
}

// Widget para reproducir video
class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Center(child: CircularProgressIndicator());
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        VideoPlayer(_controller),
        VideoProgressIndicator(_controller, allowScrubbing: true),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: Colors.white,
              size: 48,
            ),
            onPressed: () {
              setState(() {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              });
            },
          ),
        ),
      ],
    );
  }
}
