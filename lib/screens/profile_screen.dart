import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              const Text(
                'Alfredo Cholico',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'aldocholico@gmail.com',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EEFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoBox(
                      icon: Icons.male,
                      label: 'Gender',
                      value: 'Male',
                    ),
                    _InfoBox(
                      icon: Icons.calendar_month,
                      label: 'Age',
                      value: '20 yrs',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _OptionItem(title: 'Subscripción'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _EditableField(label: 'Nombre completo', value: 'Alfredo Cholico'),
                    SizedBox(height: 12),
                    _EditableField(label: 'Contraseña', value: '********'),
                    SizedBox(height: 12),
                    _EditableField(label: 'Teléfono', value: '+52 123 456 7890'),
                    SizedBox(height: 150),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String title;

  const _OptionItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EEFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 24, height: 24, color: Colors.grey[300]),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.black54),
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final String value;

  const _EditableField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFFF2EEFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
          const Icon(Icons.edit_note_rounded, color: Color(0xFF7A5AF9), size: 28),
        ],
      ),
    );
  }
}
