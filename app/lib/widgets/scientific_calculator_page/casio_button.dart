// _CasioButton class remains unchanged (omitted for brevity, assume it's same as provided)
import 'package:flutter/material.dart';

class CasioButton extends StatelessWidget {
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

  const CasioButton({
    super.key,
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
      mainLabelColor = textColor.withValues(alpha: 0.3);
    }
    if (isActiveAlpha && alphaLabel != null) {
      mainLabelColor = textColor.withValues(alpha: 0.3);
    }

    return Material(
      color: baseColor,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.1),
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
                          : shiftColor.withValues(alpha: 0.6),
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
                          : alphaColor.withValues(alpha: 0.6),
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
