class RevenueData {
  final double totalRevenue;
  final double percentageChange;

  const RevenueData({required this.totalRevenue, required this.percentageChange});
}

class SalesSummary {
  final int successful;
  final int cancelled;

  const SalesSummary({required this.successful, required this.cancelled});
}

class HourlyGrowth {
  final int hour;
  final double amount;

  const HourlyGrowth({required this.hour, required this.amount});
}

class LocationSales {
  final String id;
  final String name;
  final double totalSales;
  final List<LocationSales>? children; // For drill-down (state -> city)

  const LocationSales({
    required this.id,
    required this.name,
    required this.totalSales,
    this.children,
  });
}
