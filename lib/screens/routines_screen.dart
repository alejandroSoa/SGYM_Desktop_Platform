import 'package:flutter/material.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2FF),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rutina del día actual, incluyendo ejercicios recomendados y tiempos de descanso.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _RoutineDayButton(title: 'Lunes'),
            const SizedBox(height: 8),
            _RoutineDayButton(title: 'Martes'),
            const SizedBox(height: 8),
            _RoutineDayButton(title: 'Miércoles'),
            const SizedBox(height: 8),
            _RoutineDayButton(title: 'Más días...'),
          ],
        ),
      ),
    );
  }
}

class _RoutineDayButton extends StatelessWidget {
  final String title;

  const _RoutineDayButton({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }
}
