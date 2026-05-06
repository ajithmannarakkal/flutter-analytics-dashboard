import 'dart:math';
import '../domain/analytics_model.dart';
import '../domain/analytics_repository.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  final _random = Random();

  @override
  Future<RevenueData> getRevenueData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const RevenueData(totalRevenue: 124500.50, percentageChange: 12.5);
  }

  @override
  Future<SalesSummary> getSalesSummary() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const SalesSummary(successful: 850, cancelled: 150);
  }

  @override
  Future<List<HourlyGrowth>> getHourlyGrowth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(24, (index) {
      // Simulate a curve
      final base = 1000.0;
      final variance = _random.nextDouble() * 500;
      final trend = sin(index / 24 * pi) * 2000;
      return HourlyGrowth(hour: index, amount: base + variance + trend);
    });
  }

  @override
  Future<List<LocationSales>> getCountrySalesFlow() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const [
      LocationSales(id: 'US', name: 'United States', totalSales: 45000),
      LocationSales(id: 'UK', name: 'United Kingdom', totalSales: 32000),
      LocationSales(id: 'CA', name: 'Canada', totalSales: 28000),
      LocationSales(id: 'AU', name: 'Australia', totalSales: 15000),
      LocationSales(id: 'IN', name: 'India', totalSales: 22000),
    ];
  }

  @override
  Future<List<LocationSales>> getLocationChildren(String parentId, int page, int limit) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Simulate lazy loading child data
    return List.generate(limit, (index) {
      final itemIndex = (page * limit) + index;
      return LocationSales(
        id: '${parentId}_child_$itemIndex',
        name: '$parentId Region $itemIndex',
        totalSales: _random.nextDouble() * 5000,
      );
    });
  }
}
