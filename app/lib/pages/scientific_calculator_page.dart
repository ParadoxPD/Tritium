import 'package:app/core/evaluator/eval_types.dart';
import 'package:app/theme/theme_data.dart';
import 'package:app/widgets/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/calculator_state.dart';
import '../theme/theme_provider.dart';
import 'equation_page.dart';
import 'statistics_page.dart';

class ScientificCalculatorPage extends StatefulWidget {
  const ScientificCalculatorPage({super.key});

  @override
  State<ScientificCalculatorPage> createState() =>
      _ScientificCalculatorPageState();
}

class _ScientificCalculatorPageState extends State<ScientificCalculatorPage> {
  void _handlePress(String primary, String? shift, String? alpha) {
    final state = context.read<CalculatorState>();
    String toInput = primary;

    if (primary == 'STAT' || shift == 'STAT') {
      _navigateToStats();
      state.clearShift();
      return;
    }

    if (primary == 'EQN' || shift == 'EQN') {
      _navigateToEquation();
      state.clearShift();
      return;
    }

    state.handleButtonPress(primary: toInput, shift: shift, alpha: alpha);
  }

  void _navigateToStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatisticsPage()),
    );
  }

  void _navigateToEquation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EquationPage()),
    );
  }

  void _showModeMenu(BuildContext context, CalculatorState state) {
    final theme = context.read<ThemeProvider>().currentTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mode Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.foreground,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.calculate, color: theme.primary),
              title: Text(
                'Equation Solver',
                style: TextStyle(color: theme.foreground),
              ),
              subtitle: Text(
                'Solve polynomial & simultaneous equations',
                style: TextStyle(color: theme.muted),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToEquation();
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart, color: theme.primary),
              title: Text(
                'Statistics',
                style: TextStyle(color: theme.foreground),
              ),
              subtitle: Text(
                '1-Variable statistical analysis',
                style: TextStyle(color: theme.muted),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToStats();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: theme.primary),
              title: Text(
                'Angle Unit',
                style: TextStyle(color: theme.foreground),
              ),
              trailing: SizedBox(
                child: AnimatedBuilder(
                  animation: state,
                  builder: (_, __) {
                    return SegmentedButton<AngleMode>(
                      segments: const [
                        ButtonSegment(value: AngleMode.deg, label: Text('DEG')),
                        ButtonSegment(value: AngleMode.rad, label: Text('RAD')),
                      ],
                      selected: {state.angleMode},
                      onSelectionChanged: (s) => state.setAngleMode(s.first),
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: theme.primary,
                        selectedForegroundColor: theme.background,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CalculatorState>();
    final themeProvider = context.read<ThemeProvider>();
    final theme = themeProvider.currentTheme;

    final shiftColor = theme.warning;
    final alphaColor = theme.error;
    final isShift = state.isShift;
    final isAlpha = state.isAlpha;

    return Column(
      children: [
        // Display Section
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: BoxDecoration(
            color: theme.displayBackground,
            border: Border(
              bottom: BorderSide(
                color: theme.subtle.withOpacity(0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Indicators Row
              Row(
                children: [
                  Selector<CalculatorState, bool>(
                    selector: (_, s) => s.isShift,
                    builder: (_, v, __) =>
                        _animatedIndicator('S', shiftColor, theme, v),
                  ),
                  Selector<CalculatorState, bool>(
                    selector: (_, s) => s.isAlpha,
                    builder: (_, v, __) =>
                        _animatedIndicator('A', alphaColor, theme, v),
                  ),
                  Selector<CalculatorState, bool>(
                    selector: (_, s) => s.isHyp,
                    builder: (_, v, __) =>
                        _animatedIndicator('HYP', theme.primary, theme, v),
                  ),

                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: state.toggleAngleMode,
                    child: Selector<CalculatorState, AngleMode>(
                      selector: (_, s) => s.angleMode,
                      builder: (_, mode, __) => GestureDetector(
                        onTap: () =>
                            context.read<CalculatorState>().toggleAngleMode(),
                        child: _staticIndicator(
                          mode == AngleMode.rad ? 'RAD' : 'DEG',
                          theme.primary,
                          theme,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.apps, color: theme.muted, size: 22),
                    onPressed: () => _showModeMenu(context, state),
                    tooltip: "Mode Menu",
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.palette_outlined,
                      color: theme.muted,
                      size: 22,
                    ),
                    onPressed: () => _showThemeSettings(context),
                    tooltip: "Themes",
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Expression Display
              Selector<CalculatorState, String>(
                selector: (_, s) => s.expression,
                builder: (_, expr, __) => _fadingExpressionDisplay(theme, expr),
              ),

              const SizedBox(height: 8),

              // Result Display
              Selector<CalculatorState, String>(
                selector: (_, s) => s.display,
                builder: (_, value, __) => Text(
                  value,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: theme.displayText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Keypad Section
        Expanded(
          child: Container(
            color: theme.background,
            child: GridView.count(
              crossAxisCount: 5,
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
              children: _buildCalculatorButtons(
                theme,
                shiftColor,
                alphaColor,
                isShift,
                isAlpha,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fadingExpressionDisplay(AppThemeData theme, String text) {
    return SizedBox(
      height: 32,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              theme.displayBackground.withOpacity(0.0),
              theme.displayBackground,
              theme.displayBackground,
              theme.displayBackground.withOpacity(0.0),
            ],
            stops: const [0.0, 0.1, 0.9, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          physics: const BouncingScrollPhysics(),
          child: Text(
            text.isEmpty ? ' ' : text,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'monospace',
              color: theme.muted,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedIndicator(
    String label,
    Color color,
    AppThemeData theme,
    bool active,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.12) : Colors.transparent,
        border: Border.all(
          color: active ? color : color.withOpacity(0.4),
          width: active ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: active ? color : color.withOpacity(0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _staticIndicator(String label, Color color, AppThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  List<Widget> _buildCalculatorButtons(
    AppThemeData theme,
    Color shiftColor,
    Color alphaColor,
    bool isShift,
    bool isAlpha,
  ) {
    Widget btn(
      String label, {
      String? shift,
      String? alpha,
      bool isNumber = false,
      bool isOperator = false,
      bool isFunction = false,
      bool isControl = false,
      VoidCallback? customOnTap,
    }) {
      return _CasioButton(
        label: label,
        shiftLabel: shift,
        alphaLabel: alpha,
        isActiveShift: isShift,
        isActiveAlpha: isAlpha,
        baseColor: isNumber
            ? theme.buttonNumber
            : isOperator
            ? theme.buttonOperator
            : isFunction
            ? theme.buttonFunction
            : isControl
            ? theme.buttonSpecial
            : theme.surface,
        textColor: theme.primaryTextColor,
        shiftColor: shiftColor,
        alphaColor: alphaColor,
        onPressed: customOnTap ?? () => _handlePress(label, shift, alpha),
      );
    }

    return [
      // Row 1
      btn(
        'SHIFT',
        customOnTap: () => context.read<CalculatorState>().toggleShift(),
        isControl: true,
      ),
      btn(
        'ALPHA',
        customOnTap: () => context.read<CalculatorState>().toggleAlpha(),
        isControl: true,
      ),
      btn(
        'MODE',
        shift: 'SETUP',
        customOnTap: () =>
            _showModeMenu(context, context.read<CalculatorState>()),
        isControl: true,
      ),
      btn(
        'CLR',
        shift: 'RESET',
        customOnTap: () => context.read<CalculatorState>().input('AC'),
        isControl: true,
      ),
      btn('←', shift: '→', isControl: true),

      // Row 2
      btn('x⁻¹', shift: 'x!', alpha: ':', isFunction: true),
      btn('nCr', shift: 'nPr', isFunction: true),
      btn('Pol(', shift: 'Rec(', isFunction: true),
      btn('^', shift: '³√', alpha: '∛', isFunction: true),
      btn('log', shift: '10ˣ', isFunction: true),

      // Row 3
      btn('ln', shift: 'eˣ', isFunction: true),
      btn('(-)', shift: 'Ans', isFunction: true),
      btn('°\'"', shift: 'ENG', isFunction: true),
      btn(
        'HYP',
        customOnTap: () => context.read<CalculatorState>().toggleHyp(),
        isFunction: true,
      ),
      btn('sin', shift: 'sin⁻¹', alpha: 'D', isFunction: true),

      // Row 4
      btn('cos', shift: 'cos⁻¹', alpha: 'E', isFunction: true),
      btn('tan', shift: 'tan⁻¹', alpha: 'F', isFunction: true),
      btn('RCL', shift: 'STO', isFunction: true),
      btn('ENG', shift: '←', isFunction: true),
      btn('(', shift: ')', alpha: 'A', isOperator: true),

      // Row 5
      btn('7', shift: 'CONST', alpha: 'off', isNumber: true),
      btn('8', shift: 'CONV', isNumber: true),
      btn('9', shift: 'ARG', isNumber: true),
      btn('DEL', shift: 'INS', isControl: true),
      btn('AC', isControl: true),

      // Row 6
      btn('4', shift: '∫dx', alpha: 'X', isNumber: true),
      btn('5', shift: 'd/dx', alpha: 'Y', isNumber: true),
      btn('6', shift: 'Σ(', alpha: 'Z', isNumber: true),
      btn('×', shift: '%', isOperator: true),
      btn('÷', shift: 'Abs', isOperator: true),

      // Row 7
      btn('1', shift: 'STAT', alpha: 'M', isNumber: true),
      btn('2', shift: 'BASE', isNumber: true),
      btn('3', shift: 'EQN', isNumber: true),
      btn('+', shift: 'M+', isOperator: true),
      btn('-', shift: 'M-', isOperator: true),

      // Row 8
      btn('0', shift: 'Rnd', isNumber: true),
      btn('.', shift: 'Ran#', alpha: '=', isNumber: true),
      btn('×10ˣ', shift: 'π', alpha: 'e', isNumber: true),
      btn('Ans', shift: 'DRG', isFunction: true),
      btn('=', shift: '%', isControl: true),
    ];
  }

  void _showThemeSettings(BuildContext context) {
    showDialog(context: context, builder: (_) => const ThemeSettingsDialog());
  }
}

class _CasioButton extends StatelessWidget {
  final String label;
  final String? shiftLabel;
  final String? alphaLabel;
  final bool isActiveShift;
  final bool isActiveAlpha;
  final Color baseColor;
  final Color textColor;
  final Color shiftColor;
  final Color alphaColor;
  final VoidCallback onPressed;

  const _CasioButton({
    required this.label,
    this.shiftLabel,
    this.alphaLabel,
    required this.isActiveShift,
    required this.isActiveAlpha,
    required this.baseColor,
    required this.textColor,
    required this.shiftColor,
    required this.alphaColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color mainLabelColor = textColor;
    if (isActiveShift && shiftLabel != null) {
      mainLabelColor = textColor.withOpacity(0.3);
    }
    if (isActiveAlpha && alphaLabel != null) {
      mainLabelColor = textColor.withOpacity(0.3);
    }

    return Material(
      color: baseColor,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.black.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: label.length > 3 ? 14 : 18,
                    fontWeight: FontWeight.w600,
                    color: mainLabelColor,
                  ),
                ),
              ),
              if (shiftLabel != null)
                Positioned(
                  left: 4,
                  top: 3,
                  child: Text(
                    shiftLabel!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActiveShift
                          ? shiftColor
                          : shiftColor.withOpacity(0.6),
                      decoration: isActiveShift
                          ? TextDecoration.underline
                          : null,
                    ),
                  ),
                ),
              if (alphaLabel != null)
                Positioned(
                  right: 4,
                  top: 3,
                  child: Text(
                    alphaLabel!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActiveAlpha
                          ? alphaColor
                          : alphaColor.withOpacity(0.6),
                      decoration: isActiveAlpha
                          ? TextDecoration.underline
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
