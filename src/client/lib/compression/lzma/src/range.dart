/*
Copyright (c) 2012 Juan Mellado

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/*
References:
- "LZMA SDK" by Igor Pavlov
  http://www.7-zip.org/sdk.html
*/

part of lzma;

class RangeDecoder {
  static const int _kTopMask = 0xff000000;

  static const int _kNumBitModelTotalBits = 11;
  static const int _kBitModelTotal = 1 << _kNumBitModelTotalBits;
  static const int _kNumMoveBits = 5;

  int _range;
  int _code;

  InStream _stream;

  void setStream(InStream stream) {
    _stream = stream;
  }

  void releaseStream() {
    _stream = null;
  }

  void init() {
    _code = 0;
    _range = -1;

    for (var i = 0; i < 5; ++ i) {
      _code = (_code << 8) | _stream.read();
    }
  }

  int decodeDirectBits(int numTotalBits) {
    var result = 0;

    for (var i = numTotalBits; i > 0; -- i) {
      _range = (_range >> 1) & 0x7fffffff;
      var t = ((_code - _range) >> 31) & 1;
      _code -= _range & (t - 1);
      result = (result << 1) | (1 - t);

      if ((_range & _kTopMask) == 0) {
        _code = (_code << 8) | _stream.read();
        _range <<= 8;
      }
    }

    return result;
  }

  int decodeBit(List<int> probs, int index) {
    int prob = probs[index];

    var newBound = ((_range >>_kNumBitModelTotalBits) & 0x1fffff) * prob;

    if ((new Int32(_code) ^ 0x80000000) < (new Int32(newBound) ^ 0x80000000)) {
      _range = newBound;
      probs[index] = prob + ((_kBitModelTotal - prob) >> _kNumMoveBits);

      if ((_range & _kTopMask) == 0) {
        _code = (_code << 8) | _stream.read();
        _range <<= 8;
      }

      return 0;
    }

    _range -= newBound;
    _code -= newBound;
    probs[index] = prob - ((prob >> _kNumMoveBits) & 0x7ffffff);

    if ((_range & _kTopMask) == 0) {
      _code = (_code << 8) | _stream.read();
      _range <<= 8;
    }

    return 1;
  }

  static void initBitModels(List<int> probs) {
    for (var i = 0; i < probs.length; ++ i) {
      probs[i] = _kBitModelTotal >> 1;
    }
  }
}

class RangeEncoder {
  static const int _kTopMask = 0xff000000;
  static const int _kNumBitModelTotalBits = 11;
  static const int _kBitModelTotal = 1 << _kNumBitModelTotalBits;
  static const int _kNumMoveBits = 5;

  OutStream _stream;

  Int64 _low;
  int _range;
  int _cacheSize;
  int _cache;

  int _position;

  void setStream(OutStream stream) {
    _stream = stream;
  }

  void releaseStream() {
    _stream = null;
  }

  void init() {
    _position = 0;
    _low = Int64.ZERO;
    _range = -1;
    _cacheSize = 1;
    _cache = 0;
  }

  void flushData() {
    for (var i = 0; i < 5; ++ i) {
      shiftLow();
    }
  }

  void flushStream() {
    _stream.flush();
  }

  void shiftLow(){
    var lowHi = _low.shiftRightUnsigned(32).toInt();
    if ((lowHi != 0) || (_low < 0xff000000)) {
      _position += _cacheSize;
      var temp = _cache;
      do {
        _stream.write((temp + lowHi) & 0xff);
        temp = 0xff;
      } while (-- _cacheSize != 0);
      _cache = _low.toInt32().shiftRightUnsigned(24).toInt();
    }
    ++ _cacheSize;
    _low = (_low & 0xffffff) << 8;
  }

  void encodeDirectBits(int v, int numTotalBits) {
    for (var i = numTotalBits - 1; i >= 0; -- i) {
      _range = (_range >> 1) & 0x7fffffff;
      if (((v >> i) & 1) == 1) {
        _low += _range;
      }
      if ((_range & _kTopMask) == 0){
        _range <<= 8;
        shiftLow();
      }
    }
  }

  int getProcessedSizeAdd() => _cacheSize + _position + 4;

  static const int _kNumMoveReducingBits = 2;
  static const int _kNumBitPriceShiftBits = 6;

  static void initBitModels(List<int> probs) {
    for (var i = 0; i < probs.length; ++ i) {
      probs[i] = _kBitModelTotal >> 1;
    }
  }

  void encode(List<int> probs, int index, int symbol) {
    int prob = probs[index];

    var newBound = ((_range >> _kNumBitModelTotalBits) & 0x1fffff) * prob;

    if (symbol == 0) {
      _range = newBound;
      probs[index] = prob + ((_kBitModelTotal - prob) >> _kNumMoveBits);
    } else {
      _low += new Int64(0xffffffff) & newBound;
      _range -= newBound;
      probs[index] = prob - (prob >> _kNumMoveBits);
    }
    if ((_range & _kTopMask) == 0) {
      _range <<= 8;
      shiftLow();
    }
  }

