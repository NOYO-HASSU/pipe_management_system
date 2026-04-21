import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/colors.dart';

class SalesTrendChart extends StatelessWidget {
  const SalesTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "30-Day Sales Trend",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Daily performance tracking",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildLegendItem("Sales", AppColors.primaryDark),
                const SizedBox(width: 12),
                _buildLegendItem("Forecast", Colors.grey.shade300),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade200, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      );
                      Widget text;
                      switch (value.toInt()) {
                        case 1:
                          text = const Text('01 AUG', style: style);
                          break;
                        case 4:
                          text = const Text('10 AUG', style: style);
                          break;
                        case 7:
                          text = const Text('20 AUG', style: style);
                          break;
                        case 10:
                          text = const Text('30 AUG', style: style);
                          break;
                        default:
                          text = const Text('', style: style);
                          break;
                      }
                      return SideTitleWidget(meta: meta, child: text);
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 11,
              minY: 0,
              maxY: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 1.5),
                    FlSpot(2, 1.3),
                    FlSpot(4, 2.5),
                    FlSpot(6, 1.8),
                    FlSpot(8, 4.5),
                    FlSpot(10, 2.8),
                    FlSpot(11, 1.5),
                  ],
                  isCurved: true,
                  color: AppColors.primaryDark,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class TopSellingPipes extends StatelessWidget {
  const TopSellingPipes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Top 5 Best-Selling Pipes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Volume by SKU category",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Icon(Icons.more_vert, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressRow(
                "PVC High Pressure 2\"",
                "1,240 Units",
                0.95,
                AppColors.primaryDark,
              ),
              _buildProgressRow(
                "Galvanized Steel 4\"",
                "980 Units",
                0.80,
                AppColors.primaryDark,
              ),
              _buildProgressRow(
                "HDPE Heavy Duty 6\"",
                "720 Units",
                0.60,
                const Color(0xFFC7D2FE),
              ),
              _buildProgressRow(
                "PPR Hot Water 1\"",
                "510 Units",
                0.40,
                const Color(0xFFE0E7FF),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(
    String title,
    String value,
    double percentage,
    Color barColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: AppColors.background,
            color: barColor,
          ),
        ),
      ],
    );
  }
}
