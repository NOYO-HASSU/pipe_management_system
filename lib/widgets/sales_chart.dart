import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../models/dashboard_data.dart';

class SalesTrendChart extends StatelessWidget {
  final DashboardData data;
  final String periodLabel;

  const SalesTrendChart({
    super.key,
    required this.data,
    this.periodLabel = 'Monthly',
  });

  @override
  Widget build(BuildContext context) {
    final points = data.salesTrend;
    final maxSales = points.isEmpty
        ? 0.0
        : points
              .map((point) => point.sales)
              .reduce((current, next) => current > next ? current : next);
    final chartMaxY = maxSales <= 0 ? 1.0 : maxSales * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$periodLabel Sales Trend",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  points.isEmpty
                      ? "No sales recorded for selected period"
                      : "$periodLabel performance tracking",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Row(children: [_buildLegendItem("Sales", AppColors.primaryDark)]),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
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
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      );

                      final index = value.toInt();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }

                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          _formatAxisDate(points[index].date),
                          style: style,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: points.isEmpty ? 1 : (points.length - 1).toDouble(),
              minY: 0,
              maxY: chartMaxY,
              lineBarsData: [
                LineChartBarData(
                  spots: points.isEmpty
                      ? const [FlSpot(0, 0)]
                      : List.generate(
                          points.length,
                          (index) =>
                              FlSpot(index.toDouble(), points[index].sales),
                        ),
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

  String _formatAxisDate(DateTime date) {
    const monthNames = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    final month = monthNames[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    return '$day $month';
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
  final List<TopSellingItem> items;

  const TopSellingPipes({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final maxUnits = items.isEmpty
        ? 1
        : items
              .map((item) => item.unitsSold)
              .reduce((current, next) => current > next ? current : next);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Top 5 Best-Selling Products",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Units sold in the last 30 days",
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
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    "No product sales yet.",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final percentage = maxUnits == 0
                        ? 0.0
                        : item.unitsSold / maxUnits;

                    return _buildProgressRow(
                      item.name,
                      "${item.unitsSold} Units",
                      percentage,
                      index < 2
                          ? AppColors.primaryDark
                          : const Color(0xFFC7D2FE),
                    );
                  }),
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
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
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
