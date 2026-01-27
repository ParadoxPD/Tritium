import 'dart:math' as math;
import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Vector {
  final List<double> components;

  Vector(this.components);

  int get dimension => components.length;

  double get magnitude =>
      math.sqrt(components.fold(0.0, (sum, c) => sum + c * c));

  Vector operator +(Vector other) {
    if (dimension != other.dimension) throw ArgumentError('Dimension mismatch');
    return Vector(
      List.generate(dimension, (i) => components[i] + other.components[i]),
    );
  }

  Vector operator -(Vector other) {
    if (dimension != other.dimension) throw ArgumentError('Dimension mismatch');
    return Vector(
      List.generate(dimension, (i) => components[i] - other.components[i]),
    );
  }

  Vector operator *(double scalar) {
    return Vector(components.map((c) => c * scalar).toList());
  }

  double dot(Vector other) {
    if (dimension != other.dimension) throw ArgumentError('Dimension mismatch');
    return List.generate(
      dimension,
      (i) => components[i] * other.components[i],
    ).fold(0.0, (sum, v) => sum + v);
  }

  Vector? cross(Vector other) {
    if (dimension != 3 || other.dimension != 3) return null;
    return Vector([
      components[1] * other.components[2] - components[2] * other.components[1],
      components[2] * other.components[0] - components[0] * other.components[2],
      components[0] * other.components[1] - components[1] * other.components[0],
    ]);
  }

  double angle(Vector other) {
    final dotProduct = dot(other);
    final magnitudes = magnitude * other.magnitude;
    if (magnitudes == 0) return 0;
    return math.acos((dotProduct / magnitudes).clamp(-1.0, 1.0));
  }

  @override
  String toString() =>
      '(${components.map((c) => c.toStringAsFixed(4)).join(', ')})';
}

class VectorPage extends StatefulWidget {
  const VectorPage({super.key});

  @override
  State<VectorPage> createState() => _VectorPageState();
}

class _VectorPageState extends State<VectorPage> {
  final Map<String, Vector?> _vectors = {
    'VctA': null,
    'VctB': null,
    'VctC': null,
    'VctD': null,
  };

  String _result = '';
  String? _error;

  void _defineVector(String name) {
    showDialog(
      context: context,
      builder: (ctx) => _VectorInputDialog(
        name: name,
        onSave: (vector) {
          setState(() {
            _vectors[name] = vector;
            _error = null;
          });
        },
      ),
    );
  }

