import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

enum ChartType { pie, bar, none }

class ChartView extends StatelessWidget {
  final List<Transaction> transactions;
  final ChartType selectedType;
  final Function(ChartType) onTypeChanged;
  final String periodTitle;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool showArrows;

  const ChartView({
    super.key,
    required this.transactions,
    required this.selectedType,
    required this.onTypeChanged,
    required this.periodTitle,
    required this.onPrevious,
    required this.onNext,
    required this.showArrows,
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Navigationszeile (Immer sichtbar)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Linker Pfeil
                if (showArrows)
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: onPrevious,
                  )
                else
                  const SizedBox(width: 48),

                // Zeitraum-Titel (Immer der Zeitraum, kein "Analyse" mehr)
                Expanded(
                  child: Text(
                    periodTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                // Rechter Pfeil & Auswahlmenü mit Icons
                Row(
                  children: [
                    if (showArrows)
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: onNext,
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
              ],
            ),

            // Diagramm-Bereich (Nur sichtbar, wenn nicht ausgeblendet)
            if (selectedType != ChartType.none)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: transactions.isNotEmpty
                    ? SizedBox(
                        height: 150,
                        child: selectedType == ChartType.pie
                            ? _buildPieChart()
                            : _buildBarChart(),
                      )
                    : const SizedBox(
                        height: 50,
                        child: Center(
                          child: Text(
                            'Keine Daten vorhanden',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }

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
        return BarChartGroupData(
          x: index++,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color: category.color,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        );
      }).toList(),
      titlesData: const FlTitlesData(
        leftTitles: AxisTitles(),
        rightTitles: AxisTitles(),
        topTitles: AxisTitles(),
        bottomTitles: AxisTitles(),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }
}
