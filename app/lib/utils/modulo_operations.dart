class ModuloOperations {
  static int add(int a, int b, int mod) {
    return (a + b) % mod;
  }

  static int subtract(int a, int b, int mod) {
    return (a - b) % mod;
  }

  static int multiply(int a, int b, int mod) {
    return (a * b) % mod;
  }

  static int power(int base, int exp, int mod) {
    int result = 1;
    base = base % mod;
    while (exp > 0) {
      if (exp % 2 == 1) result = (result * base) % mod;
      exp = exp >> 1;
      base = (base * base) % mod;
    }
    return result;
  }

  static int inverse(int a, int mod) {
    final gcd = _extendedGCD(a, mod);
    if (gcd[0] != 1) throw Exception('Inverse does not exist');
    return (gcd[1] % mod + mod) % mod;
  }

  static List<int> _extendedGCD(int a, int b) {
    if (b == 0) return [a, 1, 0];
    final result = _extendedGCD(b, a % b);
    final x = result[2];
    final y = result[1] - (a ~/ b) * result[2];
    return [result[0], x, y];
  }
}
