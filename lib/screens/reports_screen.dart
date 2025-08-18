import 'package:flutter/material.dart';
import '../services/ReportService.dart';
import '../interfaces/bussiness/report_interface.dart';
import 'dart:async';

class ReportsScreen extends StatefulWidget {
	const ReportsScreen({Key? key}) : super(key: key);

	@override
	State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
		List<ReportAccess>? accesses;
		bool loading = false;
		DateTime? _selectedDate;
		TimeOfDay? _selectedStartTime;
		TimeOfDay? _selectedEndTime;

	@override
	void initState() {
		super.initState();
		fetchAll();
	}

			Future<void> fetchAll() async {
				setState(() => loading = true);
				try {
					String? date = _selectedDate != null
							? "${_selectedDate!.year.toString().padLeft(4, '0')}-"
								"${_selectedDate!.month.toString().padLeft(2, '0')}-"
								"${_selectedDate!.day.toString().padLeft(2, '0')}"
							: null;
					String? startTime = _selectedStartTime != null
							? "${_selectedStartTime!.hour.toString().padLeft(2, '0')}:"
								"${_selectedStartTime!.minute.toString().padLeft(2, '0')}:00"
							: null;
					String? endTime = _selectedEndTime != null
							? "${_selectedEndTime!.hour.toString().padLeft(2, '0')}:"
								"${_selectedEndTime!.minute.toString().padLeft(2, '0')}:00"
							: null;
					accesses = await ReportService.getAccesses(
						date: date,
						startTime: startTime,
						endTime: endTime,
					);
				} catch (e) {
					accesses = null;
				}
				setState(() => loading = false);
			}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.white,
			body: Padding(
				padding: const EdgeInsets.all(20.0),
				child: Column(
					children: [
									Padding(
										padding: const EdgeInsets.all(8.0),
										child: Row(
											children: [
												Expanded(
													child: InkWell(
														onTap: () async {
															final picked = await showDatePicker(
																context: context,
																initialDate: _selectedDate ?? DateTime.now(),
																firstDate: DateTime(2020),
																lastDate: DateTime(2100),
															);
															if (picked != null) {
																setState(() => _selectedDate = picked);
															}
														},
														child: InputDecorator(
															decoration: InputDecoration(
																labelText: 'Fecha',
																prefixIcon: Icon(Icons.calendar_today),
															),
															child: Text(_selectedDate != null
																	? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
																	: 'Selecciona una fecha'),
														),
													),
												),
												const SizedBox(width: 16),
												Expanded(
													child: InkWell(
														onTap: () async {
															final picked = await showTimePicker(
																context: context,
																initialTime: _selectedStartTime ?? TimeOfDay(hour: 0, minute: 0),
															);
															if (picked != null) {
																setState(() => _selectedStartTime = picked);
															}
														},
														child: InputDecorator(
															decoration: InputDecoration(
																labelText: 'Hora inicio',
																prefixIcon: Icon(Icons.access_time),
															),
															child: Text(_selectedStartTime != null
																	? _selectedStartTime!.format(context)
																	: 'Selecciona hora inicio'),
														),
													),
												),
												const SizedBox(width: 16),
												Expanded(
													child: InkWell(
														onTap: () async {
															final picked = await showTimePicker(
																context: context,
																initialTime: _selectedEndTime ?? TimeOfDay(hour: 0, minute: 0),
															);
															if (picked != null) {
																setState(() => _selectedEndTime = picked);
															}
														},
														child: InputDecorator(
															decoration: InputDecoration(
																labelText: 'Hora fin',
																prefixIcon: Icon(Icons.access_time),
															),
															child: Text(_selectedEndTime != null
																	? _selectedEndTime!.format(context)
																	: 'Selecciona hora fin'),
														),
													),
												),
												const SizedBox(width: 16),
												ElevatedButton.icon(
													icon: Icon(Icons.refresh),
													label: Text('Filtrar'),
													style: ElevatedButton.styleFrom(
														backgroundColor: Color(0xFF7710D4),
														foregroundColor: Colors.white,
													),
													onPressed: fetchAll,
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
										: accesses == null
												? const Center(child: Text('No se pudieron cargar los accesos'))
												: Builder(
														builder: (context) {
																							final filtered = accesses!;
																							if (filtered.isEmpty) {
																								return const Center(child: Text('No hay accesos disponibles'));
																							}
																							return Column(
																								children: [
																									Container(
																										padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
																										child: Row(
																											children: const [
																												Expanded(child: Text('Usuario', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
																												Expanded(child: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
																												Expanded(child: Text('Hora Inicio', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
																												Expanded(child: Text('Hora Fin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
																												Expanded(child: Text('Acceso', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
																											],
																										),
																									),
																									const Divider(height: 1, color: Colors.deepPurpleAccent),
																									Expanded(
																										child: ListView.builder(
																											itemCount: filtered.length,
																											itemBuilder: (context, index) {
																												final a = filtered[index];
																												return Column(
																													children: [
																														Container(
																															padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
																															child: Row(
																																children: [
																																	Expanded(child: Text(a.userId.toString())),
																																	Expanded(child: Text(a.date)),
																																	Expanded(child: Text(a.startTime)),
																																	Expanded(child: Text(a.endTime)),
																																	Expanded(child: Icon(a.access ? Icons.check_circle : Icons.cancel, color: a.access ? Colors.green : Colors.red)),
																																],
																															),
																														),
																														const Divider(height: 1, color: Colors.deepPurpleAccent),
																													],
																												);
																											},
																										),
																									),
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
			),
		);
	}
}
