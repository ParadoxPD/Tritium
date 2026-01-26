import 'dart:math';
import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum StatMode { oneVar, twoVar }

enum RegressionType { linear, quadratic, exponential, power, logarithmic }

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data storage
  final List<double> _xData = [];
  final List<double> _yData = [];
  final List<int> _freq = [];

  // Controllers
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();
  final TextEditingController _freqController = TextEditingController();

  StatMode _mode = StatMode.oneVar;
  RegressionType _regType = RegressionType.linear;
  bool _useFrequency = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _reset();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _xController.dispose();
    _yController.dispose();
    _freqController.dispose();
    super.dispose();
  }

  void _addData() {
    final x = double.tryParse(_xController.text);
    if (x == null) return;

    final y = _mode == StatMode.twoVar
        ? double.tryParse(_yController.text)
        : null;

    final freq = _useFrequency ? int.tryParse(_freqController.text) ?? 1 : 1;

    if (_mode == StatMode.twoVar && y == null) return;

    setState(() {
      _xData.add(x);
      if (_mode == StatMode.twoVar) _yData.add(y!);
      _freq.add(freq);
    });

    _xController.clear();
    _yController.clear();
    _freqController.clear();
  }

  void _clearData() {
    setState(() {
      _xData.clear();
      _yData.clear();
      _freq.clear();
    });
  }

  void _removeAt(int index) {
    setState(() {
      _xData.removeAt(index);
      if (_mode == StatMode.twoVar) _yData.removeAt(index);
      _freq.removeAt(index);
    });
  }

  Map<String, double> _calculate1Var() {
    if (_xData.isEmpty) return {};

    double n = _useFrequency
        ? _freq.reduce((a, b) => a + b).toDouble()
        : _xData.length.toDouble();

    double sumX = 0, sumX2 = 0;
    for (int i = 0; i < _xData.length; i++) {
      final f = _useFrequency ? _freq[i] : 1;
      sumX += _xData[i] * f;
      sumX2 += _xData[i] * _xData[i] * f;
    }

    double mean = sumX / n;
    double variance = (sumX2 / n) - (mean * mean);
    double sampleVar = n > 1 ? (sumX2 - (sumX * sumX) / n) / (n - 1) : 0;

    final expandedData = <double>[];
    for (int i = 0; i < _xData.length; i++) {
      final f = _useFrequency ? _freq[i] : 1;
      for (int j = 0; j < f; j++) {
        expandedData.add(_xData[i]);
      }
    }
    expandedData.sort();

    double median;
    final len = expandedData.length;
    if (len % 2 == 0) {
      median = (expandedData[len ~/ 2 - 1] + expandedData[len ~/ 2]) / 2;
    } else {
      median = expandedData[len ~/ 2];
    }

    return {
      'n': n,
      'Σx': sumX,
      'Σx²': sumX2,
      'x̄': mean,
      'σx': sqrt(variance),
      'sx': sqrt(sampleVar),
      'Med': median,
      'minX': _xData.reduce(min),
      'maxX': _xData.reduce(max),
    };
  }

  Map<String, double> _calculate2Var() {
    if (_xData.isEmpty || _yData.isEmpty) return {};

    double n = _useFrequency
        ? _freq.reduce((a, b) => a + b).toDouble()
        : _xData.length.toDouble();

    double sumX = 0, sumY = 0, sumX2 = 0, sumY2 = 0, sumXY = 0;

    for (int i = 0; i < _xData.length; i++) {
      final f = _useFrequency ? _freq[i] : 1;
      sumX += _xData[i] * f;
      sumY += _yData[i] * f;
      sumX2 += _xData[i] * _xData[i] * f;
      sumY2 += _yData[i] * _yData[i] * f;
      sumXY += _xData[i] * _yData[i] * f;
    }

    double meanX = sumX / n;
    double meanY = sumY / n;

    // Regression coefficients (linear: y = a + bx)
    double b = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double a = meanY - b * meanX;

    // Correlation coefficient
    double r =
        (n * sumXY - sumX * sumY) /
        sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));

    return {
      'n': n,
      'Σx': sumX,
      'Σy': sumY,
      'Σx²': sumX2,
      'Σy²': sumY2,
      'Σxy': sumXY,
      'x̄': meanX,
      'ȳ': meanY,
      'σx': sqrt((sumX2 / n) - (meanX * meanX)),
      'σy': sqrt((sumY2 / n) - (meanY * meanY)),
      'a': a,
      'b': b,
      'r': r,
      'r²': r * r,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: theme.surface,
        foregroundColor: theme.foreground,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primary,
          labelColor: theme.primary,
          unselectedLabelColor: theme.muted,
          tabs: const [
            Tab(text: 'Data Entry'),
            Tab(text: 'Results'),
          ],
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.settings, color: theme.muted),
            color: theme.surface,
            itemBuilder: (context) => [
              PopupMenuItem(
                child: StatefulBuilder(
                  builder: (context, setState) => SwitchListTile(
                    title: Text(
                      'Frequency',
                      style: TextStyle(color: theme.foreground),
                    ),
                    value: _useFrequency,
                    activeColor: theme.primary,
                    onChanged: (val) {
                      setState(() => _useFrequency = val);
                      this.setState(() => _useFrequency = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_xData.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: theme.error),
              onPressed: _clearData,
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDataEntry(theme), _buildResults(theme)],
      ),
    );
  }

  Widget _buildDataEntry(dynamic theme) {
    return Column(
      children: [
        // Mode selector
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.surface,
          child: Row(
            children: [
              Text(
                'Mode:',
                style: TextStyle(
                  color: theme.foreground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SegmentedButton<StatMode>(
                  segments: const [
                    ButtonSegment(value: StatMode.oneVar, label: Text('1-VAR')),
                    ButtonSegment(value: StatMode.twoVar, label: Text('2-VAR')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (Set<StatMode> sel) {
                    setState(() {
                      _mode = sel.first;
                      _clearData();
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: theme.primary,
                    selectedForegroundColor: theme.background,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Input fields
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
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _xController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      style: TextStyle(color: theme.foreground),
                      decoration: InputDecoration(
                        labelText: _mode == StatMode.oneVar ? 'Value (x)' : 'X',
                        labelStyle: TextStyle(color: theme.primary),
                        filled: true,
                        fillColor: theme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onSubmitted: (_) => _addData(),
                    ),
                  ),
                  if (_mode == StatMode.twoVar) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _yController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        style: TextStyle(color: theme.foreground),
                        decoration: InputDecoration(
                          labelText: 'Y',
                          labelStyle: TextStyle(color: theme.primary),
                          filled: true,
                          fillColor: theme.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSubmitted: (_) => _addData(),
                      ),
                    ),
                  ],
                  if (_useFrequency) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _freqController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: theme.foreground),
                        decoration: InputDecoration(
                          labelText: 'FREQ',
                          labelStyle: TextStyle(color: theme.primary),
                          filled: true,
                          fillColor: theme.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSubmitted: (_) => _addData(),
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Data table
        Expanded(
          child: _xData.isEmpty
              ? Center(
                  child: Text(
                    'No data entered',
                    style: TextStyle(color: theme.muted, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _xData.length,
                  itemBuilder: (context, i) {
                    return Card(
                      color: theme.surface,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.primary.withOpacity(0.2),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(color: theme.primary),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'X: ${_xData[i]}',
                                style: TextStyle(
                                  color: theme.foreground,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            if (_mode == StatMode.twoVar)
                              Expanded(
                                child: Text(
                                  'Y: ${_yData[i]}',
                                  style: TextStyle(
                                    color: theme.foreground,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            if (_useFrequency)
                              Text(
                                'F: ${_freq[i]}',
                                style: TextStyle(
                                  color: theme.muted,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.close, color: theme.error),
                          onPressed: () => _removeAt(i),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildResults(dynamic theme) {
    final stats = _mode == StatMode.oneVar
        ? _calculate1Var()
        : _calculate2Var();

    if (stats.isEmpty) {
      return Center(
        child: Text(
          'Enter data to see results',
          style: TextStyle(color: theme.muted),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_mode == StatMode.twoVar) ...[
          _buildSection(theme, 'Regression Type', [
            SegmentedButton<RegressionType>(
              segments: const [
                ButtonSegment(
                  value: RegressionType.linear,
                  label: Text('y=a+bx'),
                ),
                ButtonSegment(
                  value: RegressionType.quadratic,
                  label: Text('y=a+bx+cx²'),
                ),
              ],
              selected: {_regType},
              onSelectionChanged: (sel) => setState(() => _regType = sel.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: theme.primary,
                selectedForegroundColor: theme.background,
              ),
            ),
          ]),
          const SizedBox(height: 16),
        ],

        _buildSection(
          theme,
          _mode == StatMode.oneVar ? '1-Variable Stats' : 'X Statistics',
          stats.entries
              .map((e) => _buildStatRow(theme, e.key, e.value))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSection(dynamic theme, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(dynamic theme, String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _formatValue(value),
            style: TextStyle(
              color: theme.primary,
              fontFamily: 'monospace',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(double val) {
    if (val.abs() >= 1e6 || (val.abs() < 1e-4 && val != 0)) {
      return val.toStringAsExponential(6);
    }
    return val.toStringAsFixed(8).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _reset() {
    _unfocusInputs();
    _xController.clear();
    _yController.clear();
    _freqController.clear();
    _useFrequency = false;
  }

  void _unfocusInputs() {
    FocusScope.of(context).unfocus();
  }
}
