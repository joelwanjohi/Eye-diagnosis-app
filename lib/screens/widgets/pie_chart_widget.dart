import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class PieChartWidget extends StatefulWidget {
  final List<({String name, int count})> data;
  final String title;
  final String subtitle;

  const PieChartWidget({
    Key? key,
    required this.data,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Sort data by count (descending)
    final sortedData = List<({String name, int count})>.from(widget.data)
      ..sort((a, b) => b.count.compareTo(a.count));

    // Calculate total
    final total = sortedData.fold<int>(0, (sum, item) => sum + item.count);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            sortedData.isEmpty
                ? SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'No data available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection == null) {
                                      touchedIndex = -1;
                                      return;
                                    }
                                    touchedIndex =
                                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: _generateSections(sortedData, total),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildLegend(sortedData, total),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateSections(
      List<({String name, int count})> data, int total) {
    return List.generate(data.length, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;
      final double percentage = total > 0 ? (data[i].count / total * 100).toDouble() : 0.0;

      return PieChartSectionData(
        color: AppConstants.chartColors[i % AppConstants.chartColors.length],
        value: percentage, // Now this is explicitly a double
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLegend(List<({String name, int count})> data, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        data.length > 5 ? 5 : data.length,
        (index) {
          final item = data[index];
          final double percentage = total > 0 ? (item.count / total * 100).toDouble() : 0.0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(3),
                    color: AppConstants.chartColors[index % AppConstants.chartColors.length],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      )..add(
        data.length > 5
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'And ${data.length - 5} more...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}