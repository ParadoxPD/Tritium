# TODO - Universal Calculator App

**Vision**: A comprehensive, free, open-source calculator application that serves all academic, engineering, and professional needs without compromise.

---

## 🎯 Project Goals

1. **Universal Coverage** - Handle every calculation need from basic arithmetic to advanced engineering
2. **100% Free** - No paywalls, no ads, completely open-source
3. **Academic Excellence** - Full Casio fx-991EX emulation + extended features
4. **Professional Tools** - Engineering, finance, health, and specialized calculators
5. **User Experience** - Beautiful, intuitive, accessible interface
6. **Cross-Platform** - Flutter-based for Android, iOS, Web, Desktop

---

## ✅ PHASE 1: CORE FOUNDATION (COMPLETE)

### Scientific Calculator - DONE ✓

- [x] Casio fx-991EX button layout
- [x] SHIFT/ALPHA/HYP modes
- [x] All trig functions (normal + hyperbolic + inverse)
- [x] Logarithms (ln, log, exp)
- [x] Powers and roots (x², x³, xⁿ, √, ³√, ⁿ√)
- [x] Complex number support
- [x] Matrix operations (basic)
- [x] Memory variables (A-F, X-Z, M, Ans)
- [x] Angle modes (RAD/DEG)

### Advanced Math Engine - DONE ✓

- [x] Complex arithmetic
- [x] Matrix operations (det, transpose, multiply)
- [x] Base-N mode (Binary, Octal, Hex, Decimal)
- [x] Engineering notation
- [x] Exact fractions mode
- [x] Expression parser with proper precedence
- [x] Variable storage and custom functions

### Casio Modes - DONE ✓

- [x] STAT mode (1-Var & 2-Var statistics)
- [x] EQN mode (Polynomial & Simultaneous equations)
- [x] TABLE mode (Function table generator)
- [x] VECTOR mode (2D/3D vector operations)

### Core Pages - DONE ✓

- [x] Matrix calculator (add, subtract, multiply, inverse, determinant)
- [x] Base-N calculator (bin, oct, dec, hex conversions)
- [x] Modulo calculator (modular arithmetic)
- [x] Unit converter (50+ categories, 500+ units)
- [x] Custom functions (define, save, test)

### Theme System - DONE ✓

- [x] Multiple dark themes (10+)
- [x] Multiple light themes (10+)
- [x] Theme persistence
- [x] Beautiful color schemes
- [x] Accessible contrast

---

## 🚧 PHASE 2: GEOMETRY & SHAPES (IN PROGRESS)

### Priority: HIGH | Timeline: 2-3 weeks

### 2D Shapes Calculator

