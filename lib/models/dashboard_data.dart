class DashboardData {
  final double totalSales;
  final String salesGrowth;
  final double totalProfit;
  final String profitGrowth;
  final double profitMargin;
  final int inStock;
  final int lowStock;
  final List<DailySalesPoint> salesTrend;
  final List<TopSellingItem> topSellingItems;

  const DashboardData({
    required this.totalSales,
    required this.salesGrowth,
    required this.totalProfit,
    required this.profitGrowth,
    required this.profitMargin,
    required this.inStock,
    required this.lowStock,
    required this.salesTrend,
    required this.topSellingItems,
  });
}

class DailySalesPoint {
  final DateTime date;
  final double sales;

  const DailySalesPoint({
    required this.date,
    required this.sales,
  });
}

class TopSellingItem {
  final String name;
  final int unitsSold;

  const TopSellingItem({
    required this.name,
    required this.unitsSold,
  });
}
