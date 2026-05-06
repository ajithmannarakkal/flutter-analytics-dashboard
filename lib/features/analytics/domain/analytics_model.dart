import 'package:equatable/equatable.dart';

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  if (value is Map) {
    return _parseDouble(value['value'] ?? value['amount'] ?? value['total'] ?? value['revenue']);
  }
  return 0.0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is Map) {
    return _parseInt(value['count'] ?? value['value'] ?? value['amount'] ?? value['total']);
  }
  return 0;
}

class RevenueData extends Equatable {
  final double totalRevenue;
  final double percentageChange;

  const RevenueData({required this.totalRevenue, required this.percentageChange});

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      totalRevenue: _parseDouble(json['totalRevenue'] ?? json['revenue'] ?? json['total']),
      percentageChange: _parseDouble(json['percentageChange'] ?? json['percentage'] ?? json['change']),
    );
  }

  @override
  List<Object?> get props => [totalRevenue, percentageChange];
}

class SalesSummary extends Equatable {
  final int successful;
  final int cancelled;

  const SalesSummary({required this.successful, required this.cancelled});

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      successful: _parseInt(json['successful'] ?? json['success']),
      cancelled: _parseInt(json['cancelled'] ?? json['cancel']),
    );
  }

  @override
  List<Object?> get props => [successful, cancelled];
}

class HourlyGrowth extends Equatable {
  final int hour;
  final double amount;

  const HourlyGrowth({required this.hour, required this.amount});

  factory HourlyGrowth.fromJson(Map<String, dynamic> json) {
    return HourlyGrowth(
      hour: _parseInt(json['hour'] ?? json['time']),
      amount: _parseDouble(json['amount'] ?? json['value'] ?? json['total']),
    );
  }

  @override
  List<Object?> get props => [hour, amount];
}

class LocationSales extends Equatable {
  final String id;
  final String name;
  final double totalSales;
  final List<LocationSales>? children; 

  const LocationSales({
    required this.id,
    required this.name,
    required this.totalSales,
    this.children,
  });

  factory LocationSales.fromJson(Map<String, dynamic> json) {
    // Try to find a name in common fields used by different levels of drill-down
    final name = json['city'] ?? 
                 json['state'] ?? 
                 json['country'] ?? 
                 json['name'] ?? 
                 json['location'] ?? 
                 json['label'];

    // Use name as the primary identifier for API calls as requested
    final id = name ?? 
               json['id'] ?? 
               json['code'] ?? 
               json['isoCode'] ?? 
               json['country_code'] ?? 
               json['state_code'];

    return LocationSales(
      id: id?.toString() ?? '',
      name: name?.toString() ?? 'Unknown',
      totalSales: _parseDouble(json['totalSales'] ?? json['sales'] ?? json['total'] ?? json['amount'] ?? json['value']),
    );
  }

  @override
  List<Object?> get props => [id, name, totalSales, children];
}
