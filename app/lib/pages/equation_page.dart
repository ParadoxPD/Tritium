import 'dart:math';
import 'package:app/theme/theme_data.dart';
import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EquationPage extends StatefulWidget {
  const EquationPage({Key? key}) : super(key: key);

  @override
  State<EquationPage> createState() => _EquationPageState();
}

class _EquationPageState extends State<EquationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _polyDegree = 2;
  final List<TextEditingController> _polyCoeffs = List.generate(
    4,
    (_) => TextEditingController(),
  );
  String _polyResult = '';

  int _sysUnknowns = 2;
  final List<List<TextEditingController>> _sysCoeffs = List.generate(
    3,
    (_) => List.generate(4, (_) => TextEditingController()),
  );
  String _sysResult = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var ctrl in _polyCoeffs) {
      ctrl.dispose();
    }
    for (var row in _sysCoeffs) {
      for (var ctrl in row) {
        ctrl.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Equation Solver'),
        backgroundColor: theme.surface,
        foregroundColor: theme.foreground,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primary,
          labelColor: theme.primary,
          unselectedLabelColor: theme.muted,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.functions), text: 'Polynomial'),
            Tab(icon: Icon(Icons.grid_3x3), text: 'Simultaneous'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPolynomialTab(theme), _buildSystemTab(theme)],
      ),
    );
  }

  Widget _buildPolynomialTab(AppThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Polynomial Equation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Solve equations of degree 2 or 3',
            style: TextStyle(color: theme.muted, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Degree selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.subtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Degree',
                  style: TextStyle(
                    color: theme.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 2, label: Text('Quadratic (2)')),
                    ButtonSegment(value: 3, label: Text('Cubic (3)')),
                  ],
                  selected: {_polyDegree},
                  onSelectionChanged: (Set<int> selection) {
                    setState(() {
                      _polyDegree = selection.first;
                      _polyResult = '';
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: theme.primary,
                    selectedForegroundColor: theme.background,
                    fixedSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Equation display
          Container(
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
                  'Coefficients',
                  style: TextStyle(
                    color: theme.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPolynomialInput(theme),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Solve button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: _solvePolynomial,
              child: const Text(
                'SOLVE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          if (_polyResult.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildResultCard(theme, _polyResult),
          ],
        ],
      ),
    );
  }

  Widget _buildPolynomialInput(AppThemeData theme) {
    List<Widget> terms = [];

    for (int i = 0; i <= _polyDegree; i++) {
      if (i > 0) {
        terms.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '+',
              style: TextStyle(
                color: theme.muted,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }

      terms.add(
        Expanded(
          child: TextField(
            controller: _polyCoeffs[i],
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.foreground,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              labelText: String.fromCharCode('a'.codeUnitAt(0) + i),
              labelStyle: TextStyle(color: theme.primary),
              filled: true,
              fillColor: theme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
      );

      String power = switch (_polyDegree - i) {
        0 => '',
        1 => 'x',
        2 => 'x²',
        3 => 'x³',
        _ => '',
      };
      terms.add(
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            power,
            style: TextStyle(
              color: theme.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    terms.add(
      Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          '= 0',
          style: TextStyle(
            color: theme.foreground,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: terms);
  }

  void _solvePolynomial() {
    _unfocusInputs();
    if (_polyDegree == 2) {
      double a = double.tryParse(_polyCoeffs[0].text) ?? 0;
      double b = double.tryParse(_polyCoeffs[1].text) ?? 0;
      double c = double.tryParse(_polyCoeffs[2].text) ?? 0;

      if (a == 0) {
        setState(() => _polyResult = 'Error: Not a quadratic equation (a = 0)');
        return;
      }

      double discriminant = b * b - 4 * a * c;

      if (discriminant > 0) {
        double x1 = (-b + sqrt(discriminant)) / (2 * a);
        double x2 = (-b - sqrt(discriminant)) / (2 * a);
        setState(
          () => _polyResult =
              'Two real solutions:\n\nx₁ = ${_formatNum(x1)}\nx₂ = ${_formatNum(x2)}',
        );
      } else if (discriminant == 0) {
        double x = -b / (2 * a);
        setState(
          () => _polyResult = 'One repeated solution:\n\nx = ${_formatNum(x)}',
        );
      } else {
        double real = -b / (2 * a);
        double imag = sqrt(-discriminant) / (2 * a);
        setState(
          () => _polyResult =
              'Two complex solutions:\n\nx₁ = ${_formatNum(real)} + ${_formatNum(imag)}i\nx₂ = ${_formatNum(real)} - ${_formatNum(imag)}i',
        );
      }
    } else if (_polyDegree == 3) {
      setState(
        () => _polyResult =
            'Cubic equation solver:\n\nComing soon! This requires Cardano\'s formula implementation.',
      );
    }
  }

  Widget _buildSystemTab(AppThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System of Linear Equations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Solve simultaneous equations',
            style: TextStyle(color: theme.muted, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Unknowns selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.subtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Number of Unknowns',
                  style: TextStyle(
                    color: theme.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 2, label: Text('2 (x, y)')),
                    ButtonSegment(value: 3, label: Text('3 (x, y, z)')),
                  ],
                  selected: {_sysUnknowns},
                  onSelectionChanged: (Set<int> selection) {
                    setState(() {
                      _sysUnknowns = selection.first;
                      _sysResult = '';
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: theme.primary,
                    selectedForegroundColor: theme.background,
                    fixedSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Equations
          ...List.generate(_sysUnknowns, (row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSystemRow(theme, row),
            );
          }),

          const SizedBox(height: 8),

          // Solve button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _solveSystem,
              child: const Text(
                'SOLVE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          if (_sysResult.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildResultCard(theme, _sysResult),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemRow(AppThemeData theme, int row) {
    const vars = ['x', 'y', 'z'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.subtle),
      ),
      child: Row(
        children: [
          for (int col = 0; col < _sysUnknowns; col++) ...[
            if (col > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '+',
                  style: TextStyle(color: theme.muted, fontSize: 18),
                ),
              ),
            Expanded(
              child: TextField(
                controller: _sysCoeffs[row][col],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.foreground, fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                vars[col],
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '=',
              style: TextStyle(color: theme.foreground, fontSize: 18),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _sysCoeffs[row][_sysUnknowns],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.foreground, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _solveSystem() {
    _unfocusInputs();
    if (_sysUnknowns == 2) {
      double a1 = double.tryParse(_sysCoeffs[0][0].text) ?? 0;
      double b1 = double.tryParse(_sysCoeffs[0][1].text) ?? 0;
      double c1 = double.tryParse(_sysCoeffs[0][2].text) ?? 0;

      double a2 = double.tryParse(_sysCoeffs[1][0].text) ?? 0;
      double b2 = double.tryParse(_sysCoeffs[1][1].text) ?? 0;
      double c2 = double.tryParse(_sysCoeffs[1][2].text) ?? 0;

      double det = a1 * b2 - a2 * b1;

      if (det == 0) {
        setState(() => _sysResult = 'No unique solution\n(Determinant = 0)');
      } else {
        double dx = c1 * b2 - c2 * b1;
        double dy = a1 * c2 - a2 * c1;
        double x = dx / det;
        double y = dy / det;
        setState(
          () => _sysResult =
              'Solution:\n\nx = ${_formatNum(x)}\ny = ${_formatNum(y)}',
        );
      }
    } else {
      setState(
        () => _sysResult =
            '3×3 system solver:\n\nComing soon! This requires Gaussian elimination.',
      );
    }
  }

  Widget _buildResultCard(AppThemeData theme, String result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: theme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Solution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result,
            style: TextStyle(
              color: theme.foreground,
              fontSize: 16,
              height: 1.6,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _formatNum(double val) {
    if (val.abs() >= 1000000 || (val.abs() < 0.0001 && val != 0)) {
      return val.toStringAsExponential(6);
    }
    return val.toStringAsFixed(8).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _unfocusInputs() {
    FocusScope.of(context).unfocus();
  }
}
