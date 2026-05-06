import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/analytics_model.dart';
import '../domain/analytics_repository.dart';
import '../data/mock_analytics_repository.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return MockAnalyticsRepository();
});

final revenueProvider = FutureProvider.autoDispose<RevenueData>((ref) {
  return ref.watch(analyticsRepositoryProvider).getRevenueData();
});

final salesSummaryProvider = FutureProvider.autoDispose<SalesSummary>((ref) {
  return ref.watch(analyticsRepositoryProvider).getSalesSummary();
});

final hourlyGrowthProvider = FutureProvider.autoDispose<List<HourlyGrowth>>((ref) {
  return ref.watch(analyticsRepositoryProvider).getHourlyGrowth();
});

final countrySalesProvider = FutureProvider.autoDispose<List<LocationSales>>((ref) {
  return ref.watch(analyticsRepositoryProvider).getCountrySalesFlow();
});

// For drill-down lazy loading
final locationChildrenProvider = FutureProvider.family.autoDispose<List<LocationSales>, LocationRequest>((ref, request) {
  return ref.watch(analyticsRepositoryProvider).getLocationChildren(request.parentId, request.page, request.limit);
});

class LocationRequest {
  final String parentId;
  final int page;
  final int limit;

  const LocationRequest({required this.parentId, required this.page, required this.limit});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationRequest &&
          runtimeType == other.runtimeType &&
          parentId == other.parentId &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode => parentId.hashCode ^ page.hashCode ^ limit.hashCode;
}
