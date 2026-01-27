import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_data.dart';

enum ThemeType {
  // --------------------
  // DARK THEMES
  // --------------------
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

  defaultDark,
  midnight,
  amoledBlack,
  darkOcean,
  forestNight,
  purpleDreams,
  cyberpunk,
  sunset,

  // --------------------
  // LIGHT THEMES
  // --------------------
  githubLight,
  oneLight,
  solarizedLight,
  catppuccinLatte,
  everforestLight,

  defaultLight,

  // --------------------
  // AUTO-GENERATED PASTELS
  // --------------------
  pastelBlue,
  pastelMint,
  pastelLavender,
  pastelPeach,
  pastelRose,

  //Dynamic Pastel
  customPastel,
}

class ThemeProvider extends ChangeNotifier {
  AppThemeData _currentTheme = OneDarkProTheme();
  ThemeType _themeType = ThemeType.oneDarkPro;
  ThemeMode _currentThemeGroup = ThemeMode.dark;

  static const _themeKey = 'selected_theme';
  static const _themeGroupKey = 'selected_theme_group';
  static const _pastelSeedKey = 'pastel_seed';
  int? _customPastelSeed;

  ThemeProvider() {
    _loadTheme();
  }

  AppThemeData get currentTheme => _currentTheme;
  ThemeData get theme => _currentTheme.toThemeData();
  ThemeType get themeType => _themeType;
  ThemeMode get currentThemeGroup => _currentThemeGroup;
  String get pastelSeedKey => _pastelSeedKey;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? 'oneDarkPro';
    final themeGroup = prefs.getString(_themeGroupKey) ?? 'dark';

