import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:opt_app/library/opt_app.dart';

class LineChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final DateTimeRange dateRange;
  final bool showDetails;
  final bool showMultipleLines;

  const LineChartWidget({
    Key? key,
    required this.data,
    required this.dateRange,
    this.showDetails = false,
    this.showMultipleLines = false,
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
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.gray.shade200,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: AppColors.gray.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // Check if data is available to avoid index errors
                  if (data.isEmpty || value.toInt() >= data.length) {
                    return const Text('');
                  }
                  
                  final date = DateTime.tryParse(data[value.toInt()]['date']);
                  if (date == null) return const Text('');
                  
                  // Format based on date range duration
                  final difference = dateRange.duration.inDays;
                  if (difference <= 31) {
                    // Show day for shorter ranges
                    return Text(
                      DateFormat('d').format(date),
                      style: AppTypography().smallRegular,
                    );
                  } else {
                    // Show month for longer ranges
                    return Text(
                      DateFormat('MMM').format(date),
                      style: AppTypography().smallRegular,
                    );
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: AppTypography().smallRegular,
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.gray.shade200),
          ),
          minX: 0,
          maxX: data.length.toDouble() - 1,
          minY: 0,
          maxY: _getMaxY(),
          lineBarsData: _getLineBarsData(),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              // Remove the tooltip background color property altogether
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.x.toInt();
                  if (index >= data.length) return null;
                  
                  final date = DateTime.tryParse(data[index]['date']);
                  if (date == null) return null;
                  
                  final formattedDate = DateFormat('MMM d, yyyy').format(date);
                  final value = barSpot.y.toInt().toString();
                  
                  return LineTooltipItem(
                    '$formattedDate\n$value diagnoses',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 10;
    
    if (showMultipleLines) {
      double maxValue = 0;
      for (var item in data) {
        // Check all possible diagnosis count fields
        for (var key in item.keys) {
          if (key != 'date' && item[key] is num) {
            maxValue = max(maxValue, (item[key] as num).toDouble());
          }
        }
      }
      return maxValue + 1;
    } else {
      double maxValue = 0;
      for (var item in data) {
        maxValue = max(maxValue, (item['count'] as num).toDouble());
      }
      return maxValue + 1;
    }
  }

  List<LineChartBarData> _getLineBarsData() {
    if (data.isEmpty) {
      return [
        LineChartBarData(
          spots: [const FlSpot(0, 0), const FlSpot(1, 0)],
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.1),
          ),
        )
      ];
    }

    if (showMultipleLines) {
      // Create multiple lines for different diagnoses
      final Map<String, List<FlSpot>> diagnosisSpots = {};
      final List<Color> colors = [
        AppColors.primary,
        Colors.orange,
        Colors.green,
        Colors.purple,
        Colors.teal,
      ];
      
      // First, identify all diagnosis types
      final Set<String> diagnosisTypes = {};
      for (var item in data) {
        for (var key in item.keys) {
          if (key != 'date' && item[key] is num) {
            diagnosisTypes.add(key);
          }
        }
      }
      
      // Create spots for each diagnosis type
      for (var type in diagnosisTypes) {
        diagnosisSpots[type] = [];
        for (int i = 0; i < data.length; i++) {
          if (data[i].containsKey(type) && data[i][type] is num) {
            diagnosisSpots[type]!.add(FlSpot(i.toDouble(), data[i][type].toDouble()));
          }
        }
      }
      
      // Convert to LineChartBarData list
      List<LineChartBarData> result = [];
      int colorIndex = 0;
      
      diagnosisTypes.forEach((type) {
        if (diagnosisSpots[type]!.isNotEmpty) {
          result.add(
            LineChartBarData(
              spots: diagnosisSpots[type]!,
              isCurved: true,
              color: colors[colorIndex % colors.length],
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: colors[colorIndex % colors.length].withOpacity(0.1),
              ),
            ),
          );
          colorIndex++;
        }
      });
      
      return result;
    } else {
      // Single line for total count
      return [
        LineChartBarData(
          spots: List.generate(data.length, (index) {
            return FlSpot(index.toDouble(), data[index]['count'].toDouble());
          }),
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: showDetails),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.1),
          ),
        )
      ];
    }
  }

  double max(double a, double b) {
    return a > b ? a : b;
  }
}