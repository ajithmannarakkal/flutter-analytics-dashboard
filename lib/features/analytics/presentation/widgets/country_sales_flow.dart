import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                      title: Text(country.name),
                      trailing: Text(
                        '\$${country.totalSales.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        _DrillDownList(parentId: country.id),
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

class _DrillDownList extends ConsumerStatefulWidget {
  final String parentId;

  const _DrillDownList({required this.parentId});

  @override
  ConsumerState<_DrillDownList> createState() => _DrillDownListState();
}

class _DrillDownListState extends ConsumerState<_DrillDownList> {
  int _page = 0;
  final int _limit = 3;
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
      final request = LocationRequest(parentId: widget.parentId, page: _page, limit: _limit);
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
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        ..._items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.name, style: const TextStyle(color: Colors.grey)),
                  Text('\$${item.totalSales.toStringAsFixed(0)}'),
                ],
              ),
            )),
        if (_hasMore)
          TextButton(
            onPressed: _isLoadingMore ? null : _fetchMore,
            child: _isLoadingMore
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Load More'),
          ),
      ],
    );
  }
}
