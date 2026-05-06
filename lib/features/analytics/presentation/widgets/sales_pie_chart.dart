import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../analytics_provider.dart';

class SalesPieChart extends ConsumerStatefulWidget {
  const SalesPieChart({super.key});

  @override
  ConsumerState<SalesPieChart> createState() => _SalesPieChartState();
}

class _SalesPieChartState extends ConsumerState<SalesPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesSummaryProvider);
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales Analysis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.pie_chart_outline, color: theme.colorScheme.primary.withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 220,
              child: salesAsync.when(
                data: (data) {
                  final total = data.successful + data.cancelled;
                  if (total == 0) return const Center(child: Text('No sales data'));
                  
                  final successRate = (data.successful / total * 100).toStringAsFixed(1);
                  
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 4,
                          centerSpaceRadius: 65,
                          sections: [
                            _buildSection(
                              index: 0,
                              value: data.successful.toDouble(),
                              title: '${(data.successful / total * 100).toStringAsFixed(0)}%',
                              color: const Color(0xFF4CAF50),
                              theme: theme,
                            ),
                            _buildSection(
                              index: 1,
                              value: data.cancelled.toDouble(),
                              title: '${(data.cancelled / total * 100).toStringAsFixed(0)}%',
                              color: const Color(0xFFE57373),
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$successRate%',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                          Text(
                            'Success',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
            const SizedBox(height: 32),
            salesAsync.maybeWhen(
              data: (data) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LegendItem(
                    label: 'Successful',
                    value: '${data.successful}',
                    color: const Color(0xFF4CAF50),
                  ),
                  _LegendItem(
                    label: 'Cancelled',
                    value: '${data.cancelled}',
                    color: const Color(0xFFE57373),
                  ),
                ],
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildSection({
    required int index,
    required double value,
    required String title,
    required Color color,
    required ThemeData theme,
  }) {
    final isTouched = index == touchedIndex;
    final double radius = isTouched ? 35 : 30;
    final double fontSize = isTouched ? 16 : 13;

    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black26, blurRadius: isTouched ? 4 : 2)],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
