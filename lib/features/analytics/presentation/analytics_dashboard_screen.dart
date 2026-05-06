import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import 'widgets/revenue_widget.dart';
import 'widgets/sales_pie_chart.dart';
import 'widgets/hourly_growth_chart.dart';
import 'widgets/country_sales_flow.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            RevenueWidget(),
            SizedBox(height: 16),
            HourlyGrowthChart(),
            SizedBox(height: 16),
            SalesPieChart(),
            SizedBox(height: 16),
            CountrySalesFlow(),
          ],
        ),
      ),
    );
  }
}
