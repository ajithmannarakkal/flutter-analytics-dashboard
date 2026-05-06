import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';

class AnalyticsRemoteDataSource {
  final DioClient _dioClient;

  AnalyticsRemoteDataSource(this._dioClient);

  Future<Map<String, dynamic>> getRevenue() async {
    final response = await _dioClient.get(ApiConstants.revenue);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSalesSummary() async {
    final response = await _dioClient.get(ApiConstants.salesSummary);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getHourlyGrowth() async {
    final response = await _dioClient.get(ApiConstants.hourlyGrowth);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCountries() async {
    final response = await _dioClient.get(ApiConstants.countries);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStates(String country) async {
    final response = await _dioClient.get(ApiConstants.states(country));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCities(String state, int page, int limit) async {
    final response = await _dioClient.get(
      ApiConstants.cities(state),
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.data as Map<String, dynamic>;
  }
}
