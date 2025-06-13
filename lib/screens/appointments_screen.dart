import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WeeklyCalendar(),
          const SizedBox(height: 24),
          const Text(
            'Recordatorios',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          _ReminderCard(),
        ],
      ),
    );
  }
}

class _WeeklyCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7E0F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('Sun'), Text('Mon'), Text('Tu'),
              Text('Wed'), Text('Thu'), Text('Fri'), Text('Sa'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayCircle(text: '1', selected: false),
              _DayCircle(text: '2', selected: true),
              _DayCircle(text: '3', selected: false),
              _DayCircle(text: '4', selected: false),
              _DayCircle(text: '5', selected: false),
              _DayCircle(text: '6', selected: false),
              _DayCircle(text: '7', selected: false, isAdd: true),
            ],
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Día seleccionado:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Cierra gimnasio\nCita con el entrenador',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final String text;
  final bool selected;
  final bool isAdd;

  const _DayCircle({
    required this.text,
    this.selected = false,
    this.isAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: selected ? Colors.deepPurple : Colors.white,
      child: Text(
        isAdd ? '+' : text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7E0F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('Recordatorio del día'),
          CircleAvatar(
            radius: 12,
            backgroundColor: Color.fromRGBO(127, 17, 224, 1),
            child: Icon(Icons.info_outline, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}
