import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LineChartWidget extends StatelessWidget {
  final List<({String date, int count})> data;
  final String title;
  final String subtitle;

  const LineChartWidget({
    Key? key,
    required this.data,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort data by date
    final sortedData = List<({String date, int count})>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    final maxY = sortedData.isEmpty 
        ? 10.0 
        : (sortedData.map((e) => e.count).reduce((a, b) => a > b ? a : b) * 1.2).toDouble();

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: sortedData.isEmpty
                  ? Center(
                      child: Text(
                        'No data available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: _getDrawingLine,
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
                              interval: _calculateInterval(sortedData.length),
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= sortedData.length || value.toInt() < 0) {
                                  return const SizedBox.shrink();
                                }
                                
                                final date = sortedData[value.toInt()].date;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _formatDate(date),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: maxY / 5,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  value.toInt().toString(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        minX: 0,
                        maxX: (sortedData.length - 1).toDouble(),
                        minY: 0,
                        maxY: maxY,
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            // Remove the problematic background color parameter
                            tooltipRoundedRadius: 8,
                            tooltipBorder: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                final index = barSpot.x.toInt();
                                if (index >= 0 && index < sortedData.length) {
                                  final item = sortedData[index];
                                  return LineTooltipItem(
                                    '${item.date}\n${item.count} diagnoses',
                                    Theme.of(context).textTheme.bodySmall!,
                                  );
                                }
                                return null;
                              }).toList();
                            },
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(sortedData.length, (index) {
                              return FlSpot(
                                index.toDouble(),
                                sortedData[index].count.toDouble(),
                              );
                            }),
                            isCurved: true,
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.accentColor,
                              ],
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.3),
                                  AppTheme.accentColor.withOpacity(0.05),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static FlLine _getDrawingLine(double value) {
    return FlLine(
      color: AppTheme.textSecondaryColor.withOpacity(0.1),
      strokeWidth: 1,
      dashArray: [5, 5],
    );
  }

  double _calculateInterval(int dataLength) {
    if (dataLength <= 5) return 1;
    if (dataLength <= 10) return 2;
    if (dataLength <= 20) return 4;
    return (dataLength / 5).ceil().toDouble();
  }

  String _formatDate(String date) {
    // Handle different date formats
    if (date.contains('-')) {
      final parts = date.split('-');
      if (parts.length >= 2) {
        // For YYYY-MM or YYYY-MM-DD format
        if (parts[0].length == 4) {
          // Return just month for YYYY-MM
          if (parts.length == 2) return parts[1];
          // Return MM-DD for YYYY-MM-DD
          return '${parts[1]}-${parts[2]}';
        }
      }
    }
    return date; // Return as is if not matching expected format
  }
}