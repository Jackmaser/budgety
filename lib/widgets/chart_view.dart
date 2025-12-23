import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

enum ChartType { pie, bar, none }

class ChartView extends StatelessWidget {
  final List<Transaction> transactions;
  final ChartType selectedType;
  final Function(ChartType) onTypeChanged;
  final String periodTitle; // Neu: Zeigt z.B. "Dezember 2025"

  const ChartView({
    super.key,
    required this.transactions,
    required this.selectedType,
    required this.onTypeChanged,
    required this.periodTitle,
  });

  Map<String, double> get _groupedData {
    Map<String, double> data = {};
    for (var tx in transactions) {
      data.update(tx.category.name, (val) => val + tx.amount,
          ifAbsent: () => tx.amount);
    }
    return data;
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
                Expanded(
                  // Expanded sorgt dafür, dass langer Text nicht das Menü wegdrückt
                  child: Row(
                    children: [
                      Icon(
                        selectedType == ChartType.none
                            ? Icons.analytics_outlined
                            : Icons.analytics,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          selectedType == ChartType.none
                              ? 'Analyse (aus)'
                              : periodTitle,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<ChartType>(
                  tooltip: 'Typ ändern',
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: onTypeChanged,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ChartType.pie,
                      child: Row(children: [
                        Icon(Icons.pie_chart_outline, size: 20),
                        SizedBox(width: 10),
                        Text('Kuchen')
                      ]),
                    ),
                    const PopupMenuItem(
                      value: ChartType.bar,
                      child: Row(children: [
                        Icon(Icons.bar_chart_outlined, size: 20),
                        SizedBox(width: 10),
                        Text('Säulen')
                      ]),
                    ),
                    const PopupMenuItem(
                      value: ChartType.none,
                      child: Row(children: [
                        Icon(Icons.visibility_off_outlined, size: 20),
                        SizedBox(width: 10),
                        Text('Ausblenden')
                      ]),
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

  // (Die restlichen Funktionen _buildPieChart und _buildBarChart bleiben identisch zu vorher)
  Widget _buildPieChart() {
    final data = _groupedData;
    return PieChart(PieChartData(
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
    ));
  }

  Widget _buildBarChart() {
    final data = _groupedData;
    int index = 0;
    return BarChart(BarChartData(
      barGroups: data.entries.map((entry) {
        final category = transactions
            .firstWhere((t) => t.category.name == entry.key)
            .category;
        return BarChartGroupData(x: index++, barRods: [
          BarChartRodData(
              toY: entry.value,
              color: category.color,
              width: 14,
              borderRadius: BorderRadius.circular(4))
        ]);
      }).toList(),
      titlesData: const FlTitlesData(
          leftTitles: AxisTitles(),
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
          bottomTitles: AxisTitles()), // Vereinfacht für die Anzeige
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }
}
