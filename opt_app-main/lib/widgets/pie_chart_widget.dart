import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:opt_app/library/opt_app.dart';

class PieChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final bool showLegend;

  const PieChartWidget({
    Key? key,
    required this.data,
    this.showLegend = false,
  }) : super(key: key);

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  final List<Color> _colors = [
    AppColors.primary,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.amber,
    Colors.blue,
  ];

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
      child: Row(
        children: [
          Expanded(
            flex: 3,
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
                      touchedIndex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: _getSections(),
              ),
            ),
          ),
          if (widget.showLegend) ...[
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _getLegendItems(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    if (widget.data.isEmpty) {
      return [
        PieChartSectionData(
          color: AppColors.gray.shade300,
          value: 100,
          title: 'No data',
          radius: 50,
          titleStyle: AppTypography().smallMedium.copyWith(
                color: AppColors.black,
              ),
        )
      ];
    }

    return List.generate(widget.data.length, (index) {
      final isTouched = index == touchedIndex;
      final double radius = isTouched ? 60 : 50;
      final double value = widget.data[index]['value'].toDouble();

      // Format percentage for display
      final double percentage = (value / _calculateTotal()) * 100;
      String displayValue = percentage >= 10
          ? '${percentage.toStringAsFixed(0)}%'
          : '${percentage.toStringAsFixed(1)}%';

      return PieChartSectionData(
        color: _colors[index % _colors.length],
        value: value,
        title: displayValue,
        radius: radius,
        titleStyle: AppTypography().smallMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      );
    });
  }

  List<Widget> _getLegendItems() {
    if (widget.data.isEmpty) {
      return [
        Text('No data available', style: AppTypography().smallMedium),
      ];
    }

    return List.generate(
      widget.data.length,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _colors[index % _colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.data[index]['label'],
                style: AppTypography().smallMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal() {
    if (widget.data.isEmpty) return 1;
    double total = 0;
    for (var item in widget.data) {
      total += item['value'].toDouble();
    }
    return total > 0 ? total : 1; // Avoid division by zero
  }
}