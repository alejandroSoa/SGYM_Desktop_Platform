import 'package:flutter/material.dart';

class DayAdvice extends StatelessWidget {
  final Color color;
  final String frase;

  const DayAdvice({
    super.key,
    required this.color,
    required this.frase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        frase,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
