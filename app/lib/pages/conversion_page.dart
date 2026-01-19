import 'package:app/models/unit_models.dart';
import 'package:app/services/conversion_service.dart';
import 'package:app/services/unit_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_page.dart';
import '../theme/theme_provider.dart';

class ConversionPage extends StatefulWidget {
  const ConversionPage({Key? key}) : super(key: key);

  @override
  State<ConversionPage> createState() => _ConversionPageState();
}

class _ConversionPageState extends State<ConversionPage> {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<ConversionService>();
    final theme = context.watch<ThemeProvider>().currentTheme;

    return AppPage(
      title: 'Precision Converter',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGroupedDropdown(service, theme),
            const SizedBox(height: 24),

            ThemedCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInputRow(service, theme, isSource: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: GestureDetector(
                      onTap: service.swap,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 300),
                        builder: (_, v, child) {
                          return Transform.rotate(
                            angle: v * 3.1416,
                            child: child,
                          );
                        },
                        child: Icon(
                          Icons.swap_vert_circle,
                          color: theme.primary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  _buildInputRow(service, theme, isSource: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedDropdown(ConversionService service, dynamic theme) {
    // Logic to group UnitData.categories by domain for the UI
    return GestureDetector(
      onTap: () => _openCategoryPicker(context, service, theme),
      child: Container(
        decoration: BoxDecoration(
          color: theme.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.subtle),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(service.currentCategory.icon, color: theme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                service.currentCategory.name,
                style: TextStyle(color: theme.foreground),
              ),
            ),
            Icon(Icons.search, color: theme.muted),
          ],
        ),
      ),
    );
  }

  void _openCategoryPicker(
    BuildContext context,
    ConversionService service,
    dynamic theme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        String query = '';

        return StatefulBuilder(
          builder: (context, setState) {
            final filtered = UnitData.categories.where((c) {
              return c.name.toLowerCase().contains(query.toLowerCase()) ||
                  c.domain.toLowerCase().contains(query.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      prefixIcon: Icon(Icons.search, color: theme.muted),
                    ),
                    onChanged: (v) => setState(() => query = v),
                  ),
                  const SizedBox(height: 12),

                  // List
                  SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final cat = filtered[i];
                        return ListTile(
                          leading: Icon(cat.icon, color: theme.primary),
                          title: Text(
                            cat.name,
                            style: TextStyle(color: theme.foreground),
                          ),
                          subtitle: Text(
                            cat.domain,
                            style: TextStyle(color: theme.muted),
                          ),
                          onTap: () {
                            service.setCategory(cat);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Visual Hierarchy: Headers are bold and smaller, items are indented
  List<DropdownMenuItem<CategoryDefinition>> _buildGroupedItems(dynamic theme) {
    List<DropdownMenuItem<CategoryDefinition>> items = [];
    String? lastDomain;

    for (var cat in UnitData.categories) {
      if (cat.domain != lastDomain) {
        items.add(
          DropdownMenuItem(
            enabled: false,
            child: Text(
              cat.domain.toUpperCase(),
              style: TextStyle(
                color: theme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        );
        lastDomain = cat.domain;
      }
      items.add(
        DropdownMenuItem(
          value: cat,
          child: Row(
            children: [
              Icon(cat.icon, size: 18, color: theme.muted),
              SizedBox(width: 12),
              Text(cat.name, style: TextStyle(color: theme.foreground)),
            ],
          ),
        ),
      );
    }
    return items;
  }

  Widget _buildInputRow(
    ConversionService service,
    dynamic theme, {
    required bool isSource,
  }) {
    final currentUnit = isSource ? service.fromUnit : service.toUnit;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // VALUE SECTION
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSource ? "From" : "To",
                style: TextStyle(
                  color: theme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              isSource
                  ? TextField(
                      controller: service.inputController
                        ..selection = TextSelection.collapsed(
                          offset: service.input.length,
                        ),
                      onChanged: service.convert,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.foreground,
                      ),
                      decoration: InputDecoration(
                        hintText: "0.00",
                        hintStyle: TextStyle(color: theme.subtle),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: Text(
                        service.output.isEmpty ? "0.00" : service.output,
                        key: ValueKey(service.output),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: service.output.isEmpty
                              ? theme.subtle
                              : theme.primary,
                        ),
                      ),
                    ),
            ],
          ),
        ),

        // UNIT SELECTOR SECTION
        const SizedBox(width: 12),
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.subtle.withOpacity(0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UnitDefinition>(
              value: currentUnit,
              menuMaxHeight: 220,
              icon: Icon(Icons.unfold_more, size: 18, color: theme.primary),
              dropdownColor: theme.panel,
              items: service.currentCategory.units.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(
                    unit.symbol,
                    style: TextStyle(
                      color: theme.foreground,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newUnit) {
                if (isSource) {
                  service.updateUnits(from: newUnit);
                } else {
                  service.updateUnits(to: newUnit);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
