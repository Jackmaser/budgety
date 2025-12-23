import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../models/category.dart';

enum ChartType { pie, bar, none }

class ChartView extends StatelessWidget {
  final List<Transaction> transactions;
  final ChartType selectedType;
  final Function(ChartType) onTypeChanged;

  const ChartView({
    super.key,
    required this.transactions,
    required this.selectedType,
    required this.onTypeChanged,
  });

  Map<String, double> get _groupedData {
    Map<String, double> data = {};
    for (var tx in transactions) {
      data.update(tx.category.name, (val) => val + tx.amount,
          ifAbsent: () => tx.amount);
    }
    return data;
  }

  String get _chartTitle {
    switch (selectedType) {
      case ChartType.pie:
        return 'Kuchendiagramm';
      case ChartType.bar:
        return 'Säulendiagramm';
      case ChartType.none:
        return 'Analyse (aus)';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      selectedType == ChartType.none
                          ? Icons.analytics_outlined
                          : Icons.analytics,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _chartTitle,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                PopupMenuButton<ChartType>(
                  tooltip: 'Typ ändern',
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: onTypeChanged,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ChartType.pie,
                      child: Row(
                        children: [
                          Icon(Icons.pie_chart_outline, size: 20),
                          SizedBox(width: 10),
                          Text('Kuchen'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: ChartType.bar,
                      child: Row(
                        children: [
                          Icon(Icons.bar_chart_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Säulen'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: ChartType.none,
                      child: Row(
                        children: [
                          Icon(Icons.visibility_off_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Ausblenden'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (selectedType != ChartType.none)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: SizedBox(
                  height: 150,
                  child: selectedType == ChartType.pie
                      ? _buildPieChart()
                      : _buildBarChart(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final data = _groupedData;
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: data.entries.map((entry) {
          final category = transactions
              .firstWhere((t) => t.category.name == entry.key)
              .category;
          return PieChartSectionData(
            color: category.color,
            value: entry.value,
            title: '${entry.value.toStringAsFixed(0)}€',
            radius: 40,
            titleStyle: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart() {
    final data = _groupedData;
    int index = 0;
    return BarChart(
      BarChartData(
        barGroups: data.entries.map((entry) {
          final category = transactions
              .firstWhere((t) => t.category.name == entry.key)
              .category;
          return BarChartGroupData(
            x: index++,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: category.color,
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length)
                  return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    data.keys.elementAt(value.toInt()).substring(0, 3),
                    style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
