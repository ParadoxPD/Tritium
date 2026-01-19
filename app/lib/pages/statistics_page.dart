import 'dart:math';
import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final List<double> _data = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _addValue() {
    final val = double.tryParse(_controller.text);
    if (val != null) {
      setState(() => _data.add(val));
      _controller.clear();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _clearData() {
    setState(() {
      _data.clear();
      _controller.clear();
    });
  }

  void _removeAt(int index) {
    setState(() => _data.removeAt(index));
  }

  Map<String, String> _calculateStats() {
    if (_data.isEmpty) return {};

    double n = _data.length.toDouble();
    double sum = _data.reduce((a, b) => a + b);
    double sumSq = _data.map((e) => e * e).reduce((a, b) => a + b);
    double mean = sum / n;

    double variance = 0;
    if (n > 1) {
      variance = (sumSq - (sum * sum) / n) / (n - 1);
    }
    double popVariance = (sumSq / n) - (mean * mean);

    double sampleSD = n > 1 ? sqrt(variance) : 0;
    double popSD = sqrt(popVariance);

    List<double> sorted = List.from(_data)..sort();
    double median;
    if (n % 2 == 0) {
      median = (sorted[(n / 2).toInt() - 1] + sorted[(n / 2).toInt()]) / 2;
    } else {
      median = sorted[(n / 2).toInt()];
    }

    return {
      'n': n.toStringAsFixed(0),
      'Σx': _format(sum),
      'Σx²': _format(sumSq),
      'x̄ (Mean)': _format(mean),
      'Med': _format(median),
      'σx': _format(popSD),
      'sx': _format(sampleSD),
      'min': _format(_data.reduce(min)),
      'max': _format(_data.reduce(max)),
    };
  }

  String _format(double val) {
    if (val.abs() >= 1000000 || (val.abs() < 0.0001 && val != 0)) {
      return val.toStringAsExponential(4);
    }
    return val.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final stats = _calculateStats();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('1-Variable Statistics'),
        backgroundColor: theme.surface,
        foregroundColor: theme.foreground,
        elevation: 0,
        actions: [
          if (_data.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: theme.error),
              onPressed: _clearData,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: Column(
        children: [
          // Input Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    style: TextStyle(color: theme.foreground, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Enter data value',
                      hintStyle: TextStyle(color: theme.muted),
                      filled: true,
                      fillColor: theme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.subtle),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => _addValue(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addValue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),

          // Data count indicator
          if (_data.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.background,
              child: Row(
                children: [
                  Icon(Icons.dataset, size: 16, color: theme.muted),
                  const SizedBox(width: 8),
                  Text(
                    '${_data.length} data point${_data.length == 1 ? '' : 's'}',
                    style: TextStyle(color: theme.muted, fontSize: 14),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: _data.isEmpty
                ? _buildEmptyState(theme)
                : Row(
                    children: [
                      // Data list
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: theme.subtle),
                            ),
                          ),
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(8),
                            itemCount: _data.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              return Card(
                                color: theme.surface,
                                elevation: 0,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: theme.subtle.withOpacity(0.5),
                                  ),
                                ),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  leading: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: theme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: theme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    _format(_data[index]),
                                    style: TextStyle(
                                      color: theme.foreground,
                                      fontFamily: 'monospace',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: theme.error,
                                    ),
                                    onPressed: () => _removeAt(index),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Results panel
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: theme.surface,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Text(
                                'Results',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.foreground,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...stats.entries.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.key,
                                        style: TextStyle(
                                          color: theme.muted,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.background,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: theme.subtle.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          e.value,
                                          style: TextStyle(
                                            color: theme.foreground,
                                            fontFamily: 'monospace',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(dynamic theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 80,
            color: theme.muted.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Data Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add values to see statistics',
            style: TextStyle(fontSize: 14, color: theme.muted.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}