  static final List<int> _probPrices = _buildProbPrices();

  static List<int> _buildProbPrices() {
    var probPrices = new List<int>(_kBitModelTotal >> _kNumMoveReducingBits);

    probPrices[0] = 0;

    var kNumBits = _kNumBitModelTotalBits - _kNumMoveReducingBits;
    for (var i = kNumBits - 1; i >= 0; -- i) {
      var start = 1 << (kNumBits - i - 1);
      var end = 1 << (kNumBits - i);
      for (var j = start; j < end; ++ j) {
        probPrices[j] = (i << _kNumBitPriceShiftBits) +
            (((end - j) << _kNumBitPriceShiftBits) >> (kNumBits - i - 1));
      }
    }

    return probPrices;
  }

  static int getPrice(int prob, int symbol) =>
    _probPrices[((new Int32(prob - symbol) ^ new Int32(-symbol)).toInt()
        & (_kBitModelTotal - 1)) >> _kNumMoveReducingBits];

  static int getPrice0(int prob) =>
    _probPrices[prob >> _kNumMoveReducingBits];

  static int getPrice1(int prob) =>
    _probPrices[(_kBitModelTotal - prob) >> _kNumMoveReducingBits];
}

class BitTreeDecoder {
  final List<int> _models;
  final int _numBitLevels;

  BitTreeDecoder(int numBitLevels)
    : _numBitLevels = numBitLevels,
      _models = new List<int>(1 << numBitLevels);

  void init() {
    RangeDecoder.initBitModels(_models);
  }

  int decode(RangeDecoder rangeDecoder) {
    var m = 1;
    for (var i = _numBitLevels; i > 0; -- i) {
      m = (m << 1) | rangeDecoder.decodeBit(_models, m);
    }
    return m - (1 << _numBitLevels);
  }

  int reverseDecode(RangeDecoder rangeDecoder) {
    var m = 1, symbol = 0;
    for (var i = 0; i < _numBitLevels; ++ i) {
      var bit = rangeDecoder.decodeBit(_models, m);
      m = (m << 1) | bit;
      symbol |= bit << i;
    }
    return symbol;
  }

  static int reverseDecode2(List<int>models, int startIndex,
                            RangeDecoder rangeDecoder, int numBitLevels) {
    var m = 1, symbol = 0;
    for (var i = 0; i < numBitLevels; ++ i) {
      var bit = rangeDecoder.decodeBit(models, startIndex + m);
      m = (m << 1) | bit;
      symbol |= bit << i;
    }
    return symbol;
  }
}

class BitTreeEncoder {
  final List<int> _models;
  final int _numBitLevels;

  BitTreeEncoder(int numBitLevels)
    : _numBitLevels = numBitLevels,
      _models = new List(1 << numBitLevels);

  void init() {
    RangeDecoder.initBitModels(_models);
  }

  void encode(RangeEncoder rangeEncoder, int symbol) {
    var m = 1;
    for (var bitIndex = _numBitLevels; bitIndex > 0;) {
      -- bitIndex;
      var bit = (symbol >> bitIndex) & 1;
      rangeEncoder.encode(_models, m, bit);
      m = (m << 1) | bit;
    }
  }

  void reverseEncode(RangeEncoder rangeEncoder, int symbol) {
    var m = 1;
    for (var i = 0; i < _numBitLevels; ++ i) {
      var bit = symbol & 1;
      rangeEncoder.encode(_models, m, bit);
      m = (m << 1) | bit;
      symbol >>= 1;
    }
  }

  int getPrice(int symbol) {
    var price = 0;
    var m = 1;
    for (var bitIndex = _numBitLevels; bitIndex > 0;) {
      -- bitIndex;
      var bit = (symbol >> bitIndex) & 1;
      price += RangeEncoder.getPrice(_models[m], bit);
      m = (m << 1) | bit;
    }
    return price;
  }

  int reverseGetPrice(int symbol) {
    var price = 0;
    var m = 1;
    for (var i = _numBitLevels; i > 0; -- i) {
      var bit = symbol & 1;
      symbol >>= 1;
      price += RangeEncoder.getPrice(_models[m], bit);
      m = (m << 1) | bit;
    }
    return price;
  }

  static int reverseGetPrice2(List<int> models, int startIndex,
      int numBitLevels, int symbol) {
    var price = 0;
    var m = 1;
    for (var i = numBitLevels; i > 0; -- i) {
      var bit = symbol & 1;
      symbol >>= 1;
      price += RangeEncoder.getPrice(models[startIndex + m], bit);
      m = (m << 1) | bit;
    }
    return price;
  }

  static void reverseEncode2(List<int> models, int startIndex,
      RangeEncoder rangeEncoder, int numBitLevels, int symbol) {
    var m = 1;
    for (var i = 0; i < numBitLevels; ++ i) {
      var bit = symbol & 1;
      rangeEncoder.encode(models, startIndex + m, bit);
      m = (m << 1) | bit;
      symbol >>= 1;
    }
  }
}
