# 🧮 Tritium - The Ultimate Free Calculator App

> **A comprehensive, open-source calculator suite built with Flutter**  
> _Because powerful tools should be free for everyone_

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge)](http://makeapullrequest.com)

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Installation](#-installation)
- [Usage Guide](#-usage-guide)
- [Architecture](#-architecture)
- [Development](#-development)
- [Contributing](#-contributing)
- [Roadmap](#-roadmap)
- [License](#-license)

---

## 🌟 Overview

**Tritium** is a feature-rich, completely free calculator application designed for students, engineers, scientists, and professionals. It combines the power of advanced scientific calculators like the Casio fx-991EX with modern conveniences like unit conversion, financial tools, and health calculators.

### Why Tritium?

- **🆓 100% Free** - No ads, no in-app purchases, no paywalls
- **🔬 Academic Excellence** - Full Casio fx-991EX emulation plus extended features
- **🛠️ Professional Tools** - Finance, engineering, health, and specialized calculators
- **🎨 Beautiful Design** - 20+ gorgeous themes (dark & light)
- **📱 Cross-Platform** - Android, iOS, Web, Windows, macOS, Linux
- **🔓 Open Source** - Community-driven, transparent development
- **🌍 Offline First** - Full functionality without internet
- **♿ Accessible** - Designed for everyone

---

## ✨ Features

### 🔬 Scientific Calculator (Casio fx-991EX Emulation)

**Complete Button Layout**

- ✅ SHIFT/ALPHA/HYP modifier modes
- ✅ All trigonometric functions (sin, cos, tan, + inverses, + hyperbolic)
- ✅ Logarithms (ln, log, exp, 10^x)
- ✅ Powers & Roots (x², x³, x^y, √, ³√, ⁿ√)
- ✅ Complex number arithmetic
- ✅ Matrix operations
- ✅ Memory variables (A-F, X-Z, M, Ans)
- ✅ Angle modes (RAD/DEG)
- ✅ Base-N conversions (Binary, Octal, Decimal, Hex)
- ✅ Engineering notation
- ✅ Exact fractions mode

**Advanced Math Engine**

- ✅ Complex arithmetic (a+bi)
- ✅ Matrix math (det, transpose, multiply, add, subtract)
- ✅ Expression parser with proper operator precedence
- ✅ Variable storage and custom functions
- ✅ Recursive evaluation with guards

**Casio Modes**

- ✅ **STAT Mode** - 1-Variable & 2-Variable statistics with regression
- ✅ **EQN Mode** - Polynomial (quadratic) & simultaneous equations (2×2)
- ✅ **TABLE Mode** - Function table generator (f(x) and g(x))
- ✅ **VECTOR Mode** - 2D/3D vector operations (dot, cross, magnitude, angle)

### 🔢 Specialized Calculators

**Mathematics**

- ✅ Matrix Calculator - Add, subtract, multiply, inverse, determinant
- ✅ Base-N Calculator - Binary, Octal, Decimal, Hexadecimal conversions
- ✅ Modulo Calculator - Modular arithmetic operations
- 🚧 Geometry Calculator - 2D/3D shapes (coming soon)
- 🚧 Algebra Tools - Fractions, ratios, percentages (coming soon)
- 🚧 Number Theory - GCD, LCM, prime checker (coming soon)

**Conversions**

- ✅ Unit Converter - 50+ categories, 500+ units
  - Length, Area, Volume, Mass, Time
  - Temperature, Speed, Pressure, Energy
  - Data, Frequency, Power, Force
  - Cooking, Medical, Scientific units
  - And much more!
- 🚧 Currency Converter - Live exchange rates (coming soon)

**Tools**

- ✅ Custom Functions - Define, save, and test your own functions
- 🚧 Random Generators - Numbers, dice, passwords, text (coming soon)
- 🚧 Date/Time Calculator (coming soon)

### 💰 Finance (Planned)

- Currency converter with live rates
- Loan & mortgage calculator
- Interest calculators
- ROI & investment tools
- Sales tax & tip calculator
- Discount calculator

### 🏃 Health & Fitness (Planned)

- BMI calculator
- Body fat percentage
- Calorie burn calculator
- Macro calculator
- Fitness metrics

### 🎨 Themes & Customization

**30+ Beautiful Themes**

_Dark Themes (17)_

- Default Dark, Midnight, Amoled Black
- Dark Ocean, Forest Night, Purple Dreams
- Cyberpunk, Sunset, Dracula
- Monokai, Nord, OneDarkPro
- GruvBox, Tokyo Night, Night Owl
- Catpuccin, Github Dark

_Light Themes (15)_

- Default Light, Paper White, Cream
- Pastel Blue, Mint Fresh, Lavender Dreams
- Warm Peach, Sky Blue, Rose Garden, Minimalist
- Github Light, One Light, Solarized Light,
- Catpuccin Latte, Everforest Light

**Customization**

- Theme persistence
- Color-coded button types
- Accessible contrast ratios
- Beautiful gradients and shadows

---

## 📱 Screenshots

### Scientific Calculator

_(More screenshots coming soon)_

---

## 🚀 Installation

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Git

### Clone & Run

```bash
# Clone the repository
git clone https://github.com/ParadoxPD/Tritium.git

# Navigate to project directory
cd Tritium

# Install dependencies
flutter pub get

# Run on your device/emulator
flutter run
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## 📚 Usage Guide

### Quick Start

1. **Basic Calculation**

   - Tap numbers and operators
   - Press `=` to evaluate
   - Use `AC` to clear

2. **Scientific Functions**

   - Press `SHIFT` to access orange functions
   - Press `ALPHA` to access red variables
   - Press `HYP` before trig for hyperbolic functions

3. **Memory Storage**

   - Calculate a value
   - Press `SHIFT` → `RCL` (becomes `STO`)
   - Press variable letter (A-F, X-Z, M)
   - Value is stored!

4. **Recall Variable**
   - Press `RCL`
   - Press variable letter
   - Value inserted into expression

### Advanced Features

**Complex Numbers**

```
Input: 3+4i
Output: 3.0000+4.0000i

Functions work: sqrt(-1) → 0.0000+1.0000i
```

**Exact Fractions**

```
Toggle S⇔D button
Input: 1/3 + 1/6
Output: 1/2
```

**Matrix Operations**

```
Navigate to Matrix Calculator
Define matrices A and B
Perform: A + B, A × B, det(A), A⁻¹
```

**Base-N Conversions**

```
Input: 0xFF (hexadecimal)
Output: 255 (decimal)
Toggle base mode to see: 0b11111111
```

### Calculator Modes (Casio-style)

**STAT Mode** (SHIFT + 1)

- Enter data points
- Get mean, median, standard deviation
- Linear regression for 2-variable data

**EQN Mode** (SHIFT + 3)

- Solve quadratic equations
- Solve 2×2 simultaneous equations

**TABLE Mode** (SHIFT + 2)

- Enter function f(x)
- Set range (start, end, step)
- Generate value table

**VECTOR Mode** (ALPHA + VECTOR)

- Define 2D/3D vectors
- Calculate dot product, cross product
- Find magnitude and angle

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── core/
│   └── evaluator/           # Expression evaluation engine
│       ├── eval_types.dart  # Complex, Matrix, Fraction types
│       └── expression_evaluator.dart
├── models/                  # Data models
├── pages/                   # UI pages
│   ├── scientific_calculator_page.dart
│   ├── statistics_page.dart
│   ├── equation_page.dart
│   ├── table_page.dart
│   ├── vector_page.dart
│   ├── matrix_calculator_page.dart
│   ├── base_n_calculator_page.dart
│   ├── conversion_page.dart
│   └── custom_functions_page.dart
├── services/                # Business logic
│   ├── calculator_service.dart
│   └── conversion_service.dart
├── state/                   # State management
│   └── calculator_state.dart
├── theme/                   # Theming system
│   ├── theme_data.dart
│   └── theme_provider.dart
└── widgets/                 # Reusable widgets
```

### Key Technologies

- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **SharedPreferences** - Local storage
- **Dart** - Programming language

### Evaluation Engine

The core of the calculator is a custom-built expression evaluator that supports:

- **Tokenization** - Converts strings to tokens
- **Shunting Yard Algorithm** - Infix to postfix conversion
- **Postfix Evaluation** - Stack-based calculation
- **Type System** - double, Complex, Matrix, Fraction
- **Function Support** - 30+ mathematical functions
- **Variable Storage** - Named variables and custom functions

---

## 🛠️ Development

### Code Style

We follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide.

```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Run tests
flutter test
```

### Adding a New Calculator

1. Create page in `lib/pages/your_calculator_page.dart`
2. Create state if needed in `lib/state/`
3. Add navigation in `calculator_home.dart`
4. Update theme if needed
5. Add tests
6. Update documentation

### Testing

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widgets/

# Integration tests
flutter test test/integration/

# Coverage
flutter test --coverage
```

### Debugging

```bash
# Run in debug mode
flutter run --debug

# Run with DevTools
flutter run --debug --dart-define=FLUTTER_WEB_USE_SKIA=true

# Profile mode
flutter run --profile
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Ways to Contribute

1. **Report Bugs** - Open an issue with details
2. **Suggest Features** - Share your ideas
3. **Write Code** - Submit pull requests
4. **Improve Docs** - Help others understand
5. **Translate** - Multi-language support
6. **Test** - Try beta features
7. **Spread the Word** - Share with others

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Commit Message Guidelines

```
feat: Add currency converter
fix: Resolve root symbol parsing
docs: Update README with examples
style: Format code according to Dart style
refactor: Simplify matrix operations
test: Add tests for complex numbers
chore: Update dependencies
```

### Code Review Process

- All PRs require at least one review
- CI must pass (tests, linting)
- Follow existing code style
- Update documentation
- Add tests for new features

---

## 🗺️ Roadmap

See [TODO.md](TODO.md) for the complete development roadmap.

### Next Release (v0.2.0)

- [ ] Geometry calculator (2D/3D shapes)
- [ ] Currency converter with live rates
- [ ] Home screen widgets
- [ ] Settings page
- [ ] Bug fixes

### Future Versions

- **v0.3.0** - Finance calculators
- **v0.4.0** - Health & fitness tools
- **v0.5.0** - Random generators
- **v0.6.0** - Date/Time calculators
- **v1.0.0** - Stable release

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Tritium Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

### Inspiration

- **Casio fx-991EX** - The gold standard for scientific calculators
- **WolframAlpha** - Computational knowledge engine
- **Desmos** - Beautiful mathematical visualization
- **RealCalc** - Classic Android calculator

### Libraries & Tools

- [Flutter](https://flutter.dev) - Google's UI toolkit
- [Provider](https://pub.dev/packages/provider) - State management
- [SharedPreferences](https://pub.dev/packages/shared_preferences) - Local storage

### Contributors

Thanks to everyone who has contributed to this project!

_(Contributors will be listed here as the project grows)_

---

## 📞 Contact & Support

### Get Help

- 📖 **Documentation**: [Wiki](https://github.com/ParadoxPD/Tritium/wiki)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/ParadoxPD/Tritium/discussions)
- 🐛 **Bug Reports**: [Issues](https://github.com/ParadoxPD/Tritium/issues)
- 💡 **Feature Requests**: [Issues](https://github.com/ParadoxPD/Tritium/issues/new?template=feature_request.md)

### Community

- 🌐 **Website**: (Coming soon)
- 🐦 **Twitter**: (Coming soon)
- 💬 **Discord**: (Coming soon)
- 📧 **Email**: [contact@paradoxpd.tech](mailto:contact@paradoxpd.tech)

---

## ⭐ Star History

If you find this project useful, please consider giving it a star! It helps the project grow and motivates contributors.

[![Star History Chart](https://api.star-history.com/svg?repos=ParadoxPD/Tritium&type=Date)](https://star-history.com/#ParadoxPD/Tritium&Date)

---

## 🎯 Project Goals

### Mission Statement

> _To provide a completely free, comprehensive calculator application that empowers students, professionals, and enthusiasts with powerful mathematical and computational tools without any barriers._

### Core Principles

1. **100% Free Forever** - No ads, no subscriptions, no paywalls
2. **Privacy First** - No data collection, no tracking, no accounts
3. **Accessibility** - Usable by everyone, regardless of ability
4. **Quality** - Professional-grade accuracy and reliability
5. **Transparency** - Open-source, community-driven
6. **Education** - Help people learn and understand
7. **Innovation** - Push boundaries of mobile calculators

---

## 📊 Stats

![GitHub code size](https://img.shields.io/github/languages/code-size/ParadoxPD/Tritium?style=flat-square)
![GitHub repo size](https://img.shields.io/github/repo-size/ParadoxPD/Tritium?style=flat-square)
![Lines of code](https://img.shields.io/tokei/lines/github/ParadoxPD/Tritium?style=flat-square)
![GitHub issues](https://img.shields.io/github/issues/ParadoxPD/Tritium?style=flat-square)
![GitHub pull requests](https://img.shields.io/github/issues-pr/ParadoxPD/Tritium?style=flat-square)

---

<div align="center">

**Made with ❤️ by the Paradox**

If this project helped you, consider giving it a ⭐!

[Report Bug](https://github.com/ParadoxPD/Tritium/issues) · [Request Feature](https://github.com/ParadoxPD/Tritium/issues) · [Documentation](https://github.com/ParadoxPD/Tritium/wiki)

</div>
