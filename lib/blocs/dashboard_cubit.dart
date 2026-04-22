import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dashboard_data.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/sales_repository.dart';

abstract class DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData data;

  DashboardLoaded(this.data);
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}

class DashboardCubit extends Cubit<DashboardState> {
  final SalesRepository _salesRepository;
  final InventoryRepository _inventoryRepository;

  DashboardCubit({
    SalesRepository? salesRepository,
    InventoryRepository? inventoryRepository,
  }) : _salesRepository = salesRepository ?? SalesRepository(),
       _inventoryRepository = inventoryRepository ?? InventoryRepository(),
       super(DashboardLoading());

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());

    try {
      final salesHistory = await _salesRepository.fetchSalesHistory();
      final saleItems = await _salesRepository.fetchSaleItems();
      final products = await _inventoryRepository.fetchProducts();

      final purchasePriceById = <String, double>{};
      int inStock = 0;
      int lowStock = 0;

      for (final product in products) {
        final productId = product['id']?.toString() ?? '';
        purchasePriceById[productId] = _toDouble(product['purchase']);

        final stock = _toInt(product['stock']);
        if (stock > 0) {
          inStock += 1;
        }
        if (stock > 0 && stock <= 20) {
          lowStock += 1;
        }
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final currentStart = today.subtract(const Duration(days: 29));
      final previousStart = currentStart.subtract(const Duration(days: 30));

      double currentSales = 0;
      double previousSales = 0;
      final salesByDay = <DateTime, double>{};

      for (int i = 0; i < 30; i++) {
        final day = currentStart.add(Duration(days: i));
        salesByDay[day] = 0;
      }

      for (final sale in salesHistory) {
        final createdAt = DateTime.tryParse(sale['createdAt']?.toString() ?? '');
        if (createdAt == null) {
          continue;
        }

        final localTime = createdAt.toLocal();
        final saleDay = DateTime(localTime.year, localTime.month, localTime.day);
        final total = _toDouble(sale['total']);

        if (!saleDay.isBefore(currentStart) && !saleDay.isAfter(today)) {
          currentSales += total;
          salesByDay[saleDay] = (salesByDay[saleDay] ?? 0) + total;
        } else if (!saleDay.isBefore(previousStart) &&
            saleDay.isBefore(currentStart)) {
          previousSales += total;
        }
      }

      double currentProfit = 0;
      double previousProfit = 0;
      final unitsSoldByProduct = <String, int>{};

      for (final item in saleItems) {
        final createdAt = DateTime.tryParse(item['createdAt']?.toString() ?? '');
        if (createdAt == null) {
          continue;
        }

        final localTime = createdAt.toLocal();
        final itemDay = DateTime(localTime.year, localTime.month, localTime.day);
        final productId = item['productId']?.toString() ?? '';
        final quantity = _toInt(item['quantity']);
        final lineTotal = _toDouble(item['lineTotal']);
        final purchasePrice = purchasePriceById[productId] ?? 0;
        final profit = lineTotal - (purchasePrice * quantity);

        if (!itemDay.isBefore(currentStart) && !itemDay.isAfter(today)) {
          currentProfit += profit;
          final productName = _displayProductName(item);
          unitsSoldByProduct[productName] =
              (unitsSoldByProduct[productName] ?? 0) + quantity;
        } else if (!itemDay.isBefore(previousStart) &&
            itemDay.isBefore(currentStart)) {
          previousProfit += profit;
        }
      }

      final salesTrend = salesByDay.entries
          .map(
            (entry) => DailySalesPoint(
              date: entry.key,
              sales: entry.value,
            ),
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      final topSellingItems = unitsSoldByProduct.entries
          .map(
            (entry) => TopSellingItem(
              name: entry.key,
              unitsSold: entry.value,
            ),
          )
          .toList()
        ..sort((a, b) => b.unitsSold.compareTo(a.unitsSold));

      emit(
        DashboardLoaded(
          DashboardData(
            totalSales: currentSales,
            salesGrowth: _formatGrowth(currentSales, previousSales),
            totalProfit: currentProfit,
            profitGrowth: _formatGrowth(currentProfit, previousProfit),
            profitMargin: currentSales <= 0 ? 0 : (currentProfit / currentSales) * 100,
            inStock: inStock,
            lowStock: lowStock,
            salesTrend: salesTrend,
            topSellingItems: topSellingItems.take(5).toList(),
          ),
        ),
      );
    } catch (e) {
      emit(DashboardError('Failed to fetch dashboard data: $e'));
    }
  }

  String _displayProductName(Map<String, dynamic> item) {
    final productName = item['productName']?.toString().trim() ?? '';
    if (productName.isNotEmpty) {
      return productName;
    }

    final sku = item['sku']?.toString().trim() ?? '';
    if (sku.isNotEmpty) {
      return sku;
    }

    return 'Unnamed Product';
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatGrowth(double current, double previous) {
    if (previous <= 0) {
      if (current <= 0) {
        return '0.0%';
      }
      return '+100.0%';
    }

    final change = ((current - previous) / previous) * 100;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}%';
  }
}
