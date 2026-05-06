import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/error_handler.dart';
import '../../domain/analytics_model.dart';
import '../analytics_provider.dart';
import 'city_drill_down_list.dart';

/// A list of states for a specific country.
/// Acts as the second level of the 3-level sales drill-down.
class StateDrillDownList extends ConsumerWidget {
  final String countryId;
  const StateDrillDownList({super.key, required this.countryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // page 0 = fetch all states in our repository logic
    final statesAsync = ref.watch(
      locationChildrenProvider(LocationRequest(parentId: countryId, page: 0, limit: 100)),
    );

    return statesAsync.when(
      data: (states) {
        if (states.isEmpty) {
          return const _EmptyPlaceholder(message: 'No state data available');
        }
        return Column(
          children: states.map((state) => _StateExpansionTile(state: state)).toList(),
        );
      },
      loading: () => const _LoadingSpinner(),
      error: (e, st) => _ErrorLabel(message: ErrorHandler.getMessage(e)),
    );
  }
}

class _StateExpansionTile extends StatelessWidget {
  final LocationSales state;
  const _StateExpansionTile({required this.state});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Text(state.name, style: const TextStyle(fontSize: 14)),
      ),
      trailing: Text(
        '\$${state.totalSales.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      children: [
        CityDrillDownList(stateId: state.id),
      ],
    );
  }
}

class _LoadingSpinner extends StatelessWidget {
  const _LoadingSpinner();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  final String message;
  const _EmptyPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(message, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }
}

class _ErrorLabel extends StatelessWidget {
  final String message;
  const _ErrorLabel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        message, 
        style: const TextStyle(color: Colors.red, fontSize: 13),
      ),
    );
  }
}