- [ ] **Circle**: Area, Circumference, Arc length, Sector area
- [ ] **Triangle**: Area (Heron's formula, base×height), Perimeter, Angles, Special triangles
- [ ] **Rectangle/Square**: Area, Perimeter, Diagonal
- [ ] **Parallelogram**: Area, Perimeter
- [ ] **Trapezoid**: Area, Perimeter
- [ ] **Rhombus**: Area, Perimeter
- [ ] **Regular Polygon**: Area, Perimeter (3-12 sides)
- [ ] **Ellipse**: Area, Perimeter (approximation)
- [ ] **Annulus**: Area (ring)
- [ ] **Sector/Segment**: Area calculations

### 3D Shapes Calculator

- [ ] **Cube**: Volume, Surface area, Diagonal
- [ ] **Cuboid/Box**: Volume, Surface area, Diagonal
- [ ] **Sphere**: Volume, Surface area
- [ ] **Cylinder**: Volume, Surface area (lateral + total)
- [ ] **Cone**: Volume, Surface area, Slant height
- [ ] **Pyramid**: Volume, Surface area (square, triangular)
- [ ] **Prism**: Volume, Surface area (triangular, hexagonal)
- [ ] **Torus**: Volume, Surface area
- [ ] **Ellipsoid**: Volume approximation
- [ ] **Frustum**: Volume (cone, pyramid)

### Coordinate Geometry

- [ ] **Distance**: Between two points (2D/3D)
- [ ] **Midpoint**: Between two points
- [ ] **Slope**: Line slope calculator
- [ ] **Line equation**: Point-slope, slope-intercept, standard form
- [ ] **Circle equation**: Center-radius, general form
- [ ] **Intersection**: Line-line, line-circle
- [ ] **Area of polygon**: Given vertices

### Implementation Notes

```
File: lib/pages/geometry_page.dart
- Tabbed interface: 2D, 3D, Coordinate
- Visual diagrams for each shape
- Input validation with real-time preview
- Unit selection (cm, m, in, ft)
- Copy results to clipboard
```

---

## 🚧 PHASE 3: WIDGETS & QUICK ACCESS (PRIORITY)

### Priority: HIGH | Timeline: 1-2 weeks

### Home Screen Widgets

- [ ] **Mini Calculator Widget**

  - Basic operations (+, -, ×, ÷)
  - Memory function
  - 4×4 button layout
  - Resizable (small, medium, large)
  - Dark/Light theme sync

- [ ] **Unit Converter Widget**

  - Quick common conversions
  - Length, Weight, Temperature
  - Favorite conversions
  - 2×1 or 2×2 size

- [ ] **Currency Converter Widget**
  - Real-time exchange rates (API integration)
  - Top 20 currencies
  - Auto-update daily
  - Offline cache

### Quick Access Panel

- [ ] Bottom sheet with common calculators
- [ ] Swipe-up gesture from any page
- [ ] Recently used calculators
- [ ] Favorites/Pinned calculators
- [ ] Search functionality

### Implementation Notes

```
Dependencies needed:
- home_widget: For Android/iOS widgets
- workmanager: For background updates
- http: For currency API calls
```

---

## 📊 PHASE 4: ALGEBRA & NUMBER THEORY

### Priority: MEDIUM | Timeline: 2 weeks

### Algebraic Operations

- [ ] **Percentage Calculator**

  - X is what % of Y
  - What is X% of Y
  - X is Y% of what
  - Percentage increase/decrease
  - Percentage change

- [ ] **Fractions**

  - Add, subtract, multiply, divide
  - Simplify fractions
  - Mixed number conversions
  - Decimal to fraction
  - Fraction comparison

- [ ] **Ratios & Proportions**

  - Simplify ratios
  - Divide quantity by ratio
  - Cross multiplication
  - Direct/Inverse proportion
  - Golden ratio calculator

- [ ] **Average & Statistics**
  - Mean, Median, Mode
  - Range, Variance
  - Weighted average
  - Moving average
  - Percentile calculator

### Number Theory Tools

- [ ] **GCD/LCM Calculator**

  - Greatest Common Divisor
  - Least Common Multiple
  - Multiple numbers support
  - Step-by-step solution

- [ ] **Prime Number Tools**

  - Prime checker
  - Prime factorization
  - List primes in range
  - Nth prime finder
  - Twin primes

- [ ] **Number Properties**
  - Even/Odd checker
  - Perfect square/cube
  - Fibonacci checker
  - Armstrong number
  - Palindrome checker

### Combinatorics (Extended)

- [ ] **Permutations**

  - nPr calculator
  - Circular permutations
  - Permutations with repetition
  - Derangements

- [ ] **Combinations**

  - nCr calculator
  - Multiset combinations
  - Stars and bars

- [ ] **Factorial Tools**
  - n! calculator (large numbers)
  - Double factorial (n!!)
  - Stirling's approximation

### Implementation Notes

```
File structure:
lib/pages/
  ├── algebra_page.dart
  ├── number_theory_page.dart
  └── combinatorics_page.dart
```

---

## 🎲 PHASE 5: RANDOM GENERATORS

### Priority: MEDIUM | Timeline: 1 week

### Number Generators

- [ ] **Random Number**

  - Integer range (min-max)
  - Decimal precision
  - Multiple numbers
  - No duplicates option
  - Cryptographically secure option

- [ ] **Dice Roller**

  - Standard dice (d4, d6, d8, d10, d12, d20)
  - Multiple dice
  - Custom sides
  - Sum/Individual results
  - Dice notation (3d6, 2d20+5)

- [ ] **Lottery Numbers**

  - Powerball
  - Mega Millions
  - Custom lottery format
  - Quick picks

- [ ] **Coin Flip**
  - Heads/Tails
  - Multiple flips
  - Statistics tracker

### Text/Password Generators

- [ ] **Password Generator**

  - Length selector (4-128)
  - Character sets (A-Z, a-z, 0-9, symbols)
  - Exclude ambiguous (0, O, l, 1)
  - Multiple passwords
  - Strength indicator
  - Pronounceable passwords

- [ ] **Random String**

  - Alphanumeric
  - Hex string
  - Base64
  - Custom alphabet

- [ ] **Text Randomizer**

  - Shuffle words
  - Shuffle letters
  - Random line picker
  - Lorem ipsum generator

- [ ] **UUID/GUID Generator**
  - Version 4 (random)
  - Bulk generation
  - Copy/Share

### Color Generator

- [ ] Random hex colors
- [ ] Random RGB/HSL
- [ ] Color palette generator
- [ ] Gradient generator

### Implementation Notes

```
File: lib/pages/random_generator_page.dart
- Secure random: dart:math Random.secure()
- Save favorites
- History of generated items
- Export options
```

---

## 💰 PHASE 6: FINANCE CALCULATORS

### Priority: HIGH | Timeline: 2-3 weeks

### Currency & Shopping

- [ ] **Currency Converter**

  - 150+ currencies
  - Live exchange rates
  - Offline mode (cached rates)
  - Historical rates
  - Currency trends graph
  - Favorite currencies
  - Widget integration

- [ ] **Sales Tax Calculator**

  - Calculate tax from price
  - Remove tax from total
  - Multi-jurisdiction tax
  - Custom tax rates
  - Save tax presets

- [ ] **Discount Calculator**

  - Percentage off
  - Multiple discounts
  - Final price calculator
  - Savings amount
  - Compare discounts

- [ ] **Tip Calculator**

  - Percentage tips (10%, 15%, 18%, 20%, custom)
  - Split bill
  - Round up/down options
  - Per person calculation
  - Service quality presets

- [ ] **Unit Price Comparison**
  - Price per unit
  - Best value finder
  - Different units (oz, lb, g, kg)
  - Bulk discount analyzer

### Loans & Interest

- [ ] **Loan Calculator**

  - Monthly payment (PMT)
  - Total interest paid
  - Amortization schedule
  - Extra payment impact
  - Loan comparison
  - APR calculator

- [ ] **Mortgage Calculator**

  - Principal & Interest
  - Include taxes & insurance
  - PMI calculator
  - Rent vs Buy comparison
  - Refinance calculator
  - Affordability calculator

- [ ] **Interest Calculators**

  - Simple interest
  - Compound interest
  - Continuous compounding
  - APY calculator
  - Rule of 72
  - Doubling time

- [ ] **Savings Calculator**
  - Future value
  - Required monthly deposit
  - Goal-based savings
  - Investment growth

### Investment Tools

- [ ] **ROI Calculator**

  - Return on investment
  - Annualized return
  - Investment gain/loss
  - Break-even analysis

- [ ] **Stock Calculator**

  - Profit/Loss
  - Average cost
  - Position sizing
  - Commission impact

- [ ] **Retirement Calculator**
  - Required savings
  - Retirement age
  - Withdrawal strategy
  - Inflation adjustment

### Business Finance

- [ ] **Markup/Margin Calculator**

  - Profit margin
  - Markup percentage
  - Break-even point
  - Gross vs Net

- [ ] **Paycheck Calculator**
  - Gross to net
  - Hourly to salary
  - Overtime calculator
  - Tax withholding

### Implementation Notes

```
Dependencies:
- http: For currency API
- intl: For number formatting
- charts_flutter: For graphs

API Options:
- exchangerate-api.com (free tier)
- fixer.io
- currencyapi.com
```

---

## 🏃 PHASE 7: HEALTH & FITNESS

### Priority: MEDIUM | Timeline: 2 weeks

### Body Metrics

- [ ] **BMI Calculator**

  - Weight & Height input
  - Metric/Imperial units
  - BMI categories
  - Visual indicator
  - Ideal weight range
  - Age/Gender adjustments

- [ ] **Body Fat Calculator**

  - Navy method (neck, waist, hip)
  - YMCA method
  - Skinfold measurements
  - Body fat categories
  - Lean body mass

- [ ] **BMR/TDEE Calculator**

  - Basal Metabolic Rate
  - Total Daily Energy Expenditure
  - Activity level multipliers
  - Macro calculator
  - Calorie goals

- [ ] **Body Measurements**
  - Waist-to-hip ratio
  - Waist-to-height ratio
  - Body frame size
  - Ideal measurements

### Calorie & Nutrition

- [ ] **Caloric Burn Calculator**

  - Exercise activities (50+ types)
  - Duration & intensity
  - MET values
  - Weight-based calculation
  - Total daily burn

- [ ] **Calorie Deficit/Surplus**

  - Weight loss/gain calculator
  - Time to goal
  - Healthy rate limits
  - Macro split

- [ ] **Macronutrient Calculator**

  - Protein/Carb/Fat grams
  - Percentage-based
  - Custom ratios
  - Popular diets (Keto, Paleo, etc.)

- [ ] **Water Intake Calculator**
  - Daily recommendation
  - Activity-based
  - Climate adjustment
  - Reminder calculator

### Fitness Planning

- [ ] **One-Rep Max (1RM)**

  - Multiple formulas
  - Training percentages
  - Plate calculator

- [ ] **Pace Calculator**

  - Running pace
  - Split times
  - Finish time predictor
  - Mile/Km conversion

- [ ] **Heart Rate Zones**

  - Max HR calculation
  - Zone 1-5 ranges
  - Target HR for goals
  - Karvonen formula

- [ ] **Pregnancy Calculator**
  - Due date
  - Conception date
  - Week-by-week info
  - Trimester calculator

### Implementation Notes

```
File: lib/pages/health_fitness_page.dart
- Save user profile (weight, height, age)
- History tracking
- Progress graphs
- Export to health apps
```

---

## 📅 PHASE 8: DATE & TIME CALCULATORS

### Priority: MEDIUM | Timeline: 1 week

### Date Calculations

- [ ] **Date Difference**

  - Days between dates
  - Years, months, weeks breakdown
  - Business days only
  - Age calculator
  - Relationship anniversary

- [ ] **Date Addition/Subtraction**

  - Add/subtract days/months/years
  - Business days calculation
  - Exclude weekends/holidays
  - Due date calculator

- [ ] **Day of Week**

  - Find day for any date
  - Historical dates
  - Future dates
  - Week number

- [ ] **World Clock**
  - Multiple timezones
  - Time conversion
  - Meeting planner
  - Daylight saving awareness

### Time Calculations

- [ ] **Time Duration**

  - Between two times
  - Hours:Minutes:Seconds
  - Decimal hours
  - Timesheet calculator

- [ ] **Time Addition/Subtraction**

  - Add/subtract time
  - Shift calculator
  - Break time deduction

- [ ] **Stopwatch & Timer**
  - Lap times
  - Split times
  - Countdown timer
  - Multiple timers

### Specialized

- [ ] **Work Hours Calculator**

  - Weekly hours
  - Overtime calculation
  - Punch card calculator
  - Shift differential

- [ ] **Deadline Calculator**

  - Project timeline
  - Working days to deadline
  - Milestone planner

- [ ] **Holiday Calculator**
  - Next holiday
  - Holiday list
  - Custom holidays
  - Religious calendars

### Implementation Notes

```
Dependencies:
- timezone: For world clock
- intl: For date formatting
```

---

## ⚙️ PHASE 9: SETTINGS & CONFIGURATION

### Priority: HIGH | Timeline: 1 week

### Core Settings Page

- [ ] **Theme Settings** (Already partial)

  - Dark/Light mode selector
  - Theme browser with preview
  - Custom theme creator
  - Theme import/export

- [ ] **Calculator Preferences**

  - Default angle mode (RAD/DEG)
  - Default base mode (DEC/HEX/BIN/OCT)
  - Decimal precision
  - Thousand separator
  - Scientific notation threshold
  - Auto-close parentheses

- [ ] **Page Management**

  - Toggle pages on/off
  - Reorder navigation tabs
  - Hide unused calculators
  - Favorites/Pinned pages
  - Custom page groups

- [ ] **Memory Management**

  - Clear all memory (A-F, X-Z, M)
  - Clear calculation history
  - Clear cached data
  - Export memory variables
  - Import memory variables

- [ ] **Data & Privacy**
  - Clear all app data
  - Export all settings
  - Import settings
  - Backup to cloud
  - Privacy policy
  - Open-source licenses

### Customization

- [ ] **Display Settings**

  - Font size
  - Button size
  - Haptic feedback
  - Sound effects
  - Animation speed

- [ ] **Input Settings**

  - Vibration on press
  - Key click sound
  - Swipe gestures
  - Long-press actions

- [ ] **Unit Preferences**
  - Default unit system (Metric/Imperial)
  - Temperature preference
  - Currency preference
  - Favorite conversions

### Advanced

- [ ] **Developer Options**

  - Debug mode
  - Show calculation steps
  - Expression tree view
  - Performance metrics
  - Error logging

- [ ] **Accessibility**
  - Screen reader support
  - Large text mode
  - High contrast
  - Color blind modes
  - Voice input

### Implementation Notes

```
File: lib/pages/settings_page.dart
Dependencies:
- shared_preferences: Settings storage
- flutter_tts: Voice feedback
- vibration: Haptic feedback
```

---

## 🎨 PHASE 10: POLISH & OPTIMIZATION

### Priority: MEDIUM | Timeline: Ongoing

### UI/UX Improvements

- [ ] **Onboarding**

  - Welcome screens
  - Feature highlights
  - Tutorial mode
  - Guided tour

- [ ] **Help & Documentation**

  - In-app help for each calculator
  - Formula explanations
  - Example calculations
  - Tips & tricks
  - Video tutorials

- [ ] **Search Functionality**

  - Global search
  - Search all calculators
  - Recent searches
  - Suggested searches

- [ ] **History**
  - Calculation history (all pages)
  - History search/filter
  - Export history
  - Clear selective history
  - Favorite calculations

### Performance

- [ ] **Optimization**

  - Lazy loading pages
  - Cache management
  - Memory optimization
  - Battery optimization
  - Startup time reduction

- [ ] **Offline Mode**
  - Full offline functionality
  - Cache currency rates
  - Offline help docs
  - Sync when online

### Quality Assurance

- [ ] **Testing**

  - Unit tests (all calculators)
  - Widget tests (UI)
  - Integration tests
  - Performance benchmarks
  - Accessibility audit

- [ ] **Bug Fixes**
  - Fix root symbol parsing
  - Complex number display
  - Matrix overflow handling
  - Theme persistence issues
  - Navigation bugs

### Platform-Specific

- [ ] **Android**

  - Material You theming
  - Adaptive icons
  - Shortcuts
  - Share functionality

- [ ] **iOS**

  - iOS design guidelines
  - Haptics
  - Shortcuts app integration
  - Siri shortcuts

- [ ] **Web**

  - Responsive design
  - PWA support
  - Keyboard shortcuts
  - SEO optimization

- [ ] **Desktop**
  - Native menus
  - Keyboard navigation
  - Window management
  - System tray icon

---

## 🚀 PHASE 11: ADVANCED FEATURES

### Priority: LOW | Timeline: Future

### Scientific Extensions

- [ ] **Calculus Tools**

  - Numerical integration (Simpson's, Trapezoidal)
  - Numerical differentiation
  - Limit calculator
  - Series calculator (convergence tests)

- [ ] **Linear Algebra**

  - Matrix rank
  - Eigenvalues/Eigenvectors
  - Matrix inverse (larger matrices)
  - LU decomposition
  - QR decomposition

- [ ] **Graph Plotter**
  - 2D function plotting
  - Multiple functions
  - Zoom/Pan
  - Find roots/intersections
  - Export as image

### Programming Tools

- [ ] **Bitwise Operations**

  - AND, OR, XOR, NOT
  - Bit shifts
  - Bit manipulation
  - Binary visualization

- [ ] **Boolean Algebra**

  - Truth tables
  - Logic gate simulator
  - Boolean expression simplification
  - Karnaugh maps

- [ ] **ASCII/Unicode**
  - Character code lookup
  - Text encoding converter
  - Emoji info

### Engineering

- [ ] **Electrical Engineering**

  - Ohm's law calculator
  - Resistor color code
  - RC/RL circuit calculator
  - Power calculations
  - Wire gauge calculator

- [ ] **Mechanical Engineering**

  - Gear ratio calculator
  - Belt/pulley calculator
  - Stress/Strain
  - Beam calculator

- [ ] **Chemistry Tools**
  - Molar mass calculator
  - Molarity calculator
  - pH calculator
  - Gas laws

### Specialized

- [ ] **Music Theory**

  - BPM calculator
  - Note frequency
  - Interval calculator
  - Chord finder

- [ ] **Photography**
  - Depth of field
  - Exposure calculator
  - Print size calculator
  - Megapixel calculator

---

## 📦 PHASE 12: RELEASE & DISTRIBUTION

### Priority: HIGH | Timeline: 2 weeks

### Pre-Release

- [ ] **Code Quality**

  - Code review
  - Refactoring
  - Documentation
  - Performance profiling
  - Security audit

- [ ] **Testing**
  - Beta testing program
  - User feedback collection
  - Bug triage
  - Crash analytics setup

### App Store Preparation

- [ ] **Android (Google Play)**

  - App signing
  - Store listing
  - Screenshots (6-8)
  - Promotional graphics
  - Privacy policy
  - Beta track

- [ ] **iOS (App Store)**

  - App signing
  - Store listing
  - Screenshots
  - App preview video
  - TestFlight beta
  - App review preparation

- [ ] **Web**

  - Domain registration
  - Hosting setup
  - PWA manifest
  - Service worker
  - SEO optimization

- [ ] **Desktop**
  - Windows installer
  - macOS DMG
  - Linux packages (snap, flatpak, AppImage)

### Marketing

- [ ] **Website**

  - Landing page
  - Feature showcase
  - Download links
  - Documentation
  - Blog/News

- [ ] **Social Media**

  - GitHub repository
  - Twitter/X account
  - Reddit community
  - Discord server

- [ ] **Promotion**
  - Press release
  - App review requests
  - Product Hunt launch
  - Hacker News post

### Post-Launch

- [ ] **Support**

  - Email support
  - FAQ page
  - Issue tracker
  - Feature requests
  - Community forums

- [ ] **Analytics**

  - Usage tracking (privacy-respecting)
  - Crash reporting
  - Feature usage metrics
  - A/B testing framework

- [ ] **Updates**
  - Regular bug fixes
  - Feature additions
  - Performance improvements
  - Security patches

---

## 🎯 PRIORITY MATRIX

### **CRITICAL (Do First)**

1. Root symbol parsing fix
2. Settings page
3. Currency converter widget
4. Basic geometry calculator

### **HIGH (Do Soon)**

1. Finance calculators (high user demand)
2. Algebra tools
3. Health calculators
4. Home screen widgets

### **MEDIUM (Plan Ahead)**

1. Random generators
2. Date/Time calculators
3. Advanced geometry
4. Number theory tools

### **LOW (Nice to Have)**

1. Graph plotter
2. Programming tools
3. Specialized engineering
4. Music/Photography tools

---

## 📊 PROGRESS TRACKING

**Overall Completion**: ~40%

| Phase                    | Status         | Progress |
| ------------------------ | -------------- | -------- |
| Phase 1: Core Foundation | ✅ Complete    | 100%     |
| Phase 2: Geometry        | 🔄 Not Started | 0%       |
| Phase 3: Widgets         | 🔄 Not Started | 0%       |
| Phase 4: Algebra         | 🔄 Not Started | 0%       |
| Phase 5: Random Gen      | 🔄 Not Started | 0%       |
| Phase 6: Finance         | 🔄 Not Started | 0%       |
| Phase 7: Health          | 🔄 Not Started | 0%       |
| Phase 8: Date/Time       | 🔄 Not Started | 0%       |
| Phase 9: Settings        | 🔄 Partial     | 30%      |
| Phase 10: Polish         | 🔄 Ongoing     | 20%      |
| Phase 11: Advanced       | 🔄 Not Started | 0%       |
| Phase 12: Release        | 🔄 Not Started | 0%       |

---

## 🐛 KNOWN BUGS TO FIX

### Critical

- [x] Root symbol (√) parsing not working correctly
- [ ] Complex number display formatting

### High Priority

- [ ] Matrix overflow on large determinants
- [ ] ShaderMask performance on Android
- [ ] Memory leak in table generator

### Medium Priority

- [ ] Scientific notation inconsistency
- [ ] Angle mode not saving in some cases
- [ ] Vector cross product edge cases
- [ ] Base-N display formatting

### Low Priority

- [ ] Button text overflow on small screens
- [ ] Minor UI alignment issues

---

## 💡 FEATURE REQUESTS (Community)

Track user-requested features here as they come in.

---

## 📝 NOTES

- Keep all features **100% free**
- No ads, ever
- No data collection beyond crash reports
- Open-source on GitHub
- Community-driven development
- Regular updates (monthly release cycle)
- Comprehensive documentation
- Multi-language support (future)
