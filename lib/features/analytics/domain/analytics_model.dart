import 'package:equatable/equatable.dart';

class RevenueData extends Equatable {
  final double totalRevenue;
  final double percentageChange;

  const RevenueData({required this.totalRevenue, required this.percentageChange});

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      percentageChange: (json['percentageChange'] as num).toDouble(),
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
      successful: json['successful'] as int,
      cancelled: json['cancelled'] as int,
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
      hour: json['hour'] as int,
      amount: (json['amount'] as num).toDouble(),
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
    return LocationSales(
      id: json['id'] as String? ?? json['name'] as String, // Fallback if id is missing
      name: json['name'] as String,
      totalSales: (json['totalSales'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name, totalSales, children];
}
