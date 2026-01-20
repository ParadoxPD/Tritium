import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VectorPage extends StatefulWidget {
  const VectorPage({Key? key}) : super(key: key);

  @override
  State<VectorPage> createState() => _VectorPageState();
}

class _VectorPageState extends State<VectorPage> {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    return Scaffold(backgroundColor: theme.background);
  }
}
