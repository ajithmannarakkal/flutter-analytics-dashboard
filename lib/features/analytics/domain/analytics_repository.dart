import 'analytics_model.dart';

abstract class AnalyticsRepository {
  Future<RevenueData> getRevenueData();
  Future<SalesSummary> getSalesSummary();
  Future<List<HourlyGrowth>> getHourlyGrowth();
  Future<List<LocationSales>> getCountrySalesFlow();
  // Pagination / Lazy loading for drill-down
  Future<List<LocationSales>> getLocationChildren(String parentId, int page, int limit);
}
