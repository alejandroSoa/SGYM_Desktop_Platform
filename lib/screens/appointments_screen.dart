import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reportes',
      debugShowCheckedModeBanner: false,
      home: const ReportesScreen(),
    );
  }
}

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2,
          ),
          itemBuilder: (context, index) {
            return _buildReporteCard('Reporte ${index + 1}');
          },
        ),
      ),
    );
  }

  Widget _buildReporteCard(String title) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFEBE9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: 5, color: Color(0xFF7A5AF8))
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: 3, color: Color(0xFF7A5AF8))
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(toY: 4, color: Color(0xFF7A5AF8))
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(toY: 2, color: Color(0xFF7A5AF8))
                  ]),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
