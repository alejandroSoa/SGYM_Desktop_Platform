
import 'package:flutter/material.dart';

import '../services/StationService.dart';
import '../services/ProfileService.dart';

class StationsScreen extends StatefulWidget {
	@override
	_StationsScreenState createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
	List<Map<String, dynamic>> _stations = [];
	bool _loading = true;
		Map<String, dynamic?> _userStandby = {};
		Map<String, String> _userNames = {}; // token -> nombre

	@override
	void initState() {
		super.initState();
		_fetchStations();
	}

		Future<void> _fetchStations() async {
			setState(() => _loading = true);
			try {
				final stations = await StationService.getStationsStandby();
				_userStandby.clear();
				_userNames.clear();
				for (final st in stations) {
					final token = st['token'] ?? st['stationToken'] ?? st['station_token'];
					if (token != null) {
						final userObj = await StationService.getUserStandby(token);
						_userStandby[token] = userObj;
						final userId = userObj != null ? userObj['userId'] : null;
						if (userId != null) {
							try {
								final profile = await ProfileService.fetchProfileByUserId(userId);
								_userNames[token] = profile?.fullName ?? 'Usuario $userId';
							} catch (_) {
								_userNames[token] = 'Usuario $userId';
							}
						} else {
							_userNames[token] = '-';
						}
					}
				}
				setState(() {
					_stations = List<Map<String, dynamic>>.from(stations);
					_loading = false;
				});
			} catch (e) {
				setState(() => _loading = false);
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('Error al cargar estaciones: $e'), backgroundColor: Colors.red),
				);
			}
		}

	Future<void> _handleRelease(String token, bool access) async {
		final ok = await StationService.releaseStandby(token, access);
		if (ok) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text(access ? 'Acceso aprobado' : 'Acceso denegado'), backgroundColor: access ? Colors.green : Colors.red),
			);
			_fetchStations();
		} else {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Error al liberar estación'), backgroundColor: Colors.red),
			);
		}
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
										// Encabezado
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
											child: Row(
												   children: const [
													   Expanded(child: Text('Estación', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
													   Expanded(child: Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
													   Expanded(child: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
													   Expanded(child: Text('Usuario en espera', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple))),
													   SizedBox(width: 160), // espacio para botones
												   ],
											),
										),
										const Divider(height: 1, color: Colors.deepPurpleAccent),
										// Lista de estaciones
										Expanded(
											child: _stations.isEmpty
													? const Center(child: Text('No hay estaciones en standby'))
													: ListView.builder(
															itemCount: _stations.length,
															itemBuilder: (context, i) {
																final st = _stations[i];
																final token = st['token'] ?? st['stationToken'] ?? st['station_token'];
																   final nombre = st['stationId']?.toString() ?? 'Estación';
																   final user = _userStandby[token];
																   final userName = _userNames[token] ?? '-';
																   final location = st['location'] ?? '-';
																   final type = st['type'] ?? '-';
																   return Column(
																	   children: [
																		   Row(
																			   children: [
																				   Expanded(
																					   child: Padding(
																						   padding: const EdgeInsets.all(8.0),
																						   child: Text(nombre),
																					   ),
																				   ),
																				   Expanded(
																					   child: Padding(
																						   padding: const EdgeInsets.all(8.0),
																						   child: Text(location),
																					   ),
																				   ),
																				   Expanded(
																					   child: Padding(
																						   padding: const EdgeInsets.all(8.0),
																						   child: Text(type),
																					   ),
																				   ),
																				   Expanded(
																					   child: Padding(
																						   padding: const EdgeInsets.all(8.0),
																						   child: Text(userName),
																					   ),
																				   ),
																				   Row(
																					   children: [
																						   ElevatedButton.icon(
																							   icon: Icon(Icons.check, color: Colors.white),
																							   label: Text('Aprobar'),
																							   style: ElevatedButton.styleFrom(
																								   backgroundColor: Colors.green,
																								   foregroundColor: Colors.white,
																							   ),
																							   onPressed: user == null ? null : () => _handleRelease(token, true),
																						   ),
																						   const SizedBox(width: 8),
																						   ElevatedButton.icon(
																							   icon: Icon(Icons.close, color: Colors.white),
																							   label: Text('Denegar'),
																							   style: ElevatedButton.styleFrom(
																								   backgroundColor: Colors.red,
																								   foregroundColor: Colors.white,
																							   ),
																							   onPressed: user == null ? null : () => _handleRelease(token, false),
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
