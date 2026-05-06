import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../analytics_provider.dart';
import 'state_drill_down_list.dart';

/// The entry point for the 3-level sales drill-down (Country -> State -> City).
/// Displays a list of countries that can be expanded to reveal states.
class CountrySalesFlow extends ConsumerWidget {
  const CountrySalesFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countryAsync = ref.watch(countrySalesProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Flow by Location',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            countryAsync.when(
              data: (countries) {
                if (countries.isEmpty) {
                  return const Center(child: Text('No country data found'));
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: countries.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final country = countries[index];
                    return ExpansionTile(
                      leading: const Icon(Icons.public, size: 20),
                      title: Text(country.name),
                      trailing: Text(
                        '\$${country.totalSales.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        StateDrillDownList(countryId: country.id),
                      ],
                    );
                  },
                );
              },
              loading: () => const _LoadingPlaceholder(),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