  void _performOperation(String operation) {
    setState(() {
      _error = null;
      _result = '';
    });

    try {
      switch (operation) {
        case 'A+B':
          _binaryOp((a, b) => (a + b).toString(), 'VctA', 'VctB');
          break;
        case 'A-B':
          _binaryOp((a, b) => (a - b).toString(), 'VctA', 'VctB');
          break;
        case 'A·B':
          _binaryOp((a, b) => a.dot(b).toStringAsFixed(6), 'VctA', 'VctB');
          break;
        case 'A×B':
          _crossProduct('VctA', 'VctB');
          break;
        case 'Angle(A,B)':
          _angleCalc('VctA', 'VctB');
          break;
        case '|A|':
          _magnitude('VctA');
          break;
        case '2A':
          _scalarMultiply('VctA', 2);
          break;
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _binaryOp(String Function(Vector, Vector) op, String v1, String v2) {
    final a = _vectors[v1];
    final b = _vectors[v2];

    if (a == null || b == null) {
      setState(() => _error = 'Vectors not defined');
      return;
    }

    setState(() => _result = op(a, b));
  }

  void _crossProduct(String v1, String v2) {
    final a = _vectors[v1];
    final b = _vectors[v2];

    if (a == null || b == null) {
      setState(() => _error = 'Vectors not defined');
      return;
    }

    if (a.dimension != 3 || b.dimension != 3) {
      setState(() => _error = 'Cross product requires 3D vectors');
      return;
    }

    final result = a.cross(b);
    if (result != null) {
      setState(() => _result = result.toString());
    }
  }

  void _angleCalc(String v1, String v2) {
    final a = _vectors[v1];
    final b = _vectors[v2];

    if (a == null || b == null) {
      setState(() => _error = 'Vectors not defined');
      return;
    }

    final angleRad = a.angle(b);
    final angleDeg = angleRad * 180 / math.pi;
    setState(
      () => _result =
          '${angleRad.toStringAsFixed(6)} rad (${angleDeg.toStringAsFixed(2)}°)',
    );
  }

  void _magnitude(String v) {
    final vec = _vectors[v];
    if (vec == null) {
      setState(() => _error = 'Vector not defined');
      return;
    }
    setState(() => _result = vec.magnitude.toStringAsFixed(6));
  }

  void _scalarMultiply(String v, double scalar) {
    final vec = _vectors[v];
    if (vec == null) {
      setState(() => _error = 'Vector not defined');
      return;
    }
    setState(() => _result = (vec * scalar).toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Vector Calculator'),
        backgroundColor: theme.surface,
        foregroundColor: theme.foreground,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Defined vectors display
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Defined Vectors',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.foreground,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _vectors.entries.map((entry) {
                    final defined = entry.value != null;
                    return ActionChip(
                      label: Text(
                        entry.key,
                        style: TextStyle(
                          color: defined ? theme.background : theme.foreground,
                        ),
                      ),
                      backgroundColor: defined ? theme.primary : theme.surface,
                      side: BorderSide(
                        color: defined ? theme.primary : theme.subtle,
                      ),
                      onPressed: () => _defineVector(entry.key),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Vector values
          if (_vectors.values.any((v) => v != null))
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.background,
                border: Border(top: BorderSide(color: theme.subtle)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _vectors.entries
                    .where((e) => e.value != null)
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                '${e.key}:',
                                style: TextStyle(
                                  color: theme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              e.value.toString(),
                              style: TextStyle(
                                color: theme.foreground,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          // Operations
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOperationSection(theme, 'Basic Operations', [
                  _buildOpButton(theme, 'A + B', 'A+B'),
                  _buildOpButton(theme, 'A - B', 'A-B'),
                  _buildOpButton(theme, '2 × A', '2A'),
                  _buildOpButton(theme, '|A| (Magnitude)', '|A|'),
                ]),
                const SizedBox(height: 16),
                _buildOperationSection(theme, 'Advanced Operations', [
                  _buildOpButton(theme, 'A · B (Dot Product)', 'A·B'),
                  _buildOpButton(theme, 'A × B (Cross Product)', 'A×B'),
                  _buildOpButton(theme, 'Angle(A, B)', 'Angle(A,B)'),
                ]),
              ],
            ),
          ),

          // Result display
          if (_result.isNotEmpty || _error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _error != null
                    ? theme.error.withValues(alpha: 0.1)
                    : theme.primary.withValues(alpha: 0.1),
                border: Border(
                  top: BorderSide(
                    color: _error != null ? theme.error : theme.primary,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _error != null
                            ? Icons.error_outline
                            : Icons.check_circle,
                        color: _error != null ? theme.error : theme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _error != null ? 'Error' : 'Result',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _error != null ? theme.error : theme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error ?? _result,
                    style: TextStyle(
                      color: theme.foreground,
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOperationSection(
    dynamic theme,
    String title,
    List<Widget> buttons,
  ) {
    return Container(
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: buttons),
        ],
      ),
    );
  }

  Widget _buildOpButton(dynamic theme, String label, String operation) {
    return ElevatedButton(
      onPressed: () => _performOperation(operation),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primary,
        foregroundColor: theme.background,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }
}

class _VectorInputDialog extends StatefulWidget {
  final String name;
  final Function(Vector) onSave;

  const _VectorInputDialog({required this.name, required this.onSave});

  @override
  State<_VectorInputDialog> createState() => _VectorInputDialogState();
}

class _VectorInputDialogState extends State<_VectorInputDialog> {
  int _dimension = 3;
  final List<TextEditingController> _controllers = List.generate(
    3,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _save() {
    final components = <double>[];
    for (int i = 0; i < _dimension; i++) {
      final val = double.tryParse(_controllers[i].text);
      if (val == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid number entered')));
        return;
      }
      components.add(val);
    }

    widget.onSave(Vector(components));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return AlertDialog(
      backgroundColor: theme.surface,
      title: Text(
        'Define ${widget.name}',
        style: TextStyle(color: theme.foreground),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 2, label: Text('2D')),
              ButtonSegment(value: 3, label: Text('3D')),
            ],
            selected: {_dimension},
            onSelectionChanged: (Set<int> sel) {
              setState(() => _dimension = sel.first);
            },
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: theme.primary,
              selectedForegroundColor: theme.background,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildInputs(theme),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: theme.muted)),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
          child: Text('Save', style: TextStyle(color: theme.primaryTextColor)),
        ),
      ],
    );
  }

  List<Widget> _buildInputs(dynamic theme) {
    final labels = ['x', 'y', 'z'];
    return List.generate(_dimension, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: _controllers[i],
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          style: TextStyle(color: theme.foreground),
          decoration: InputDecoration(
            labelText: labels[i],
            labelStyle: TextStyle(color: theme.primary),
            filled: true,
            fillColor: theme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    });
  }
}
