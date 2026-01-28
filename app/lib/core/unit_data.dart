import 'package:flutter/material.dart';
import '../models/unit_models.dart';

class UnitData {
  // Domains for grouping
  static const String dMath = "Mathematics / General";
  static const String dPhysics = "Physics / Mechanics";
  static const String dElec = "Electricity & Electronics";
  static const String dChem = "Chemistry / Science";
  static const String dBio = "Biology / Medical";
  static const String dEng = "Engineering / Tools";
  static const String dGeo = "Geography / Earth";
  static const String dComp = "Computing / Data";
  static const String dPrac = "Everyday / Practical";
  static const String dSound = "Sound / Acoustics";
  static const String dOpt = "Optics / Light";
  static const String dRad = "Radiation / Nuclear";

  static final List<CategoryDefinition> categories = [
    // --- MATHEMATICS ---
    CategoryDefinition(
      name: 'Length',
      domain: dMath,
      icon: Icons.straighten,
      units: [
        UnitDefinition(name: 'Meter', symbol: 'm', factor: 1.0),
        UnitDefinition(name: 'Kilometer', symbol: 'km', factor: 0.001),
        UnitDefinition(name: 'Centimeter', symbol: 'cm', factor: 100.0),
        UnitDefinition(name: 'Millimeter', symbol: 'mm', factor: 1000.0),
        UnitDefinition(name: 'Micrometer', symbol: 'µm', factor: 1e6),
        UnitDefinition(name: 'Nanometer', symbol: 'nm', factor: 1e9),
        UnitDefinition(name: 'Inch', symbol: 'in', factor: 39.3701),
        UnitDefinition(name: 'Foot', symbol: 'ft', factor: 3.28084),
        UnitDefinition(name: 'Yard', symbol: 'yd', factor: 1.09361),
        UnitDefinition(name: 'Mile', symbol: 'mi', factor: 0.000621371),
        UnitDefinition(
          name: 'Nautical Mile',
          symbol: 'nmi',
          factor: 0.000539957,
        ),
      ],
    ),
    CategoryDefinition(
      name: 'Area',
      domain: dMath,
      icon: Icons.layers,
      units: [
        UnitDefinition(name: 'Square Meter', symbol: 'm²', factor: 1.0),
        UnitDefinition(name: 'Sq. Kilometer', symbol: 'km²', factor: 1e-6),
        UnitDefinition(name: 'Sq. Centimeter', symbol: 'cm²', factor: 10000.0),
        UnitDefinition(name: 'Sq. Inch', symbol: 'in²', factor: 1550.0),
        UnitDefinition(name: 'Hectare', symbol: 'ha', factor: 0.0001),
        UnitDefinition(name: 'Acre', symbol: 'ac', factor: 0.000247105),
        UnitDefinition(name: 'Sq. Foot', symbol: 'ft²', factor: 10.7639),
        UnitDefinition(name: 'Sq. Mile', symbol: 'mi²', factor: 3.861e-7),
      ],
    ),

    // Update Volume to include all missing units
    CategoryDefinition(
      name: 'Volume',
      domain: dMath,
      icon: Icons.opacity,
      units: [
        UnitDefinition(name: 'Cubic Meter', symbol: 'm³', factor: 1.0),
        UnitDefinition(name: 'Liter', symbol: 'L', factor: 1000.0),
        UnitDefinition(name: 'Milliliter', symbol: 'mL', factor: 1e6),
        UnitDefinition(name: 'Cubic Centimeter', symbol: 'cc', factor: 1e6),
        UnitDefinition(name: 'Cubic Inch', symbol: 'in³', factor: 61023.7),
        UnitDefinition(name: 'Cubic Foot', symbol: 'ft³', factor: 35.3147),
        UnitDefinition(name: 'Gallon (US)', symbol: 'gal US', factor: 264.172),
        UnitDefinition(name: 'Gallon (UK)', symbol: 'gal UK', factor: 219.969),
        UnitDefinition(name: 'Quart', symbol: 'qt', factor: 1056.69),
        UnitDefinition(name: 'Pint', symbol: 'pt', factor: 2113.38),
        UnitDefinition(name: 'Cup', symbol: 'cup', factor: 4226.75),
      ],
    ),
    CategoryDefinition(
      name: 'Angle',
      domain: dMath,
      icon: Icons.architecture,
      units: [
        UnitDefinition(name: 'Degree', symbol: '°', factor: 1.0),
        UnitDefinition(name: 'Radian', symbol: 'rad', factor: 0.0174533),
        UnitDefinition(name: 'Gradian', symbol: 'gon', factor: 1.11111),
        UnitDefinition(name: 'Revolution', symbol: 'rev', factor: 1 / 360),
      ],
    ),

    // --- PHYSICS ---
    CategoryDefinition(
      name: 'Mass',
      domain: dPhysics,
      icon: Icons.scale,
      units: [
        UnitDefinition(name: 'Kilogram', symbol: 'kg', factor: 1.0),
        UnitDefinition(name: 'Gram', symbol: 'g', factor: 1000.0),
        UnitDefinition(name: 'Milligram', symbol: 'mg', factor: 1e6),
        UnitDefinition(name: 'Microgram', symbol: 'µg', factor: 1e9),
        UnitDefinition(name: 'Tonne', symbol: 't', factor: 0.001),
        UnitDefinition(name: 'Pound', symbol: 'lb', factor: 2.20462),
        UnitDefinition(name: 'Ounce', symbol: 'oz', factor: 35.274),
        UnitDefinition(name: 'Atomic Mass Unit', symbol: 'u', factor: 6.022e26),
      ],
    ),

    // Update Time to include microsecond
    CategoryDefinition(
      name: 'Time',
      domain: dPhysics,
      icon: Icons.schedule,
      units: [
        UnitDefinition(name: 'Second', symbol: 's', factor: 1.0),
        UnitDefinition(name: 'Millisecond', symbol: 'ms', factor: 1000.0),
        UnitDefinition(name: 'Microsecond', symbol: 'µs', factor: 1e6),
        UnitDefinition(name: 'Minute', symbol: 'min', factor: 1 / 60),
        UnitDefinition(name: 'Hour', symbol: 'h', factor: 1 / 3600),
        UnitDefinition(name: 'Day', symbol: 'd', factor: 1 / 86400),
        UnitDefinition(name: 'Year', symbol: 'yr', factor: 1 / 31536000),
      ],
    ),

    // NEW: Acceleration
    CategoryDefinition(
      name: 'Acceleration',
      domain: dPhysics,
      icon: Icons.speed,
      units: [
        UnitDefinition(name: 'Meters/sec²', symbol: 'm/s²', factor: 1.0),
        UnitDefinition(name: 'G-force', symbol: 'g', factor: 0.101972),
        UnitDefinition(name: 'Feet/sec²', symbol: 'ft/s²', factor: 3.28084),
      ],
    ),

    // Update Pressure to include kilopascal
    CategoryDefinition(
      name: 'Pressure',
      domain: dPhysics,
      icon: Icons.compress,
      units: [
        UnitDefinition(name: 'Pascal', symbol: 'Pa', factor: 1.0),
        UnitDefinition(name: 'Kilopascal', symbol: 'kPa', factor: 0.001),
        UnitDefinition(name: 'Bar', symbol: 'bar', factor: 1e-5),
        UnitDefinition(name: 'Atmosphere', symbol: 'atm', factor: 9.8692e-6),
        UnitDefinition(name: 'Torr', symbol: 'Torr', factor: 0.00750062),
        UnitDefinition(name: 'mmHg', symbol: 'mmHg', factor: 0.00750062),
        UnitDefinition(name: 'PSI', symbol: 'psi', factor: 0.000145038),
      ],
    ),

    // NEW: Density
    CategoryDefinition(
      name: 'Density',
      domain: dPhysics,
      icon: Icons.grain,
      units: [
        UnitDefinition(name: 'kg/m³', symbol: 'kg/m³', factor: 1.0),
        UnitDefinition(name: 'g/cm³', symbol: 'g/cm³', factor: 0.001),
        UnitDefinition(name: 'lb/ft³', symbol: 'lb/ft³', factor: 0.062428),
      ],
    ),

    // NEW: Frequency
    CategoryDefinition(
      name: 'Frequency',
      domain: dPhysics,
      icon: Icons.waves,
      units: [
        UnitDefinition(name: 'Hertz', symbol: 'Hz', factor: 1.0),
        UnitDefinition(name: 'Kilohertz', symbol: 'kHz', factor: 0.001),
        UnitDefinition(name: 'Megahertz', symbol: 'MHz', factor: 1e-6),
        UnitDefinition(name: 'Gigahertz', symbol: 'GHz', factor: 1e-9),
      ],
    ),

    // Update Power to include megawatt
    CategoryDefinition(
      name: 'Power',
      domain: dEng,
      icon: Icons.power,
      units: [
        UnitDefinition(name: 'Watt', symbol: 'W', factor: 1.0),
        UnitDefinition(name: 'Kilowatt', symbol: 'kW', factor: 0.001),
        UnitDefinition(name: 'Megawatt', symbol: 'MW', factor: 1e-6),
        UnitDefinition(name: 'Horsepower', symbol: 'hp', factor: 0.00134102),
      ],
    ),
    CategoryDefinition(
      name: 'Force',
      domain: dPhysics,
      icon: Icons.compress,
      units: [
        UnitDefinition(name: 'Newton', symbol: 'N', factor: 1.0),
        UnitDefinition(name: 'Dyne', symbol: 'dyn', factor: 1e5),
        UnitDefinition(name: 'Pound-force', symbol: 'lbf', factor: 0.224809),
        UnitDefinition(name: 'Kilogram-force', symbol: 'kgf', factor: 0.101972),
      ],
    ),
    CategoryDefinition(
      name: 'Energy',
      domain: dPhysics,
      icon: Icons.bolt,
      units: [
        UnitDefinition(name: 'Joule', symbol: 'J', factor: 1.0),
        UnitDefinition(name: 'Kilojoule', symbol: 'kJ', factor: 0.001),
        UnitDefinition(name: 'Calorie', symbol: 'cal', factor: 0.239006),
        UnitDefinition(
          name: 'Kilocalorie',
          symbol: 'kcal',
          factor: 0.000239006,
        ),
        UnitDefinition(name: 'Watt-hour', symbol: 'Wh', factor: 0.000277778),
        UnitDefinition(name: 'Kilowatt-hour', symbol: 'kWh', factor: 2.7778e-7),
        UnitDefinition(name: 'Electronvolt', symbol: 'eV', factor: 6.242e18),
      ],
    ),

    // --- ELECTRICITY ---
    CategoryDefinition(
      name: 'Voltage',
      domain: dElec,
      icon: Icons.electric_bolt,
      units: [
        UnitDefinition(name: 'Volt', symbol: 'V', factor: 1.0),
        UnitDefinition(name: 'Millivolt', symbol: 'mV', factor: 1000.0),
        UnitDefinition(name: 'Kilovolt', symbol: 'kV', factor: 0.001),
      ],
    ),
    CategoryDefinition(
      name: 'Current',
      domain: dElec,
      icon: Icons.flash_on,
      units: [
        UnitDefinition(name: 'Ampere', symbol: 'A', factor: 1.0),
        UnitDefinition(name: 'Milliampere', symbol: 'mA', factor: 1000.0),
        UnitDefinition(name: 'Microampere', symbol: 'µA', factor: 1e6),
      ],
    ),
    CategoryDefinition(
      name: 'Resistance',
      domain: dElec,
      icon: Icons.power_input,
      units: [
        UnitDefinition(name: 'Ohm', symbol: 'Ω', factor: 1.0),
        UnitDefinition(name: 'Kilo-ohm', symbol: 'kΩ', factor: 0.001),
        UnitDefinition(name: 'Mega-ohm', symbol: 'MΩ', factor: 1e-6),
      ],
    ),
    CategoryDefinition(
      name: 'Capacitance',
      domain: dElec,
      icon: Icons.battery_full,
      units: [
        UnitDefinition(name: 'Farad', symbol: 'F', factor: 1.0),
        UnitDefinition(name: 'Microfarad', symbol: 'µF', factor: 1e6),
        UnitDefinition(name: 'Nanofarad', symbol: 'nF', factor: 1e9),
        UnitDefinition(name: 'Picofarad', symbol: 'pF', factor: 1e12),
      ],
    ),
    // NEW: Inductance
    CategoryDefinition(
      name: 'Inductance',
      domain: dElec,
      icon: Icons.settings_input_component,
      units: [
        UnitDefinition(name: 'Henry', symbol: 'H', factor: 1.0),
        UnitDefinition(name: 'Millihenry', symbol: 'mH', factor: 1000.0),
        UnitDefinition(name: 'Microhenry', symbol: 'µH', factor: 1e6),
      ],
    ),

    // NEW: Electric Charge
    CategoryDefinition(
      name: 'Electric Charge',
      domain: dElec,
      icon: Icons.battery_charging_full,
      units: [
        UnitDefinition(name: 'Coulomb', symbol: 'C', factor: 1.0),
        UnitDefinition(name: 'Ampere-hour', symbol: 'Ah', factor: 1 / 3600),
        UnitDefinition(name: 'Milliampere-hour', symbol: 'mAh', factor: 3.6),
      ],
    ),

    // NEW: Electrical Power
    CategoryDefinition(
      name: 'Electrical Power',
      domain: dElec,
      icon: Icons.power_settings_new,
      units: [
        UnitDefinition(name: 'Watt', symbol: 'W', factor: 1.0),
        UnitDefinition(name: 'Volt-Ampere', symbol: 'VA', factor: 1.0),
        UnitDefinition(name: 'VAR', symbol: 'VAR', factor: 1.0),
      ],
    ),

    // --- COMPUTING ---
    CategoryDefinition(
      name: 'Data Size',
      domain: dComp,
      icon: Icons.data_usage,
      units: [
        UnitDefinition(name: 'Byte', symbol: 'B', factor: 1.0),
        UnitDefinition(name: 'Bit', symbol: 'b', factor: 8.0),
        UnitDefinition(name: 'Kilobyte', symbol: 'KB', factor: 1 / 1024),
        UnitDefinition(
          name: 'Megabyte',
          symbol: 'MB',
          factor: 1 / (1024 * 1024),
        ),
        UnitDefinition(
          name: 'Gigabyte',
          symbol: 'GB',
          factor: 1 / (1024 * 1024 * 1024),
        ),
        UnitDefinition(
          name: 'Terabyte',
          symbol: 'TB',
          factor: 1 / (1024 * 1024 * 1024 * 1024),
        ),
      ],
    ),
    CategoryDefinition(
      name: 'Data Rate',
      domain: dComp,
      icon: Icons.wifi,
      units: [
        UnitDefinition(name: 'bps', symbol: 'bps', factor: 1.0),
        UnitDefinition(name: 'kbps', symbol: 'kbps', factor: 1e-3),
        UnitDefinition(name: 'Mbps', symbol: 'Mbps', factor: 1e-6),
        UnitDefinition(name: 'Gbps', symbol: 'Gbps', factor: 1e-9),
      ],
    ),

    // --- PRACTICAL / EVERYDAY ---
    CategoryDefinition(
      name: 'Fuel Efficiency',
      domain: dPrac,
      icon: Icons.local_gas_station,
      units: [
        UnitDefinition(name: 'Kilometer / Liter', symbol: 'km/L', factor: 1.0),
        UnitDefinition(
          name: 'Miles / Gallon (US)',
          symbol: 'mpg',
          factor: 2.35215,
        ),
        // L/100km is inverse, requires a custom formula
        UnitDefinition(
          name: 'L/100km',
          symbol: 'L/100',
          toBase: (v) => 100 / v,
          fromBase: (v) => 100 / v,
        ),
      ],
    ),
    CategoryDefinition(
      name: 'Light',
      domain: dPrac,
      icon: Icons.light_mode,
      units: [
        UnitDefinition(name: 'Lumen', symbol: 'lm', factor: 1.0),
        UnitDefinition(name: 'Lux', symbol: 'lx', factor: 1.0),
        UnitDefinition(name: 'Candela', symbol: 'cd', factor: 1.0),
      ],
    ),
    CategoryDefinition(
      name: 'Temperature',
      domain: dPhysics,
      icon: Icons.thermostat,
      units: [
        UnitDefinition(
          name: 'Celsius',
          symbol: '°C',
          toBase: (v) => v + 273.15,
          fromBase: (v) => v - 273.15,
        ),
        UnitDefinition(
          name: 'Fahrenheit',
          symbol: '°F',
          toBase: (v) => (v - 32) * 5 / 9 + 273.15,
          fromBase: (v) => (v - 273.15) * 9 / 5 + 32,
        ),
        UnitDefinition(name: 'Kelvin', symbol: 'K', factor: 1.0),
      ],
    ),

    CategoryDefinition(
      name: 'Speed',
      domain: dPhysics,
      icon: Icons.speed,
      units: [
        UnitDefinition(name: 'Meters/sec', symbol: 'm/s', factor: 1.0),
        UnitDefinition(name: 'Km/hour', symbol: 'km/h', factor: 3.6),
        UnitDefinition(name: 'Miles/hour', symbol: 'mph', factor: 2.23694),
        UnitDefinition(name: 'Knots', symbol: 'kn', factor: 1.94384),
      ],
    ),

    // ================= CHEMISTRY =================
    CategoryDefinition(
      name: 'Amount of Substance',
      domain: dChem,
      icon: Icons.science,
      units: [UnitDefinition(name: 'Mole', symbol: 'mol', factor: 1.0)],
    ),

    // Update Concentration with all missing units
    CategoryDefinition(
      name: 'Concentration',
      domain: dChem,
      icon: Icons.science,
      units: [
        UnitDefinition(name: 'Molarity', symbol: 'mol/L', factor: 1.0),
        UnitDefinition(name: 'Molality', symbol: 'mol/kg', factor: 1.0),
        UnitDefinition(name: 'Normality', symbol: 'N', factor: 1.0),
        UnitDefinition(name: 'ppm', symbol: 'ppm', factor: 1e6),
        UnitDefinition(name: 'ppb', symbol: 'ppb', factor: 1e9),
        // Note: Mass/Volume percent would need special handling
      ],
    ),

    // NEW: Reaction Rate
    CategoryDefinition(
      name: 'Reaction Rate',
      domain: dChem,
      icon: Icons.timeline,
      units: [
        UnitDefinition(name: 'mol/L·s', symbol: 'mol/L·s', factor: 1.0),
        UnitDefinition(name: 's⁻¹', symbol: 's⁻¹', factor: 1.0),
      ],
    ),

    // NEW: Gas Volume (Same as regular volume but under Chemistry)
    CategoryDefinition(
      name: 'Gas Volume',
      domain: dChem,
      icon: Icons.air,
      units: [
        UnitDefinition(name: 'Liter', symbol: 'L', factor: 1.0),
        UnitDefinition(name: 'Cubic Meter', symbol: 'm³', factor: 0.001),
        UnitDefinition(name: 'Milliliter', symbol: 'mL', factor: 1000.0),
      ],
    ),

    // ================= BIOLOGY / MEDICAL =================
    // NEW: Mass (Small Scale)
    CategoryDefinition(
      name: 'Mass (Micro)',
      domain: dBio,
      icon: Icons.balance,
      units: [
        UnitDefinition(name: 'Gram', symbol: 'g', factor: 1.0),
        UnitDefinition(name: 'Milligram', symbol: 'mg', factor: 1000.0),
        UnitDefinition(name: 'Microgram', symbol: 'µg', factor: 1e6),
        UnitDefinition(name: 'Nanogram', symbol: 'ng', factor: 1e9),
      ],
    ),

    // NEW: Length (Microscopic)
    CategoryDefinition(
      name: 'Length (Micro)',
      domain: dBio,
      icon: Icons.zoom_in,
      units: [
        UnitDefinition(name: 'Micrometer', symbol: 'µm', factor: 1.0),
        UnitDefinition(name: 'Nanometer', symbol: 'nm', factor: 1000.0),
        UnitDefinition(name: 'Angstrom', symbol: 'Å', factor: 10000.0),
      ],
    ),

    // Update Medical Volume
    CategoryDefinition(
      name: 'Volume (Medical)',
      domain: dBio,
      icon: Icons.medical_services,
      units: [
        UnitDefinition(name: 'Milliliter', symbol: 'mL', factor: 1.0),
        UnitDefinition(name: 'Microliter', symbol: 'µL', factor: 1000.0),
        UnitDefinition(name: 'Drop', symbol: 'gtt', factor: 20.0), // ~0.05mL
      ],
    ),

    // NEW: Concentration (Bio)
    CategoryDefinition(
      name: 'Bio Concentration',
      domain: dBio,
      icon: Icons.colorize,
      units: [
        UnitDefinition(name: 'mg/mL', symbol: 'mg/mL', factor: 1.0),
        UnitDefinition(name: 'µg/mL', symbol: 'µg/mL', factor: 1000.0),
        // Note: IU is substance-specific, can't be converted generally
      ],
    ),

    // NEW: Blood Pressure
    CategoryDefinition(
      name: 'Blood Pressure',
      domain: dBio,
      icon: Icons.monitor_heart,
      units: [
        UnitDefinition(name: 'mmHg', symbol: 'mmHg', factor: 1.0),
        UnitDefinition(name: 'kPa', symbol: 'kPa', factor: 0.133322),
      ],
    ),
    CategoryDefinition(
      name: 'Heart Rate',
      domain: dBio,
      icon: Icons.favorite,
      units: [
        UnitDefinition(name: 'Beats per Minute', symbol: 'bpm', factor: 1.0),
      ],
    ),

    // ================= ENGINEERING =================
    CategoryDefinition(
      name: 'Torque',
      domain: dEng,
      icon: Icons.settings,
      units: [
        UnitDefinition(name: 'Newton-meter', symbol: 'N·m', factor: 1.0),
        UnitDefinition(name: 'Pound-foot', symbol: 'lb·ft', factor: 0.737562),
      ],
    ),
    // NEW: Stress / Young's Modulus
    CategoryDefinition(
      name: 'Stress',
      domain: dEng,
      icon: Icons.straighten,
      units: [
        UnitDefinition(name: 'Pascal', symbol: 'Pa', factor: 1.0),
        UnitDefinition(name: 'Megapascal', symbol: 'MPa', factor: 1e-6),
        UnitDefinition(name: 'Gigapascal', symbol: 'GPa', factor: 1e-9),
        UnitDefinition(name: 'PSI', symbol: 'psi', factor: 0.000145038),
      ],
    ),

    // NEW: Strain
    CategoryDefinition(
      name: 'Strain',
      domain: dEng,
      icon: Icons.compress,
      units: [
        UnitDefinition(name: 'Unitless', symbol: '', factor: 1.0),
        UnitDefinition(name: 'Percent', symbol: '%', factor: 100.0),
      ],
    ),

    // NEW: Flow Rate
    CategoryDefinition(
      name: 'Flow Rate',
      domain: dEng,
      icon: Icons.water_drop,
      units: [
        UnitDefinition(name: 'm³/s', symbol: 'm³/s', factor: 1.0),
        UnitDefinition(name: 'L/s', symbol: 'L/s', factor: 1000.0),
        UnitDefinition(name: 'L/min', symbol: 'L/min', factor: 60000.0),
        UnitDefinition(name: 'CFM', symbol: 'CFM', factor: 2118.88),
        UnitDefinition(name: 'Gallon/min', symbol: 'GPM', factor: 15850.3),
      ],
    ),

    // NEW: Viscosity
    CategoryDefinition(
      name: 'Viscosity',
      domain: dEng,
      icon: Icons.water,
      units: [
        UnitDefinition(name: 'Pascal-second', symbol: 'Pa·s', factor: 1.0),
        UnitDefinition(name: 'Poise', symbol: 'P', factor: 10.0),
        UnitDefinition(name: 'Centipoise', symbol: 'cP', factor: 1000.0),
      ],
    ),

    // NEW: Rotational Speed
    CategoryDefinition(
      name: 'Rotational Speed',
      domain: dEng,
      icon: Icons.rotate_right,
      units: [
        UnitDefinition(name: 'RPM', symbol: 'RPM', factor: 1.0),
        UnitDefinition(
          name: 'rad/s',
          symbol: 'rad/s',
          factor: 60 / (2 * 3.14159),
        ),
        UnitDefinition(name: 'Degrees/s', symbol: '°/s', factor: 6.0),
      ],
    ),

    // ================= GEOGRAPHY =================
    CategoryDefinition(
      name: 'Land Area',
      domain: dGeo,
      icon: Icons.map,
      units: [
        UnitDefinition(name: 'Square Kilometer', symbol: 'km²', factor: 1.0),
        UnitDefinition(name: 'Hectare', symbol: 'ha', factor: 100.0),
        UnitDefinition(name: 'Acre', symbol: 'ac', factor: 247.105),
      ],
    ),
    // NEW: Elevation / Depth
    CategoryDefinition(
      name: 'Elevation',
      domain: dGeo,
      icon: Icons.terrain,
      units: [
        UnitDefinition(name: 'Meter', symbol: 'm', factor: 1.0),
        UnitDefinition(name: 'Foot', symbol: 'ft', factor: 3.28084),
        UnitDefinition(name: 'Kilometer', symbol: 'km', factor: 0.001),
        UnitDefinition(name: 'Mile', symbol: 'mi', factor: 0.000621371),
      ],
    ),

    // NEW: Geographic Coordinates
    CategoryDefinition(
      name: 'Coordinates',
      domain: dGeo,
      icon: Icons.location_on,
      units: [
        UnitDefinition(name: 'Degree', symbol: '°', factor: 1.0),
        UnitDefinition(name: 'Minute', symbol: '′', factor: 60.0),
        UnitDefinition(name: 'Second', symbol: '″', factor: 3600.0),
      ],
    ),

    // TODO: Seismic Energy (Richter/Moment magnitude) uses logarithmic scale
    // and cannot be converted linearly - would need special handling

    // ==================== ADDITIONAL USEFUL CATEGORIES ====================

    // NEW: Sound / Acoustics Domain
    // Add to domains: static const String dSound = "Sound / Acoustics";

    // NEW: Sound Level
    CategoryDefinition(
      name: 'Sound Level',
      domain: dSound,
      icon: Icons.volume_up,
      units: [
        UnitDefinition(name: 'Decibel', symbol: 'dB', factor: 1.0),
        // Note: dB is logarithmic and context-dependent
      ],
    ),

    // NEW: Sound Frequency (could also go under Physics)
    CategoryDefinition(
      name: 'Audio Frequency',
      domain: dSound,
      icon: Icons.audiotrack,
      units: [
        UnitDefinition(name: 'Hertz', symbol: 'Hz', factor: 1.0),
        UnitDefinition(name: 'Kilohertz', symbol: 'kHz', factor: 0.001),
      ],
    ),

    // NEW: Optics / Light Domain
    // Add to domains: static const String dOpt = "Optics / Light";

    // NEW: Wavelength
    CategoryDefinition(
      name: 'Wavelength',
      domain: dOpt,
      icon: Icons.waves,
      units: [
        UnitDefinition(name: 'Nanometer', symbol: 'nm', factor: 1.0),
        UnitDefinition(name: 'Micrometer', symbol: 'µm', factor: 0.001),
        UnitDefinition(name: 'Angstrom', symbol: 'Å', factor: 10.0),
      ],
    ),

    // NEW: Illuminance (Better than just "Light")
    CategoryDefinition(
      name: 'Illuminance',
      domain: dOpt,
      icon: Icons.light_mode,
      units: [
        UnitDefinition(name: 'Lux', symbol: 'lx', factor: 1.0),
        UnitDefinition(name: 'Foot-candle', symbol: 'fc', factor: 0.092903),
      ],
    ),

    // NEW: Luminous Intensity
    CategoryDefinition(
      name: 'Luminous Intensity',
      domain: dOpt,
      icon: Icons.lightbulb,
      units: [UnitDefinition(name: 'Candela', symbol: 'cd', factor: 1.0)],
    ),

    // NEW: Luminous Flux
    CategoryDefinition(
      name: 'Luminous Flux',
      domain: dOpt,
      icon: Icons.flare,
      units: [UnitDefinition(name: 'Lumen', symbol: 'lm', factor: 1.0)],
    ),

    // NEW: Radiation Domain
    // Add to domains: static const String dRad = "Radiation / Nuclear";

    // NEW: Radioactivity
    CategoryDefinition(
      name: 'Radioactivity',
      domain: dRad,
      icon: Icons.warning,
      units: [
        UnitDefinition(name: 'Becquerel', symbol: 'Bq', factor: 1.0),
        UnitDefinition(name: 'Curie', symbol: 'Ci', factor: 2.7027e-11),
      ],
    ),

    // NEW: Absorbed Dose
    CategoryDefinition(
      name: 'Radiation Dose',
      domain: dRad,
      icon: Icons.shield,
      units: [
        UnitDefinition(name: 'Gray', symbol: 'Gy', factor: 1.0),
        UnitDefinition(name: 'Rad', symbol: 'rad', factor: 100.0),
        UnitDefinition(name: 'Sievert', symbol: 'Sv', factor: 1.0),
        UnitDefinition(name: 'Rem', symbol: 'rem', factor: 100.0),
      ],
    ),

    // NEW: Cooking / Kitchen (Practical)
    CategoryDefinition(
      name: 'Cooking Volume',
      domain: dPrac,
      icon: Icons.restaurant,
      units: [
        UnitDefinition(name: 'Cup', symbol: 'cup', factor: 1.0),
        UnitDefinition(name: 'Tablespoon', symbol: 'tbsp', factor: 16.0),
        UnitDefinition(name: 'Teaspoon', symbol: 'tsp', factor: 48.0),
        UnitDefinition(name: 'Milliliter', symbol: 'mL', factor: 236.588),
        UnitDefinition(name: 'Fluid Ounce', symbol: 'fl oz', factor: 8.0),
      ],
    ),

    // NEW: Cooking Mass
    CategoryDefinition(
      name: 'Cooking Mass',
      domain: dPrac,
      icon: Icons.kitchen,
      units: [
        UnitDefinition(name: 'Gram', symbol: 'g', factor: 1.0),
        UnitDefinition(name: 'Kilogram', symbol: 'kg', factor: 0.001),
        UnitDefinition(name: 'Ounce', symbol: 'oz', factor: 0.035274),
        UnitDefinition(name: 'Pound', symbol: 'lb', factor: 0.00220462),
      ],
    ),

    // TODO: Printing / Paper
    CategoryDefinition(
      name: 'Paper Size',
      domain: dPrac,
      icon: Icons.print,
      units: [
        // These would need special handling as they're not linear conversions
        // Could just show common sizes as reference
      ],
    ),

    // TODO: Shoe Size
    CategoryDefinition(
      name: 'Shoe Size',
      domain: dPrac,
      icon: Icons.hiking,
      units: [
        // US, UK, EU sizes - would need lookup tables
      ],
    ),
  ];
}
