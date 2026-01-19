import 'package:app/theme/theme_data.dart';
import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSettingsDialog extends StatelessWidget {
  const ThemeSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final filterMode = ValueNotifier<ThemeMode>(
      context.read<ThemeProvider>().currentThemeGroup,
    );

    return Consumer<ThemeProvider>(
      builder: (context, provider, _) {
        final current = provider.currentTheme;

        return AlertDialog(
          backgroundColor: current.surface,
          title: Text(
            'Appearance',
            style: TextStyle(color: current.foreground),
          ),
          contentPadding: const EdgeInsets.only(top: 20),
          content: SizedBox(
            width: double.maxFinite,
            height: 450,
            child: Column(
              children: [
                // ───── DARK / LIGHT TOGGLE ─────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ValueListenableBuilder<ThemeMode>(
                    valueListenable: filterMode,
                    builder: (_, mode, __) {
                      return SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined),
                            label: Text('Dark'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined),
                            label: Text('Light'),
                          ),
                        ],
                        selected: {mode},
                        onSelectionChanged: (s) => filterMode.value = s.first,
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor: current.primary,
                          selectedForegroundColor: current.background,
                          side: BorderSide(color: current.subtle),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                Divider(color: current.subtle),

                // ───── THEME LIST ─────
                Expanded(
                  child: ValueListenableBuilder<ThemeMode>(
                    valueListenable: filterMode,
                    builder: (_, mode, __) {
                      final themes = mode == ThemeMode.dark
                          ? provider.darkThemes
                          : provider.lightThemes;

                      return ListView.builder(
                        itemCount: themes.length,
                        itemBuilder: (_, i) => ThemeTile(type: themes[i]),
                      );
                    },
                  ),
                ),

                Divider(color: current.subtle),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: current.primary)),
            ),
          ],
        );
      },
    );
  }
}

class ThemeTile extends StatelessWidget {
  final ThemeType type;

  const ThemeTile({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ThemeProvider>();
    final preview = ThemeProvider.getThemeData(type);
    final current = provider.currentTheme;

    return Selector<ThemeProvider, bool>(
      selector: (_, p) => p.themeType == type,
      builder: (_, isSelected, __) {
        return GestureDetector(
          onTap: () => provider.setTheme(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: preview.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? preview.primary
                    : current.subtle.withOpacity(0.4),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: preview.primary.withOpacity(0.35),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // ───── Animated preview block ─────
                AnimatedScale(
                  scale: isSelected ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: _ThemePreviewSwatch(theme: preview),
                ),

                const SizedBox(width: 12),

                // ───── Theme name ─────
                Expanded(
                  child: Text(
                    type.name
                        .replaceAllMapped(
                          RegExp(r'([A-Z])'),
                          (m) => ' ${m.group(0)}',
                        )
                        .trim(),
                    style: TextStyle(
                      color: preview.foreground,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),

                // ───── Check icon ─────
                AnimatedOpacity(
                  opacity: isSelected ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.check_circle, color: preview.primary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemePreviewSwatch extends StatelessWidget {
  final AppThemeData theme;

  const _ThemePreviewSwatch({required this.theme});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: 56,
      height: 36,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.subtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [_dot(theme.primary), _dot(theme.success), _dot(theme.error)],
      ),
    );
  }

  Widget _dot(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