    _themeType = ThemeType.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => ThemeType.oneDarkPro,
    );

    _currentThemeGroup = themeGroup == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;

    _customPastelSeed = prefs.getInt(_pastelSeedKey);

    _updateTheme();
    notifyListeners();
  }

  Future<void> setTheme(ThemeType type) async {
    _themeType = type;

    _currentThemeGroup = lightThemes.contains(type)
        ? ThemeMode.light
        : ThemeMode.dark;

    _updateTheme();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, type.name);
    await prefs.setString(_themeGroupKey, _currentThemeGroup.name);

    notifyListeners();
  }

  void _updateTheme() {
    switch (_themeType) {
      // ---------------- DARK ----------------
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

      case ThemeType.defaultDark:
        _currentTheme = DefaultDarkTheme();
        break;
      case ThemeType.midnight:
        _currentTheme = MidnightTheme();
        break;
      case ThemeType.amoledBlack:
        _currentTheme = AmoledBlackTheme();
        break;
      case ThemeType.darkOcean:
        _currentTheme = DarkOceanTheme();
        break;
      case ThemeType.forestNight:
        _currentTheme = ForestNightTheme();
        break;
      case ThemeType.purpleDreams:
        _currentTheme = PurpleDreamsTheme();
        break;
      case ThemeType.cyberpunk:
        _currentTheme = CyberpunkTheme();
        break;
      case ThemeType.sunset:
        _currentTheme = SunsetTheme();
        break;

      // ---------------- LIGHT ----------------
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
      case ThemeType.defaultLight:
        _currentTheme = DefaultLightTheme();
        break;

      // -------- AUTO-GENERATED PASTELS --------
      case ThemeType.pastelBlue:
        _currentTheme = PastelGeneratedTheme(const Color(0xFF5DA9E9));
        break;
      case ThemeType.pastelMint:
        _currentTheme = PastelGeneratedTheme(const Color(0xFF4ADE80));
        break;
      case ThemeType.pastelLavender:
        _currentTheme = PastelGeneratedTheme(const Color(0xFFB692F6));
        break;
      case ThemeType.pastelPeach:
        _currentTheme = PastelGeneratedTheme(const Color(0xFFFFB4A2));
        break;
      case ThemeType.pastelRose:
        _currentTheme = PastelGeneratedTheme(const Color(0xFFF472B6));
        break;

      case ThemeType.customPastel:
        final seed = _customPastelSeed ?? 0xFF5DA9E9;
        _currentTheme = PastelGeneratedTheme(Color(seed));
        break;
    }
  }

  Future<void> setCustomPastel(Color seed) async {
    _customPastelSeed = seed.toARGB32();
    _themeType = ThemeType.customPastel;
    _currentThemeGroup = ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pastelSeedKey, seed.toARGB32());
    await prefs.setString(_themeKey, _themeType.name);
    await prefs.setString(_themeGroupKey, _currentThemeGroup.name);

    _updateTheme();
    notifyListeners();
  }

  // Helper method to access theme colors from context
  static AppThemeData of(BuildContext context, {bool listen = true}) {
    return Provider.of<ThemeProvider>(context, listen: listen).currentTheme;
  }

  static AppThemeData getThemeData(ThemeType type) {
    switch (type) {
      // -------- ORIGINAL DARK --------
      case ThemeType.oneDarkPro:
        return OneDarkProTheme();
      case ThemeType.gruvbox:
        return GruvboxTheme();
      case ThemeType.nord:
        return NordTheme();
      case ThemeType.tokyoNight:
        return TokyoNightTheme();
      case ThemeType.dracula:
        return DraculaTheme();
      case ThemeType.nightOwl:
        return NightOwlTheme();
      case ThemeType.githubDark:
        return GitHubDarkTheme();
      case ThemeType.monokai:
        return MonokaiTheme();
      case ThemeType.catppuccinMocha:
        return CatppuccinMochaTheme();
      case ThemeType.ayuDark:
        return AyuDarkTheme();
      case ThemeType.defaultDark:
        return DefaultDarkTheme();
      case ThemeType.midnight:
        return MidnightTheme();
      case ThemeType.amoledBlack:
        return AmoledBlackTheme();
      case ThemeType.darkOcean:
        return DarkOceanTheme();
      case ThemeType.forestNight:
        return ForestNightTheme();
      case ThemeType.purpleDreams:
        return PurpleDreamsTheme();
      case ThemeType.cyberpunk:
        return CyberpunkTheme();
      case ThemeType.sunset:
        return SunsetTheme();

      // -------- ORIGINAL LIGHT --------
      case ThemeType.githubLight:
        return GitHubLightTheme();
      case ThemeType.oneLight:
        return OneLightTheme();
      case ThemeType.solarizedLight:
        return SolarizedLightTheme();
      case ThemeType.catppuccinLatte:
        return CatppuccinLatteTheme();
      case ThemeType.everforestLight:
        return EverforestLightTheme();
      case ThemeType.defaultLight:
        return DefaultLightTheme();

      // -------- AUTO-GENERATED PASTELS --------
      case ThemeType.pastelBlue:
        return PastelGeneratedTheme(const Color(0xFF5DA9E9));
      case ThemeType.pastelMint:
        return PastelGeneratedTheme(const Color(0xFF4ADE80));
      case ThemeType.pastelLavender:
        return PastelGeneratedTheme(const Color(0xFFB692F6));
      case ThemeType.pastelPeach:
        return PastelGeneratedTheme(const Color(0xFFFFB4A2));
      case ThemeType.pastelRose:
        return PastelGeneratedTheme(const Color(0xFFF472B6));
      case ThemeType.customPastel:
        return PastelGeneratedTheme(const Color(0xFF5DA9E9));
    }
  }

  List<ThemeType> get darkThemes => [
    ThemeType.oneDarkPro,
    ThemeType.gruvbox,
    ThemeType.nord,
    ThemeType.tokyoNight,
    ThemeType.dracula,
    ThemeType.nightOwl,
    ThemeType.githubDark,
    ThemeType.monokai,
    ThemeType.catppuccinMocha,
    ThemeType.ayuDark,
    ThemeType.defaultDark,
    ThemeType.midnight,
    ThemeType.amoledBlack,
    ThemeType.darkOcean,
    ThemeType.forestNight,
    ThemeType.purpleDreams,
    ThemeType.cyberpunk,
    ThemeType.sunset,
  ];

  List<ThemeType> get lightThemes => [
    ThemeType.githubLight,
    ThemeType.oneLight,
    ThemeType.solarizedLight,
    ThemeType.catppuccinLatte,
    ThemeType.everforestLight,
    ThemeType.defaultLight,
    ThemeType.pastelBlue,
    ThemeType.pastelMint,
    ThemeType.pastelLavender,
    ThemeType.pastelPeach,
    ThemeType.pastelRose,
  ];
}
