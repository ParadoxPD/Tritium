import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_data.dart';

enum ThemeType {
  // Dark Themes
  oneDarkPro,
  gruvbox,
  nord,
  tokyoNight,
  dracula,
  nightOwl,
  githubDark,
  monokai,
  catppuccinMocha,
  ayuDark,

  // Light Themes
  githubLight,
  oneLight,
  solarizedLight,
  catppuccinLatte,
  everforestLight,
}

class ThemeProvider extends ChangeNotifier {
  AppThemeData _currentTheme = OneDarkProTheme();
  ThemeType _themeType = ThemeType.oneDarkPro;

  static const _themeKey = 'selected_theme';

  ThemeProvider() {
    _loadTheme();
  }

  AppThemeData get currentTheme => _currentTheme;
  ThemeData get theme => _currentTheme.toThemeData();
  ThemeType get themeType => _themeType;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? 'oneDarkPro';

    // Safely find the theme from the enum string
    _themeType = ThemeType.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => ThemeType.oneDarkPro,
    );

    _updateTheme();
    notifyListeners(); // Ensure UI updates after loading from disk
  }

  Future<void> setTheme(ThemeType type) async {
    _themeType = type;
    _updateTheme();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, type.name);

    notifyListeners();
  }

  void _updateTheme() {
    switch (_themeType) {
      // Dark
      case ThemeType.oneDarkPro:
        _currentTheme = OneDarkProTheme();
        break;
      case ThemeType.gruvbox:
        _currentTheme = GruvboxTheme();
        break;
      case ThemeType.nord:
        _currentTheme = NordTheme();
        break;
      case ThemeType.tokyoNight:
        _currentTheme = TokyoNightTheme();
        break;
      case ThemeType.dracula:
        _currentTheme = DraculaTheme();
        break;
      case ThemeType.nightOwl:
        _currentTheme = NightOwlTheme();
        break;
      case ThemeType.githubDark:
        _currentTheme = GitHubDarkTheme();
        break;
      case ThemeType.monokai:
        _currentTheme = MonokaiTheme();
        break;
      case ThemeType.catppuccinMocha:
        _currentTheme = CatppuccinMochaTheme();
        break;
      case ThemeType.ayuDark:
        _currentTheme = AyuDarkTheme();
        break;

      // Light
      case ThemeType.githubLight:
        _currentTheme = GitHubLightTheme();
        break;
      case ThemeType.oneLight:
        _currentTheme = OneLightTheme();
        break;
      case ThemeType.solarizedLight:
        _currentTheme = SolarizedLightTheme();
        break;
      case ThemeType.catppuccinLatte:
        _currentTheme = CatppuccinLatteTheme();
        break;
      case ThemeType.everforestLight:
        _currentTheme = EverforestLightTheme();
        break;
    }
  }

  // Helper method to access theme colors from context
  static AppThemeData of(BuildContext context, {bool listen = true}) {
    return Provider.of<ThemeProvider>(context, listen: listen).currentTheme;
  }
}
