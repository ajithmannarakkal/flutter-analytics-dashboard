import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_analytics_dashboard/core/network/api_exception.dart';
import '../analytics_provider.dart';
import '../../domain/analytics_model.dart';

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
              'Country-wise Sales Flow',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            countryAsync.when(
              data: (countries) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: countries.length,
                  separatorBuilder: (context, index) => const Divider(),
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
                        _StateDrillDownList(countryId: country.id),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateDrillDownList extends ConsumerWidget {
  final String countryId;
  const _StateDrillDownList({required this.countryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // page 0 = fetch states in our current repository logic
    final statesAsync = ref.watch(locationChildrenProvider(LocationRequest(parentId: countryId, page: 0, limit: 100)));

    return statesAsync.when(
      data: (states) {
        if (states.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No state data available', style: TextStyle(color: Colors.grey, fontSize: 12)),
          );
        }
        return Column(
          children: states.map((state) => ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(state.name, style: const TextStyle(fontSize: 14)),
            ),
            trailing: Text(
              '\$${state.totalSales.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 13),
            ),
            children: [
              _CityDrillDownList(stateId: state.id),
            ],
          )).toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (e, st) {
        String errorMessage = e.toString();
        if (e is ApiException) {
          errorMessage = e.message;
        } else if (e is DioException && e.error is ApiException) {
          errorMessage = (e.error as ApiException).message;
        } else if (e is DioException) {
          errorMessage = 'API Error: ${e.response?.statusCode ?? 'Unknown'}';
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 13)),
        );
      },
    );
  }
}

class _CityDrillDownList extends ConsumerStatefulWidget {
  final String stateId;
  const _CityDrillDownList({required this.stateId});

  @override
  ConsumerState<_CityDrillDownList> createState() => _CityDrillDownListState();
}

class _CityDrillDownListState extends ConsumerState<_CityDrillDownList> {
  int _page = 1; // Cities start from page 1 in our repository logic
  final int _limit = 5;
  final List<LocationSales> _items = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchMore();
  }

  Future<void> _fetchMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final request = LocationRequest(parentId: widget.stateId, page: _page, limit: _limit);
      final newItems = await ref.read(locationChildrenProvider(request).future);
      
      if (mounted) {
        setState(() {
          _page++;
          _items.addAll(newItems);
          if (newItems.length < _limit) _hasMore = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e is ApiException) {
          errorMessage = e.message;
        } else if (e is DioException && e.error is ApiException) {
          errorMessage = (e.error as ApiException).message;
        }
        // For cities we might just show a small error text
        setState(() {
          _isLoadingMore = false;
          // Optionally show a snackbar or log
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    if (_items.isEmpty && !_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No city data available', style: TextStyle(color: Colors.grey, fontSize: 12)),
      );
    }

    return Column(
      children: [
        ..._items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 48.0, right: 24.0, top: 8.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item.name, style: const TextStyle(color: Colors.grey, fontSize: 13))),
                  Text('\$${item.totalSales.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13)),
                ],
              ),
            )),
        if (_hasMore)
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: TextButton(
              onPressed: _isLoadingMore ? null : _fetchMore,
              child: _isLoadingMore
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Load More Cities', style: TextStyle(fontSize: 12)),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
