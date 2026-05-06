import '../domain/analytics_model.dart';
import '../domain/analytics_repository.dart';
import 'analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remoteDataSource;

  AnalyticsRepositoryImpl(this._remoteDataSource);

  @override
  Future<RevenueData> getRevenueData() async {
    final response = await _remoteDataSource.getRevenue();
    return RevenueData.fromJson(response['data']);
  }

  @override
  Future<SalesSummary> getSalesSummary() async {
    final response = await _remoteDataSource.getSalesSummary();
    return SalesSummary.fromJson(response['data']);
  }

  @override
  Future<List<HourlyGrowth>> getHourlyGrowth() async {
    final response = await _remoteDataSource.getHourlyGrowth();
    final dynamic rawData = response['data'];
    if (rawData is! List) return [];
    return rawData.map((e) => HourlyGrowth.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<LocationSales>> getCountrySalesFlow() async {
    final response = await _remoteDataSource.getCountries();
    final dynamic rawData = response['data'];
    if (rawData is! List) return [];
    return rawData.map((e) => LocationSales.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<LocationSales>> getLocationChildren(String parentId, int page, int limit) async {
    // Determine whether the parentId implies fetching states or cities.
    // For simplicity, we assume if it has no underscores, it's a country code -> fetch states.
    // If it has underscores or specifies state -> fetch cities. 
    // The API doc says: GET /api/dashboard/states/:country and GET /api/dashboard/cities/:state?page=1&limit=50
    
    // We can use a simple heuristic or parameterize this better, but let's stick to the interface.
    Map<String, dynamic> response;
    
    if (page == 0) {
      // It's requesting states for a country
      response = await _remoteDataSource.getStates(parentId);
    } else {
      // It's requesting cities for a state with pagination
      response = await _remoteDataSource.getCities(parentId, page, limit);
    }
    
    final dynamic rawData = response['data'];
    final List<dynamic> dataList;
    
    if (rawData is Map && rawData.containsKey('data')) {
      // It's a paginated response (Cities)
      dataList = rawData['data'] as List<dynamic>;
    } else if (rawData is List) {
      // It's a direct list (States)
      dataList = rawData;
    } else {
      dataList = [];
    }
    
    return dataList.map((e) => LocationSales.fromJson(e as Map<String, dynamic>)).toList();
  }
}
