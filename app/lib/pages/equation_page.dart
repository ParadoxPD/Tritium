import 'dart:math';
import 'package:app/theme/theme_data.dart';
import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EquationPage extends StatefulWidget {
  const EquationPage({super.key});

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
          onTap: (value) {
            _reset();
          },
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
                    _reset();
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

  //FIX: Add Complete evaluator engine support
  void _solvePolynomial() {
    _unfocusInputs();

    // Helper to parse
    double getP(int index) => double.tryParse(_polyCoeffs[index].text) ?? 0;

    if (_polyDegree == 2) {
      // ... (Your existing Quadratic logic remains here) ...
      double a = getP(0), b = getP(1), c = getP(2);
      // ... existing quadratic code ...
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
      // --- Cubic Solver (Cardano's Method) ---
      double a = getP(0);
      double b = getP(1);
      double c = getP(2);
      double d = getP(3);

      if (a == 0) {
        setState(() => _polyResult = 'Error: Not a cubic equation (a = 0)');
        return;
      }

      // Normalize to: x³ + Ax² + Bx + C = 0
      // We change variable names to avoid confusion with initial a,b,c,d
      double A = b / a;
      double B = c / a;
      double C = d / a;

      // Substitute x = y - A/3 to eliminate the quadratic term: y³ + py + q = 0
      double sqA = A * A;
      double p = B - (sqA / 3.0);
      double q = (2.0 * sqA * A) / 27.0 - (A * B) / 3.0 + C;

      // Calculate Discriminant
      double cubeP = p * p * p;
      double disc = (q * q) / 4.0 + (cubeP) / 27.0;

      // Offset to convert back from y to x
      double offset = A / 3.0;

      if (disc > 0) {
        // Case 1: One real root, two complex roots
        double r = -q / 2.0 + sqrt(disc);
        double s = -q / 2.0 - sqrt(disc);

        // Cube root function preserving sign
        double cbrt(double n) =>
            n < 0 ? -pow(-n, 1 / 3).toDouble() : pow(n, 1 / 3).toDouble();

        double u = cbrt(r);
        double v = cbrt(s);

        double realPart = -(u + v) / 2.0 - offset;
        double imagPart = (u - v) * sqrt(3) / 2.0;
        double root1 = (u + v) - offset;

        setState(() {
          _polyResult =
              'One real, two complex solutions:\n\n'
              'x₁ = ${_formatNum(root1)}\n'
              'x₂ = ${_formatNum(realPart)} + ${_formatNum(imagPart)}i\n'
              'x₃ = ${_formatNum(realPart)} - ${_formatNum(imagPart)}i';
        });
      } else if (disc == 0) {
        // Case 2: Three real roots, at least two are equal
        double cbrt(double n) =>
            n < 0 ? -pow(-n, 1 / 3).toDouble() : pow(n, 1 / 3).toDouble();

        double u = cbrt(-q / 2.0);
        double root1 = 2.0 * u - offset;
        double root2 = -u - offset;

        setState(() {
          _polyResult =
              'Three real solutions (contains repeats):\n\n'
              'x₁ = ${_formatNum(root1)}\n'
              'x₂ = ${_formatNum(root2)}\n'
              'x₃ = ${_formatNum(root2)}';
        });
      } else {
        // Case 3: Three distinct real roots (Casus irreducibilis)
        // Uses trigonometric substitution
        double phi = acos(-q / (2.0 * sqrt(-(cubeP) / 27.0)));
        double r = 2.0 * sqrt(-p / 3.0);

        double root1 = r * cos(phi / 3.0) - offset;
        double root2 = r * cos((phi + 2.0 * pi) / 3.0) - offset;
        double root3 = r * cos((phi + 4.0 * pi) / 3.0) - offset;

        setState(() {
          _polyResult =
              'Three distinct real solutions:\n\n'
              'x₁ = ${_formatNum(root1)}\n'
              'x₂ = ${_formatNum(root2)}\n'
              'x₃ = ${_formatNum(root3)}';
        });
      }
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
                    _reset();
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

  //FIX: Add Complete evaluator engine support
  void _solveSystem() {
    _unfocusInputs();

    // Helper to safely parse inputs
    double getCoeff(int row, int col) =>
        double.tryParse(_sysCoeffs[row][col].text) ?? 0;

    if (_sysUnknowns == 2) {
      // ... (Your existing 2x2 logic remains here) ...
      double a1 = getCoeff(0, 0);
      double b1 = getCoeff(0, 1);
      double c1 = getCoeff(0, 2); // Result constant for row 1

      double a2 = getCoeff(1, 0);
      double b2 = getCoeff(1, 1);
      double c2 = getCoeff(1, 2); // Result constant for row 2

      double det = a1 * b2 - a2 * b1;

      if (det == 0) {
        setState(() => _sysResult = 'No unique solution\n(Determinant = 0)');
      } else {
        double dx = c1 * b2 - c2 * b1;
        double dy = a1 * c2 - a2 * c1;
        setState(
          () => _sysResult =
              'Solution:\n\nx = ${_formatNum(dx / det)}\ny = ${_formatNum(dy / det)}',
        );
      }
    } else {
      // --- 3x3 Solver Implementation ---
      // Row 1
      double a1 = getCoeff(0, 0),
          b1 = getCoeff(0, 1),
          c1 = getCoeff(0, 2),
          d1 = getCoeff(0, 3);
      // Row 2
      double a2 = getCoeff(1, 0),
          b2 = getCoeff(1, 1),
          c2 = getCoeff(1, 2),
          d2 = getCoeff(1, 3);
      // Row 3
      double a3 = getCoeff(2, 0),
          b3 = getCoeff(2, 1),
          c3 = getCoeff(2, 2),
          d3 = getCoeff(2, 3);

      // Calculate Main Determinant (using Sarrus rule expansion)
      double D =
          a1 * (b2 * c3 - b3 * c2) -
          b1 * (a2 * c3 - a3 * c2) +
          c1 * (a2 * b3 - a3 * b2);

      if (D.abs() < 1e-10) {
        // Check for close to zero
        setState(() => _sysResult = 'No unique solution\n(Determinant ≈ 0)');
        return;
      }

      // Calculate Determinants for X, Y, Z by replacing columns with result vector D (d1, d2, d3)
      double dx =
          d1 * (b2 * c3 - b3 * c2) -
          b1 * (d2 * c3 - d3 * c2) +
          c1 * (d2 * b3 - d3 * b2);

      double dy =
          a1 * (d2 * c3 - d3 * c2) -
          d1 * (a2 * c3 - a3 * c2) +
          c1 * (a2 * d3 - a3 * d2);

      double dz =
          a1 * (b2 * d3 - b3 * d2) -
          b1 * (a2 * d3 - a3 * d2) +
          d1 * (a2 * b3 - a3 * b2);

      setState(() {
        _sysResult =
            'Solution:\n\n'
            'x = ${_formatNum(dx / D)}\n'
            'y = ${_formatNum(dy / D)}\n'
            'z = ${_formatNum(dz / D)}';
      });
    }
  }

  Widget _buildResultCard(AppThemeData theme, String result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
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

  void _reset() {
    _unfocusInputs();
    for (var controller in _polyCoeffs) {
      controller.clear();
    }

    // 2. Clear System of Equations Coefficients (Nested List)
    for (var row in _sysCoeffs) {
      for (var controller in row) {
        controller.clear();
      }
    }

    // 3. Reset result strings
    _polyResult = '';
  }
}
