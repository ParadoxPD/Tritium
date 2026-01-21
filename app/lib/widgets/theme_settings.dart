import 'package:app/theme/theme_data.dart';
import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSettingsDialog extends StatefulWidget {
  const ThemeSettingsDialog({super.key});

  @override
  State<ThemeSettingsDialog> createState() => _ThemeSettingsDialogState();
}

class _ThemeSettingsDialogState extends State<ThemeSettingsDialog> {
  late final ValueNotifier<ThemeMode> filterMode;
  late final TextEditingController searchController;
  late final ValueNotifier<String> searchQuery;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ThemeProvider>();
    filterMode = ValueNotifier(provider.currentThemeGroup);
    searchController = TextEditingController();
    searchQuery = ValueNotifier('');
  }

  @override
  void dispose() {
    filterMode.dispose();
    searchController.dispose();
    searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterMode = ValueNotifier<ThemeMode>(
      context.read<ThemeProvider>().currentThemeGroup,
    );
    final searchController = TextEditingController();
    final searchQuery = ValueNotifier('');

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    onChanged: (v) => searchQuery.value = v.toLowerCase(),
                    decoration: InputDecoration(
                      hintText: 'Search themes…',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: current.panel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
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

                      return ValueListenableBuilder<String>(
                        valueListenable: searchQuery,
                        builder: (_, query, _) {
                          final filtered = query.isEmpty
                              ? themes
                              : themes
                                    .where(
                                      (t) =>
                                          t.name.toLowerCase().contains(query),
                                    )
                                    .toList();

                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, i) => ThemeTile(type: filtered[i]),
                          );
                        },
                      );
                    },
                  ),
                ),

                Divider(color: current.subtle),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.water_drop),
              onPressed: () async {
                final color = await showDialog<Color>(
                  context: context,
                  builder: (_) => _PastelPickerDialog(),
                );

                if (color != null) {
                  provider.setCustomPastel(color);
                }
              },
            ),

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
    final preview = type == ThemeType.customPastel
        ? provider.currentTheme
        : ThemeProvider.getThemeData(type);
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
                  child: _ThemePreviewSwatch(
                    theme: preview,
                    isSelected: isSelected,
                  ),
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
  final bool isSelected;

  const _ThemePreviewSwatch({required this.theme, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: 64,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.background, theme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? theme.primary : theme.subtle,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(isSelected ? 0.35 : 0.15),
            blurRadius: isSelected ? 14 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dot(theme.primary),
              _dot(theme.success),
              _dot(theme.error),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color c) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    ),
  );
}

class _PastelPickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = [
      // Blues & Cyans
      const Color(0xFF9AD0EC), // sky pastel
      const Color(0xFFA5DEE5), // ice blue
      const Color(0xFFBEE7E8), // mist cyan
      const Color(0xFFB8D8F8), // soft cornflower
      const Color(0xFFBFD7ED), // powder blue
      // Greens
      const Color(0xFFB8E0D2), // eucalyptus
      const Color(0xFFCDEAC0), // tea green
      const Color(0xFFD0F4DE), // mint cream
      const Color(0xFFC7EDE6), // aqua foam
      const Color(0xFFDFF5EA), // pale jade
      // Yellows & Creams
      const Color(0xFFFFF1C1), // vanilla
      const Color(0xFFFFF3B0), // soft butter
      const Color(0xFFFFF6CC), // cream
      const Color(0xFFFFE8A3), // pastel gold
      const Color(0xFFFFF0D6), // warm milk
      // Oranges & Peaches (distinct from your peach)
      const Color(0xFFFFD6A5), // apricot
      const Color(0xFFFFCDB2), // melon
      const Color(0xFFFFE0B5), // light amber
      const Color(0xFFFFD8BE), // soft sand
      const Color(0xFFFFE5C4), // pale caramel
      // Reds & Pinks (non-rose)
      const Color(0xFFFFC1CC), // blush
      const Color(0xFFFFD1DC), // cotton candy
      const Color(0xFFFADADD), // cherry blossom
      const Color(0xFFFFE4EC), // pale pink
      const Color(0xFFF6C1CC), // dusty pink
      // Purples (non-lavender)
      const Color(0xFFD7C9E3), // mauve mist
      const Color(0xFFE6D9F2), // lilac fog
      const Color(0xFFDCD6F7), // periwinkle pastel
      const Color(0xFFEADCF8), // soft orchid
      const Color(0xFFD8CFF0), // muted violet
      // Neutrals / Designer pastels
      const Color(0xFFEDEDE9), // soft paper
      const Color(0xFFEAE4E9), // warm gray
      const Color(0xFFF5EBE0), // linen
      const Color(0xFFE8EDDF), // sage paper
      const Color(0xFFF1FAEE), // off white mint
    ];

    return AlertDialog(
      title: const Text('Create Pastel Theme'),
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: colors.map((c) {
          return GestureDetector(
            onTap: () => Navigator.pop(context, c),
            child: CircleAvatar(backgroundColor: c, radius: 18),
          );
        }).toList(),
      ),
    );
  }
}
