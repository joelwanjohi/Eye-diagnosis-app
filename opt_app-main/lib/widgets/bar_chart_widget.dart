import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:opt_app/library/opt_app.dart';

class BarChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool showDetails;
  final bool isGrouped;

  const BarChartWidget({
    Key? key,
    required this.data,
    this.showDetails = false,
    this.isGrouped = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barGroups: _getBarGroups(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.gray.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= data.length) {
                    return const Text('');
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()]['label'],
                      style: AppTypography().smallRegular,
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return const Text('');
                  }
                  return Text(
                    value.toInt().toString(),
                    style: AppTypography().smallRegular,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: AppColors.gray.shade300, width: 1),
              left: BorderSide(color: AppColors.gray.shade300, width: 1),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: showDetails,
            touchTooltipData: BarTouchTooltipData(
              // Remove the tooltip background color property altogether
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (isGrouped) {
                  final subCategoryLabels = [
                    'Current',
                    'Previous',
                    'Target',
                  ];
                  
                  String label = group.x.toInt() < data.length
                      ? data[group.x.toInt()]['label']
                      : '';
                  String subLabel = rodIndex < subCategoryLabels.length
                      ? subCategoryLabels[rodIndex]
                      : '';
                  
                  return BarTooltipItem(
                    '$label - $subLabel\n${rod.toY.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  String label = group.x.toInt() < data.length
                      ? data[group.x.toInt()]['label']
                      : '';
                  String value = rod.toY.toInt().toString();
                  
                  return BarTooltipItem(
                    '$label\n$value diagnoses',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 10;
    
    double maxValue = 0;
    for (var item in data) {
      if (isGrouped) {
        // For grouped charts, check all possible sub-category values
        for (var key in item.keys) {
          if (key != 'label' && item[key] is num) {
            maxValue = max(maxValue, (item[key] as num).toDouble());
          }
        }
      } else {
        maxValue = max(maxValue, (item['value'] as num).toDouble());
      }
    }
    // Add some padding to the max value
    return maxValue * 1.2;
  }

  List<BarChartGroupData> _getBarGroups() {
    if (data.isEmpty) {
      return [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: 0,
              color: AppColors.primary,
              width: 22,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      ];
    }

    return List.generate(data.length, (index) {
      if (isGrouped) {
        // Multiple rods per group for grouped chart
        List<BarChartRodData> rods = [];
        final categories = ['current', 'previous', 'target'];
        final colors = [AppColors.primary, Colors.grey, Colors.amber];
        
        for (int i = 0; i < categories.length; i++) {
          if (data[index].containsKey(categories[i]) && data[index][categories[i]] is num) {
            rods.add(
              BarChartRodData(
                toY: data[index][categories[i]].toDouble(),
                color: colors[i],
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            );
          }
        }
        
        return BarChartGroupData(
          x: index,
          barRods: rods,
          showingTooltipIndicators: showDetails ? [0] : [],
        );
      } else {
        // Single rod per group for standard chart
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: data[index]['value'].toDouble(),
              color: data[index]['highlighted'] == true
                  ? Colors.orange
                  : AppColors.primary,
              width: 22,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
          showingTooltipIndicators: showDetails ? [0] : [],
        );
      }
    });
  }

  double max(double a, double b) {
    return a > b ? a : b;
  }
}