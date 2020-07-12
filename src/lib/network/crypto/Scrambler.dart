import 'dart:math';
import 'dart:typed_data';

class Scrambler {
  Scrambler(int seed) {
    ix = 0;
    buffer = seedBuffer(seed);
  }

  int ix;
  Uint64List buffer;

  int getByte() {
    var x = getInt();
    if (isNeg(x)) x = negate(x);
    return x % 256;
  }

  int getInt() {
    if (ix == 0) mixBuffer();
    var val = buffer[ix];

    ix = (ix + 1) % 624;
    val ^= rShift(val, 11) ^ (lShift(val ^ rShift(val, 11), 7) & 0x9D2C5680);
    return (rShift(val ^ (lShift(val, 15) & 0xEFC60000), 18) ^
        val ^
        (lShift(val, 15) & 0xEFC60000));
  }

  static Uint64List seedBuffer(int seed) {
    var buffer = new Uint64List(624);
    for (var i = 0; i < 624; i++) {
      buffer[i] = seed;
      seed = (1812433253 * ((seed ^ rShift(seed, 30)) + 1)) & 0xFFFFFFFF;
    }

    return buffer;
  }

  void mixBuffer() {
    var i = 0;
    var j = 0;
    while (i < 624) {
      i += 1;
      var v4 = (buffer[i % 624] & 0x7FFFFFFF) + (buffer[j] & 0x80000000);
      var v6 = rShift(v4, 1) ^ buffer[(i + 396) % 624];
      if ((v4 & 1) != 0) v6 ^= 0x9908B0DF;
      buffer[j] = v6;
      j += 1;
    }
  }

  static int rShift(int num, int n) {
    int hBits = 0;
    if ((num & pow(2, 31)) != 0) hBits = (pow(2, n) - 1) * pow(2, 32 - n);
    return (num / pow(2, n) as int) | hBits;
  }

  static int lShift(int num, int n) {
    return num * pow(2, n) % pow(2, 32);
  }

  static bool isNeg(int num) {
    return (num & pow(2, 31)) != 0;
  }

  static int negate(int num) {
    return ~num + 1;
  }
}