import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m/widgets/sales_chart.dart';
import '../blocs/dashboard_cubit.dart';
import '../core/colors.dart';
import '../core/responsive.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
            } else if (state is DashboardLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Real-time inventory and sales metrics for Alpha Unit.",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Responsive KPI Grid
                  Responsive(
                    mobile: _KpiGrid(
                      crossAxisCount: 1,
                      childAspectRatio: 2.4,
                      data: state.data,
                    ),
                    tablet: _KpiGrid(
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      data: state.data,
                    ),
                    desktop: _KpiGrid(
                      crossAxisCount: 4,
                      childAspectRatio: 1.7,
                      data: state.data,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Charts Area
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
                          child:
                              const SalesTrendChart(), // <-- Replaced Text Placeholder
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
                            child:
                                const TopSellingPipes(), // <-- Replaced Text Placeholder
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }
            return const Text("Error loading data");
          },
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final Map<String, dynamic> data;

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
          value: "PKR ${data['totalSales']}",
          badge: data['salesGrowth'],
          isPositive: true,
        ),
        KpiCard(
          title: "TOTAL PROFIT",
          value: "PKR ${data['totalProfit']}",
          badge: data['profitGrowth'],
          isPositive: true,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(10),
          ), // Dark card from image
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
                "${data['profitMargin']} %",
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
          value: data['inStock'],
          badge: "Low Stock (${data['lowStock']})",
          isPositive: false,
          suffix: " SKUs",
        ),
      ],
    );
  }
}

// Reusable KPI Card
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
