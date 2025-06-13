import 'package:flutter/material.dart';

class DietsScreen extends StatelessWidget {
  const DietsScreen({super.key});

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
                    'Detalles del día actual, incluyendo planes de dieta.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DayButton(title: 'Lunes'),
            const SizedBox(height: 8),
            _DayButton(title: 'Martes'),
            const SizedBox(height: 8),
            _DayButton(title: 'Miércoles'),
            const SizedBox(height: 8),
            _DayButton(title: 'Más días...'),
          ],
        ),
      ),
    );
  }
}

class _DayButton extends StatelessWidget {
  final String title;

  const _DayButton({required this.title});

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
