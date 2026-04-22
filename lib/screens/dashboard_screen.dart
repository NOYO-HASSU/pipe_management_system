import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m/widgets/sales_chart.dart';
import '../blocs/dashboard_cubit.dart';
import '../core/colors.dart';
import '../core/responsive.dart';
import '../models/dashboard_data.dart';

enum DashboardRange { daily, weekly, monthly }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardRange _selectedRange = DashboardRange.monthly;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit()..loadDashboardData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardLoaded) {
              final transformedData = _transformForRange(
                state.data,
                _selectedRange,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Real-time inventory and sales metrics based on your recorded sales.",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      _RangeToggle(
                        selectedRange: _selectedRange,
                        onChanged: (range) {
                          setState(() {
                            _selectedRange = range;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Responsive(
                    mobile: _KpiGrid(
                      crossAxisCount: 1,
                      childAspectRatio: 2.4,
                      data: transformedData,
                    ),
                    tablet: _KpiGrid(
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      data: transformedData,
                    ),
                    desktop: _KpiGrid(
                      crossAxisCount: 4,
                      childAspectRatio: 1.7,
                      data: transformedData,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 340,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SalesTrendChart(
                            data: transformedData,
                            periodLabel: _labelForRange(_selectedRange),
                          ),
                        ),
                      ),
                      if (Responsive.isDesktop(context))
                        const SizedBox(width: 16),
                      if (Responsive.isDesktop(context))
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 340,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TopSellingPipes(
                              items: transformedData.topSellingItems,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }

            if (state is DashboardError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<DashboardCubit>().loadDashboardData(),
                    child: const Text('Retry'),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  DashboardData _transformForRange(DashboardData source, DashboardRange range) {
    final sortedTrend = List<DailySalesPoint>.from(source.salesTrend)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sortedTrend.isEmpty) {
      return source;
    }

    List<DailySalesPoint> trend;
    switch (range) {
      case DashboardRange.daily:
        trend = sortedTrend.length <= 7
            ? sortedTrend
            : sortedTrend.sublist(sortedTrend.length - 7);
        break;
      case DashboardRange.weekly:
        trend = _groupByWeek(sortedTrend);
        break;
      case DashboardRange.monthly:
        trend = _groupByMonth(sortedTrend);
        break;
    }

    final selectedSales = trend.fold<double>(
      0,
      (sum, point) => sum + point.sales,
    );
    final baseSales = source.totalSales <= 0 ? 1 : source.totalSales;
    final salesRatio = (selectedSales / baseSales).clamp(0.0, 10.0).toDouble();
    final adjustedProfit = source.totalProfit * salesRatio;
    final adjustedMargin = selectedSales <= 0
        ? 0.0
        : (adjustedProfit / selectedSales) * 100;
    final adjustedTopSelling =
        source.topSellingItems
            .map(
              (item) => TopSellingItem(
                name: item.name,
                unitsSold: (item.unitsSold * salesRatio).round(),
              ),
            )
            .toList()
          ..sort((a, b) => b.unitsSold.compareTo(a.unitsSold));

    return DashboardData(
      totalSales: selectedSales,
      salesGrowth: source.salesGrowth,
      totalProfit: adjustedProfit,
      profitGrowth: source.profitGrowth,
      profitMargin: adjustedMargin,
      inStock: source.inStock,
      lowStock: source.lowStock,
      salesTrend: trend,
      topSellingItems: adjustedTopSelling.take(5).toList(),
    );
  }

  List<DailySalesPoint> _groupByWeek(List<DailySalesPoint> points) {
    final map = <DateTime, double>{};
    for (final point in points) {
      final weekStart = point.date.subtract(
        Duration(days: point.date.weekday - 1),
      );
      final key = DateTime(weekStart.year, weekStart.month, weekStart.day);
      map[key] = (map[key] ?? 0) + point.sales;
    }

    final grouped =
        map.entries
            .map(
              (entry) => DailySalesPoint(date: entry.key, sales: entry.value),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return grouped;
  }

  List<DailySalesPoint> _groupByMonth(List<DailySalesPoint> points) {
    final map = <DateTime, double>{};
    for (final point in points) {
      final key = DateTime(point.date.year, point.date.month, 1);
      map[key] = (map[key] ?? 0) + point.sales;
    }

    final grouped =
        map.entries
            .map(
              (entry) => DailySalesPoint(date: entry.key, sales: entry.value),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return grouped;
  }

  String _labelForRange(DashboardRange range) {
    switch (range) {
      case DashboardRange.daily:
        return 'Daily';
      case DashboardRange.weekly:
        return 'Weekly';
      case DashboardRange.monthly:
        return 'Monthly';
    }
  }
}

class _RangeToggle extends StatelessWidget {
  final DashboardRange selectedRange;
  final ValueChanged<DashboardRange> onChanged;

  const _RangeToggle({required this.selectedRange, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton('Daily', DashboardRange.daily),
          _toggleButton('Weekly', DashboardRange.weekly),
          _toggleButton('Monthly', DashboardRange.monthly),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, DashboardRange value) {
    final isSelected = selectedRange == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final DashboardData data;

  const _KpiGrid({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        KpiCard(
          title: "TOTAL SALES",
          value: "RS ${_formatCurrency(data.totalSales)}",
          badge: data.salesGrowth,
          isPositive: !data.salesGrowth.startsWith('-'),
        ),
        KpiCard(
          title: "TOTAL PROFIT",
          value: "RS ${_formatCurrency(data.totalProfit)}",
          badge: data.profitGrowth,
          isPositive: !data.profitGrowth.startsWith('-'),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "PROFIT MARGIN",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${data.profitMargin.toStringAsFixed(1)} %",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        KpiCard(
          title: "IN STOCK",
          value: data.inStock.toString(),
          badge: "Low Stock (${data.lowStock})",
          isPositive: false,
          suffix: " SKUs",
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(0);
    return fixed.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String badge;
  final bool isPositive;
  final String suffix;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.badge,
    required this.isPositive,
    this.suffix = "",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: AppColors.primaryBlue,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.successGreen.withValues(alpha: 0.1)
                      : AppColors.warningYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isPositive
                        ? AppColors.successGreen
                        : AppColors.warningYellow,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (suffix.isNotEmpty)
                    Text(
                      suffix,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
