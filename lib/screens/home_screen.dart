import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel Admin',
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card de Reportes con UNA sola tabla
                  // ...en el Row principal...
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Reportes',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Gráfico de barras personalizado
                          Expanded(
                            child: _SimpleBarChart(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Card de Población con gráfica de barras (sin cambios)
                  Container(
                    width: 220,
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Población',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(child: _buildBarChartMock()),
                      ],
                    ),
                  ),
                ],
              ),
              
              // ...resto del código igual...
              const SizedBox(height: 20),
              // Rutinas y Dietas
              Row(
                children: [
                  // Rutinas
                  Expanded(
                    child: CategoryBox(
                      title: "Rutinas",
                      items: const [
                        {"title": "Pecho al fallo", "summary": "Pequeño resumen"},
                        {"title": "Puño limpio", "summary": "Pequeño resumen"},
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Dietas
                  Expanded(
                    child: CategoryBox(
                      title: "Dietas",
                      items: const [
                        {"title": "Greek Salad", "summary": "Pequeño resumen"},
                        {"title": "Avocado Toast", "summary": "Pequeño resumen"},
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Trabajadores
              const Text(
                "Mis trabajadores",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  WorkerCard(name: "El huicho", color: Color(0xFFEBE9FE)),
                  SizedBox(width: 8),
                  WorkerCard(name: "María de Todos LA.", color: Color(0xFFEBE9FE)),
                  SizedBox(width: 8),
                  WorkerCard(name: "Pedro Saldaño", color: Color(0xFFEBE9FE)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMPONENTES DE TABLAS Y GRÁFICA DE BARRAS ---
static Widget _buildTableMock() {
  return DataTable(
    columns: const [
      DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Valor', style: TextStyle(fontWeight: FontWeight.bold))),
    ],
    rows: const [
      DataRow(cells: [DataCell(Text('Ingresos')), DataCell(Text('\$1200'))]),
      DataRow(cells: [DataCell(Text('Egresos')), DataCell(Text('\$800'))]),
      DataRow(cells: [DataCell(Text('Miembros')), DataCell(Text('150'))]),
    ],
    headingRowColor: MaterialStatePropertyAll(Color(0xFFF3F3F3)),
    dataRowColor: MaterialStatePropertyAll(Colors.white),
    dividerThickness: 0.5,
    columnSpacing: 24,
    horizontalMargin: 0,
  );
}

  static Widget _buildBarChartMock() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(width: 24, height: 60,  color: Color(0xFFEBE9FE)), // Barra 1
        Container(width: 24, height: 80,  color: Color(0xFFD1C4E9)), // Barra 2
        Container(width: 24, height: 100, color: Color(0xFFB39DDB)), // Barra 3
        Container(width: 24, height: 120, color: Color(0xFF9575CD)), // Barra 4
        Container(width: 24, height: 140, color: Color(0xFF7E57C2)), // Barra 5
      ],
    );
  }
}

// --- COMPONENTES DE RUTINAS, DIETAS Y TRABAJADORES ---

class CategoryBox extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  const CategoryBox({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: items.map((item) {
              return Expanded(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 24, backgroundColor: Colors.grey),
                    const SizedBox(height: 4),
                    Text(item['title']!, style: const TextStyle(fontSize: 12)),
                    Text(item['summary']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class WorkerCard extends StatelessWidget {
  final String name;
  final Color color;
  const WorkerCard({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const CircleAvatar(radius: 36, backgroundColor: Colors.grey),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}


class _SimpleBarChart extends StatelessWidget {
  final List<_BarData> data = const [
    _BarData(label: 'Ingresos', value: 1200, color: Color(0xFF7A5AF8)),
    _BarData(label: 'Egresos', value: 800, color: Color(0xFF7A5AF8)),
    _BarData(label: 'Miembros', value: 150, color: Color(0xFF7A5AF8)),
  ];

  const _SimpleBarChart();

  @override
  Widget build(BuildContext context) {
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.map((bar) {
        final percent = bar.value / maxValue;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 32,
              height: 90 * percent,
              decoration: BoxDecoration(
                color: bar.color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Text(bar.label, style: const TextStyle(fontSize: 12)),
            Text('${bar.value}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        );
      }).toList(),
    );
  }
}

class _BarData {
  final String label;
  final int value;
  final Color color;
  const _BarData({required this.label, required this.value, required this.color});
}