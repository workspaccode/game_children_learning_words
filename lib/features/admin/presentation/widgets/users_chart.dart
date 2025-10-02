import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UsersChart extends StatelessWidget {

  const UsersChart({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final totalChildren = data['totalChildren'] as int;
    final totalParents = data['totalParents'] as int;
    final totalTeachers = data['totalTeachers'] as int;
    final total = totalChildren + totalParents + totalTeachers;

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: Colors.blue,
            value: totalChildren.toDouble(),
            title: '${((totalChildren / total) * 100).toStringAsFixed(1)}%',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.green,
            value: totalParents.toDouble(),
            title: '${((totalParents / total) * 100).toStringAsFixed(1)}%',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.purple,
            value: totalTeachers.toDouble(),
            title: '${((totalTeachers / total) * 100).toStringAsFixed(1)}%',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
