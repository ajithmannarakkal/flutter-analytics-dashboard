import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/error_handler.dart';
import '../../domain/analytics_model.dart';
import '../analytics_provider.dart';

/// A paginated list of cities for a specific state.
/// Handles lazy loading and pagination state locally.
class CityDrillDownList extends ConsumerStatefulWidget {
  final String stateId;
  const CityDrillDownList({super.key, required this.stateId});

  @override
  ConsumerState<CityDrillDownList> createState() => _CityDrillDownListState();
}

class _CityDrillDownListState extends ConsumerState<CityDrillDownList> {
  int _page = 1;
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
        setState(() => _isLoadingMore = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.getMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _isLoadingMore) {
      return const _LoadingSpinner();
    }

    if (_items.isEmpty && !_isLoadingMore) {
      return const _EmptyPlaceholder(message: 'No city data available');
    }

    return Column(
      children: [
        ..._items.map((item) => _CityListItem(item: item)),
        if (_hasMore) _LoadMoreButton(onPressed: _fetchMore, isLoading: _isLoadingMore),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CityListItem extends StatelessWidget {
  final LocationSales item;
  const _CityListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48.0, right: 24.0, top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item.name, 
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Text(
            '\$${item.totalSales.toStringAsFixed(0)}', 
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  const _LoadMoreButton({required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Load More Cities', style: TextStyle(fontSize: 12)),
      ),
    );
  }
}

class _LoadingSpinner extends StatelessWidget {
  const _LoadingSpinner();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
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
      child: Text(
        message, 
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
