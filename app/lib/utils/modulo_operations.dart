class ModuloOperations {
  static int _checkMod(int mod) {
    if (mod <= 0) {
      throw Exception('Modulo must be positive');
    }
    return mod;
  }

  static int _norm(int x, int mod) {
    return ((x % mod) + mod) % mod;
  }

  static int add(int a, int b, int mod) {
    mod = _checkMod(mod);
    return _norm(a + b, mod);
  }

  static int subtract(int a, int b, int mod) {
    mod = _checkMod(mod);
    return _norm(a - b, mod);
  }

  static int multiply(int a, int b, int mod) {
    mod = _checkMod(mod);
    return _norm(a * b, mod);
  }

  static int power(int base, int exp, int mod) {
    mod = _checkMod(mod);
    base = _norm(base, mod);

    if (exp < 0) {
      throw Exception('Negative exponent not supported in modulo arithmetic');
    }

    int result = 1;
    while (exp > 0) {
      if (exp & 1 == 1) result = (result * base) % mod;
      exp >>= 1;
      base = (base * base) % mod;
    }
    return result;
  }

  static int inverse(int a, int mod) {
    mod = _checkMod(mod);
    a = _norm(a, mod);

    final res = _extendedGCD(a, mod);
    if (res.gcd != 1) {
      throw Exception('Inverse does not exist (numbers not coprime)');
    }
    return _norm(res.x, mod);
  }

  static _EGCDResult _extendedGCD(int a, int b) {
    if (b == 0) {
      return _EGCDResult(a, 1, 0);
    }
    final r = _extendedGCD(b, a % b);
    return _EGCDResult(r.gcd, r.y, r.x - (a ~/ b) * r.y);
  }
}

class _EGCDResult {
  final int gcd;
  final int x;
  final int y;

  const _EGCDResult(this.gcd, this.x, this.y);
}
