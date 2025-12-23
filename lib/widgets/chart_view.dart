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

  // Hilfsfunktion: Gruppiert Beträge nach Kategorien
  Map<String, double> get _groupedData {
    Map<String, double> data = {};
    for (var tx in transactions) {
      data.update(tx.category.name, (val) => val + tx.amount,
          ifAbsent: () => tx.amount);
    }
    return data;
  }

  // Hilfsfunktion für den dynamischen Titel
  String get _chartTitle {
    switch (selectedType) {
      case ChartType.pie:
        return 'Kuchendiagramm';
      case ChartType.bar:
        return 'Säulendiagramm';
      case ChartType.none:
        return 'Analyse (ausgeblendet)';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER: Mit dynamischem Titel
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
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _chartTitle, // Dynamischer Titel
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                PopupMenuButton<ChartType>(
                  tooltip: 'Diagrammtyp ändern',
                  icon: const Icon(Icons.more_vert),
                  onSelected: onTypeChanged,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ChartType.pie,
                      child: Row(children: [
                        Icon(Icons.pie_chart_outline),
                        SizedBox(width: 8),
                        Text('Kuchen')
                      ]),
                    ),
                    const PopupMenuItem(
                      value: ChartType.bar,
                      child: Row(children: [
                        Icon(Icons.bar_chart_outlined),
                        SizedBox(width: 8),
                        Text('Säulen')
                      ]),
                    ),
                    const PopupMenuItem(
                      value: ChartType.none,
                      child: Row(children: [
                        Icon(Icons.visibility_off_outlined),
                        SizedBox(width: 8),
                        Text('Ausblenden')
                      ]),
                    ),
                  ],
                ),
              ],
            ),

            // INHALT: Erscheint nur, wenn nicht 'none' gewählt ist
            if (selectedType != ChartType.none)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: 200,
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
        centerSpaceRadius: 40,
        sections: data.entries.map((entry) {
          final category = transactions
              .firstWhere((t) => t.category.name == entry.key)
              .category;
          return PieChartSectionData(
            color: category.color,
            value: entry.value,
            title: '${entry.value.toStringAsFixed(0)}€',
            radius: 50,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
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
                width: 18,
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
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    data.keys.elementAt(value.toInt()).substring(0, 3),
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold),
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
