import 'dart:isolate';

import 'package:app/core/eval_context.dart';
import 'package:app/pages/table_page.dart';
import 'package:app/pages/vector_page.dart';
import 'package:app/theme/theme_data.dart';
import 'package:app/widgets/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Keep focus node to ensure cursor stays visible/blinking
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void dispose() {
    _inputFocusNode.dispose();
    super.dispose();
  }

  // In _handlePress method
  void _handlePress(String primary, String? shift, String? alpha) {
    final state = context.read<CalculatorState>();

    // Request focus so the cursor is visible when typing
    if (!_inputFocusNode.hasFocus) {
      _inputFocusNode.requestFocus();
    }

    // Handle special navigation buttons first
    if (state.isShift && shift == 'STAT') {
      _navigateToStats();
      state.clearShift();
      return;
    }

    if (state.isShift && shift == 'EQN') {
      _navigateToEquation();
      state.clearShift();
      return;
    }

    if (state.isShift && shift == 'TABL') {
      _navigateToTable();
      state.clearShift();
      return;
    }

    if (state.isAlpha && alpha == 'VECTOR') {
      _navigateToVector();
      state.clearAlpha();
      return;
    }

    // Special handling for DEL and AC buttons
    if (primary == 'DEL') {
      state.delete();
      return;
    }

    if (primary == 'AC') {
      state.clear();
      return;
    }

    // For arrow keys, handle cursor movement
    if (primary == '←') {
      _moveCursorLeft();
      return;
    }

    if (primary == '→') {
      _moveCursorRight();
      return;
    }

    // Normal button press handling
    state.handleButtonPress(primary: primary, shift: shift, alpha: alpha);
  }

  void _moveCursorLeft() {
    final state = context.read<CalculatorState>();
    final currentPos = state.controller.selection.base.offset;
    if (currentPos > 0) {
      state.controller.selection = TextSelection.collapsed(
        offset: currentPos - 1,
      );
    }
  }

  void _moveCursorRight() {
    final state = context.read<CalculatorState>();
    final currentPos = state.controller.selection.base.offset;
    if (currentPos < state.controller.text.length) {
      state.controller.selection = TextSelection.collapsed(
        offset: currentPos + 1,
      );
    }
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

  void _navigateToVector() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VectorPage()),
    );
  }

  void _navigateToTable() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TablePage()),
    );
  }

  void _showModeMenu(BuildContext context, CalculatorState state) {
    final theme = context.read<ThemeProvider>().currentTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SingleChildScrollView(
        child: Padding(
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
              ListTile(
                leading: Icon(Icons.table_view, color: theme.primary),
                title: Text('Table', style: TextStyle(color: theme.foreground)),
                subtitle: Text(
                  'Single and Dual Function Table Generator',
                  style: TextStyle(color: theme.muted),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _navigateToTable();
                },
              ),
              ListTile(
                leading: Icon(Icons.directions, color: theme.primary),
                title: Text(
                  'Vector',
                  style: TextStyle(color: theme.foreground),
                ),
                subtitle: Text(
                  '2D/3D Vector Calculator',
                  style: TextStyle(color: theme.muted),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _navigateToVector();
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
                    builder: (_, _) {
                      return SegmentedButton<AngleMode>(
                        segments: const [
                          ButtonSegment(
                            value: AngleMode.degrees,
                            label: Text('DEG'),
                          ),
                          ButtonSegment(
                            value: AngleMode.radians,
                            label: Text('RAD'),
                          ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CalculatorState>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = themeProvider.currentTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Display Section
            Expanded(child: _buildDisplaySection(theme, state)),
            // Keypad Section
            _buildKeypadSection(
              theme,
              state,
              constraints.maxHeight,
              constraints.maxWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKeypadSection(
    AppThemeData theme,
    CalculatorState state,
    double maxAvailable,
    double maxWidth,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic, // Smoother transition for height
      // If Scientific, take ~65% of screen. If Basic, take calculated height.
      height: _keypadHeight(state.uiMode, maxAvailable, maxWidth),

      color: theme.background,
      child: GridView.count(
        // Use a unique key for each mode to reset scroll position on toggle
        key: ValueKey(state.uiMode),
        crossAxisCount: 5,
        padding: const EdgeInsets.all(8),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.0,
        // Keep your physics as requested
        physics: state.uiMode == CalculatorUIMode.basic
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        children: _buildCalculatorButtons(
          theme,
          theme.shiftColor,
          theme.alphaColor,
          state.isShift,
          state.isAlpha,
          state,
        ),
      ),
    );
  }

  double _keypadHeight(
    CalculatorUIMode mode,
    double maxAvailable,
    double maxWidth,
  ) {
    // --- SCIENTIFIC MODE ---
    if (mode == CalculatorUIMode.scientific) {
      // Reserve space for the display so it doesn't get crushed.
      // 180.0 is roughly the height of your display's padding + text.
      const double minDisplayHeight = 200.0;

      // The keypad takes whatever is left
      final double result = maxAvailable - minDisplayHeight;

      // Safety check: ensure we don't return a negative number if screen is tiny
      return result.clamp(0.0, maxAvailable);
    }

    // --- BASIC MODE ---
    const int columns = 5;
    const int rows = 5;
    const double spacing = 6.0;
    const double padding = 16.0;

    final double buttonSize =
        (maxWidth - padding - (spacing * (columns - 1))) / columns;
    final double desiredHeight =
        (rows * buttonSize) + ((rows - 1) * spacing) + 16.0;

    return desiredHeight.clamp(0.0, maxAvailable);
  }

  Widget _buildDisplaySection(AppThemeData theme, CalculatorState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: theme.displayBackground,
        border: Border(
          bottom: BorderSide(
            color: theme.subtle.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Indicators Row
          _buildIndicatorRow(theme, state),

          const SizedBox(height: 12),
          //const Spacer(),
          // --- Editable Input Display ---
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: _buildEditorDisplay(theme, state)),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: state.uiMode == CalculatorUIMode.scientific ? 8 : 20,
                ), // Result Display
                Selector<CalculatorState, String>(
                  selector: (_, s) => s.display,
                  builder: (_, value, _) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation.drive(
                                Tween(begin: 0.95, end: 1.0),
                              ),
                              child: child,
                            ),
                          );
                        },
                    child: GestureDetector(
                      onLongPress: () {
                        // Copy the text to the clipboard
                        Clipboard.setData(ClipboardData(text: value));

                        // Optionally, show a confirmation message (e.g., a SnackBar)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Text copied to clipboard!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        key: ValueKey(state.uiMode),
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: Text(
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          value,
                          style: TextStyle(
                            fontSize:
                                state.uiMode == CalculatorUIMode.scientific
                                ? 36
                                : 48,
                            fontWeight: FontWeight.w600,
                            color: theme.displayText,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
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

  Widget _buildIndicatorRow(AppThemeData theme, CalculatorState state) {
    final shiftColor = theme.shiftColor;
    final alphaColor = theme.alphaColor;

    return Row(
      children: [
        // Wraps the scientific buttons in an animation
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn, // A nice "snap" effect
          alignment:
              Alignment.centerLeft, // Ensures it collapses toward the left
          child: state.uiMode == CalculatorUIMode.scientific
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: state.toggleShift,
                      child: Selector<CalculatorState, bool>(
                        selector: (_, s) => s.isShift,
                        builder: (_, v, _) => _animatedIndicator(
                          'S',
                          shiftColor(theme.background),
                          theme,
                          v,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: state.toggleAlpha,
                      child: Selector<CalculatorState, bool>(
                        selector: (_, s) => s.isAlpha,
                        builder: (_, v, _) => _animatedIndicator(
                          'A',
                          alphaColor(theme.background),
                          theme,
                          v,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: state.toggleHyp,
                      child: Selector<CalculatorState, bool>(
                        selector: (_, s) => s.isHyp,
                        builder: (_, v, _) =>
                            _animatedIndicator('HYP', theme.primary, theme, v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: state.toggleAngleMode,
                      child: Selector<CalculatorState, AngleMode>(
                        selector: (_, s) => s.angleMode,
                        builder: (_, mode, _) => _staticIndicator(
                          mode == AngleMode.radians ? 'RAD' : 'DEG',
                          theme.primary,
                          theme,
                        ),
                      ),
                    ),
                    // This spacing also collapses when switching modes
                    const SizedBox(width: 8),
                  ],
                )
              : const SizedBox.shrink(), // Occupies 0 width in Basic mode
        ),

        // The rest of your Row remains the same; it will slide left automatically
        GestureDetector(
          onTap: state.toggleUiMode,
          child: Selector<CalculatorState, CalculatorUIMode>(
            selector: (_, s) => s.uiMode,
            builder: (_, mode, _) => _staticIndicator(
              mode == CalculatorUIMode.basic ? 'BASIC' : 'SCI',
              theme.primary,
              theme,
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
          icon: Icon(Icons.palette_outlined, color: theme.muted, size: 22),
          onPressed: () => _showThemeSettings(context),
          tooltip: "Themes",
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  } // New Editor Display using TextField

  Widget _buildEditorDisplay(AppThemeData theme, CalculatorState state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: state.uiMode == CalculatorUIMode.scientific
          ? 36
          : 42, // Fixed height for one line
      child: ShaderMask(
        //TODO: Fix the shader stuff
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              theme.displayBackground,
              theme.displayBackground,
              theme.displayBackground,
              theme.displayBackground,
            ],
            stops: const [0.0, 0.05, 0.95, 1.0], // Tighter stops
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: TextField(
          controller: state.controller,
          focusNode: _inputFocusNode,
          readOnly: true,

          enableInteractiveSelection: true,

          scrollController: state.textScrollController,
          scrollPhysics: const BouncingScrollPhysics(),
          cursorColor: theme.primary,
          cursorWidth: 2,
          cursorRadius: const Radius.circular(2),
          textAlign: TextAlign.right,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontSize: state.uiMode == CalculatorUIMode.scientific ? 20 : 28,
            fontFamily: 'monospace',
            color: theme.primaryTextColor,
            letterSpacing: 1.0,
          ),
          decoration: const InputDecoration(
            isDense: false,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: EdgeInsets.fromLTRB(0, 4, 0, 4),
          ),
          contextMenuBuilder: (context, editableTextState) {
            return AdaptiveTextSelectionToolbar(
              anchors: editableTextState.contextMenuAnchors,
              children: [
                TextSelectionToolbarTextButton(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text == null) return;

                    final selection = state.controller.selection;
                    final text = state.controller.text;

                    final newText = text.replaceRange(
                      selection.start,
                      selection.end,
                      data!.text!,
                    );

                    state.controller.value = TextEditingValue(
                      text: newText,
                      selection: TextSelection.collapsed(
                        offset: selection.start + data.text!.length,
                      ),
                    );

                    editableTextState.hideToolbar();
                  },
                  child: const Text('Paste'),
                ),
              ],
            );
          },

          showCursor: true,
          maxLines: 1,
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
        color: active ? color.withValues(alpha: 0.12) : Colors.transparent,
        border: Border.all(
          color: active ? color : color.withValues(alpha: 0.4),
          width: active ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
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
          color: active ? color : color.withValues(alpha: 0.6),
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
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.6)),
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
    Function(Color) shiftColor,
    Function(Color) alphaColor,
    bool isShift,
    bool isAlpha,
    CalculatorState state,
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
      Color baseColor = isNumber
          ? theme.buttonNumber
          : isOperator
          ? theme.buttonOperator
          : isFunction
          ? theme.buttonFunction
          : isControl
          ? theme.buttonSpecial
          : theme.surface;

      return _CasioButton(
        label: label,
        shiftLabel: shift,
        alphaLabel: alpha,
        isActiveShift: isShift,
        isActiveAlpha: isAlpha,
        textColor: theme.primaryTextColor,
        baseColor: baseColor,
        shiftColor: shiftColor(baseColor),
        alphaColor: alphaColor(baseColor),
        onPressed: customOnTap ?? () => _handlePress(label, shift, alpha),
      );
    }

    if (state.uiMode == CalculatorUIMode.basic) {
      return [
        //Row 1
        btn('Sci', isFunction: true, customOnTap: () => state.toggleUiMode()),
        btn('^', isOperator: true),
        btn('√', isOperator: true),
        btn('(', isOperator: true),
        btn(')', isOperator: true),

        //Row 2
        btn('7', isNumber: true),
        btn('8', isNumber: true),
        btn('9', isNumber: true),
        btn('DEL', isControl: true),
        btn('AC', isControl: true),

        //Row 3
        btn('4', isNumber: true),
        btn('5', isNumber: true),
        btn('6', isNumber: true),
        btn('×', isOperator: true),
        btn('÷', isOperator: true),

        //Row 4
        btn('1', isNumber: true),
        btn('2', isNumber: true),
        btn('3', isNumber: true),
        btn('+', isOperator: true),
        btn('-', isOperator: true),

        //Row 5
        btn('0', isNumber: true),
        btn('.', isNumber: true),
        btn(
          'Crash',
          isFunction: true,
          customOnTap: () {
            SystemNavigator.pop();
            //while (true) {
            //Isolate.spawn((_) {}, null);
            //}
          },
        ),
        btn('Ans', isOperator: true),
        btn('=', isControl: true, customOnTap: () => state.evaluate()),
      ];
    }

    return [
      // Row 1: Removed CLR, Split Arrows
      btn('SHIFT', customOnTap: () => state.toggleShift(), isControl: true),
      btn('ALPHA', customOnTap: () => state.toggleAlpha(), isControl: true),
      btn(
        'MODE',
        shift: 'SETUP',
        customOnTap: () => _showModeMenu(context, state),
        isControl: true,
      ),
      btn('←', isControl: true),
      btn('→', isControl: true),

      // Row 2
      btn('x⁻¹', shift: 'x!', alpha: ':', isFunction: true),
      btn('nCr', shift: 'nPr', isFunction: true),
      btn('log', shift: '10ˣ', isFunction: true),
      btn('ln', shift: 'eˣ', isFunction: true),

      // Row 3
      btn('Pol', shift: 'Rec', isFunction: true),
      btn('HYP', customOnTap: () => state.toggleHyp(), isFunction: true),
      btn(
        state.isHyp ? 'sinh' : 'sin',
        shift: state.isHyp ? 'sinh⁻¹' : 'sin⁻¹',
        alpha: 'A',
        isFunction: true,
      ),
      btn(
        state.isHyp ? 'cosh' : 'cos',
        shift: state.isHyp ? 'cosh⁻¹' : 'cos⁻¹',
        alpha: 'B',
        isFunction: true,
      ),
      btn(
        state.isHyp ? 'tanh' : 'tan',
        shift: state.isHyp ? 'tanh⁻¹' : 'tan⁻¹',
        alpha: 'C',
        isFunction: true,
      ),
      btn('RCL', shift: 'STO', isFunction: true),

      // Row 4
      btn('x²', shift: '√', alpha: '', isFunction: true),
      btn('x³', shift: '³√', alpha: '', isFunction: true),
      btn('xⁿ', shift: 'ⁿ√', alpha: 'D', isFunction: true),
      btn('(', shift: '', alpha: 'E', isOperator: true),
      btn(')', shift: '', alpha: 'F', isOperator: true),

      // Row 5
      btn('7', shift: 'CONST', alpha: 'off', isNumber: true),
      btn('8', shift: 'CONV', isNumber: true),
      btn('9', shift: 'ARG', isNumber: true),
      btn('DEL', isControl: true),
      btn('AC', shift: 'RESET', isControl: true), // Moved RESET here
      // Row 6
      btn('4', shift: '∫dx', alpha: 'X', isNumber: true),
      btn('5', shift: 'd/dx', alpha: 'Y', isNumber: true),
      btn('6', shift: 'Σ(', alpha: 'Z', isNumber: true),
      btn('×', shift: '%', isOperator: true),
      btn('÷', shift: 'Abs', isOperator: true),

      // Row 7
      btn('1', shift: 'STAT', alpha: 'M', isNumber: true),
      btn('2', shift: 'TABL', alpha: 'i', isNumber: true),
      btn('3', shift: 'EQN', alpha: 'VECTOR', isNumber: true),
      btn('+', shift: 'M+', isOperator: true),
      btn('-', shift: 'M-', isOperator: true),

      // Row 8
      btn('0', shift: 'Rnd', isNumber: true),
      btn(
        '.',
        shift: 'Ran#',
        alpha: 'RanInt',
        isNumber: true,
      ), // Corrected alpha placement
      btn('×10ˣ', shift: 'π', alpha: 'e', isNumber: true),
      btn('Ans', shift: 'DRG', isFunction: true),
      btn(
        '=',
        shift: '≈',
        isControl: true,
        customOnTap: () => state.evaluate(),
      ),
    ];
  }

  void _showThemeSettings(BuildContext context) {
    showDialog(context: context, builder: (_) => const ThemeSettingsDialog());
  }
}

// _CasioButton class remains unchanged (omitted for brevity, assume it's same as provided)
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

  double _buttonFontSize(String label, bool isCenter) {
    if (isCenter) {
      // Heavy math / operators
      if (RegExp(r'[∫Σ√π]').hasMatch(label)) return 16;

      // Superscripts / scientific notation
      if (label.contains('ˣ') || label.contains('⁻¹')) return 15;

      // Long textual labels
      if (label.length >= 4) return 14;

      // Normal digits / ops
      return 18;
    } else {
      // Heavy math / operators
      if (RegExp(r'[∫Σ√π]').hasMatch(label)) return 18;

      // Superscripts / scientific notation
      if (label.contains('ˣ') || label.contains('⁻¹')) return 14;

      if (label.length <= 2) return 14;

      return 10;
    }
  }

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
                    fontSize: _buttonFontSize(label, true),
                    fontWeight: FontWeight.w600,
                    color: mainLabelColor,
                    height: 1.0, // prevents vertical shrink
                    fontFamilyFallback: const [
                      'Roboto',
                      'Noto Sans Math',
                      'Noto Sans Symbols',
                      'Segoe UI Symbol',
                    ],
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
                      fontSize: _buttonFontSize(shiftLabel!, false),
                      fontWeight: FontWeight.bold,
                      height: 1.0, // prevents vertical shrink
                      fontFamilyFallback: const [
                        'Roboto',
                        'Noto Sans Math',
                        'Noto Sans Symbols',
                        'Segoe UI Symbol',
                      ],
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
                      fontSize: _buttonFontSize(alphaLabel!, false),
                      height: 1.0, // prevents vertical shrink
                      fontFamilyFallback: const [
                        'Roboto',
                        'Noto Sans Math',
                        'Noto Sans Symbols',
                        'Segoe UI Symbol',
                      ],
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
