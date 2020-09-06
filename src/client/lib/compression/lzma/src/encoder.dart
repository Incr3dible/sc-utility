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

class Params {
  int dictionarySize = 23;
  int fb = 128;
  int matchFinder = Encoder.EMatchFinderTypeBT4;
  int lc = 3;
  int lp = 0;
  int pb = 2;
  bool eos = false;
}

void compress(InStream inStream, OutStream outStream, [Params params]) {
  var encoder = new Encoder();

  if (params == null) {
    params = new Params();
  }

  if (!encoder.setDictionarySize(1 << params.dictionarySize)) {
    throw new Exception("Incorrect dictionary size");
  }
  if (!encoder.setNumFastBytes(params.fb)) {
    throw new Exception("Incorrect -fb value");
  }
  if (!encoder.setMatchFinder(params.matchFinder)) {
    throw new Exception("Incorrect -mf value");
  }
  if (!encoder.setLcLpPb(params.lc, params.lp, params.pb)) {
    throw new Exception("Incorrect -lc or -lp or -pb value");
  }
  encoder.setEndMarkerMode(params.eos);

  encoder.writeCoderProperties(outStream);

  var fileSize = params.eos ? -1 : inStream.length();
  for (var i = 0; i < 8; ++ i) {
    outStream.write((fileSize >> (8 * i)) & 0xff);
  }

  encoder.code(inStream, outStream, -1, -1);
}

class Encoder2 {
  final List<int> _encoders = new List<int>(0x300);

  void init() {
    RangeEncoder.initBitModels(_encoders);
  }

  void encode(RangeEncoder rangeEncoder, int symbol) {
    var context = 1;
    for (var i = 7; i >= 0; -- i) {
      var bit = (symbol >> i) & 1;
      rangeEncoder.encode(_encoders, context, bit);
      context = (context << 1) | bit;
    }
  }

  void encodeMatched(RangeEncoder rangeEncoder, int matchByte, int symbol) {
    var context = 1;
    var same = true;
    for (var i = 7; i >= 0; -- i) {
      var bit = (symbol >> i) & 1;
      var state = context;
      if (same) {
        int matchBit = (matchByte >> i) & 1;
        state += (1 + matchBit) << 8;
        same = (matchBit == bit);
      }
      rangeEncoder.encode(_encoders, state, bit);
      context = (context << 1) | bit;
    }
  }

  int getPrice(bool matchMode, int matchByte, int symbol) {
    var price = 0;
    var context = 1;
    var i = 7;
    if (matchMode) {
      for (; i >= 0; -- i) {
        int matchBit = (matchByte >> i) & 1;
        var bit = (symbol >> i) & 1;
        price += RangeEncoder.getPrice(_encoders[((1 + matchBit) << 8) + context], bit);
        context = (context << 1) | bit;
        if (matchBit != bit) {
          -- i;
          break;
        }
      }
    }
    for (; i >= 0; -- i) {
      var bit = (symbol >> i) & 1;
      price += RangeEncoder.getPrice(_encoders[context], bit);
      context = (context << 1) | bit;
    }
    return price;
  }
}

class LiteralEncoder {
  List<Encoder2> _coders;
  int _numPrevBits;
  int _numPosBits;
  int _pPosMask;

  void create(int numPosBits, int numPrevBits) {
    if ((_coders != null) && (_numPrevBits == numPrevBits) && (_numPosBits == numPosBits)) {
      return;
    }
    _numPosBits = numPosBits;
    _pPosMask = (1 << numPosBits) - 1;
    _numPrevBits = numPrevBits;
    var numStates = 1 << (_numPrevBits + _numPosBits);
    _coders = new List<Encoder2>(numStates);
    for (var i = 0; i < numStates; ++ i) {
      _coders[i] = new Encoder2();
    }
  }

  void init() {
    var numStates = 1 << (_numPrevBits + _numPosBits);
    for (var i = 0; i < numStates;  ++ i) {
      _coders[i].init();
    }
  }

  Encoder2 getSubCoder(int pos, int prevByte) =>
    _coders[((pos & _pPosMask) << _numPrevBits) + ((prevByte & 0xFF) >> (8 - _numPrevBits))];
}

class LenEncoder {
  final List<int> _choice = new List<int>(2);
  final List<BitTreeEncoder> _lowCoder = new List<BitTreeEncoder>(Base.kNumPosStatesEncodingMax);
  final List<BitTreeEncoder> _midCoder = new List<BitTreeEncoder>(Base.kNumPosStatesEncodingMax);
  final BitTreeEncoder _highCoder = new BitTreeEncoder(Base.kNumHighLenBits);

  LenEncoder() {
    for (var posState = 0; posState < Base.kNumPosStatesEncodingMax; ++ posState) {
      _lowCoder[posState] = new BitTreeEncoder(Base.kNumLowLenBits);
      _midCoder[posState] = new BitTreeEncoder(Base.kNumMidLenBits);
    }
  }

  void init(int numPosStates) {
    RangeEncoder.initBitModels(_choice);

    for (var posState = 0; posState < numPosStates; ++ posState) {
      _lowCoder[posState].init();
      _midCoder[posState].init();
    }
    _highCoder.init();
  }

   void encode(RangeEncoder rangeEncoder, int symbol, int posState) {
    if (symbol < Base.kNumLowLenSymbols) {
      rangeEncoder.encode(_choice, 0, 0);
      _lowCoder[posState].encode(rangeEncoder, symbol);
    } else {
      symbol -= Base.kNumLowLenSymbols;
      rangeEncoder.encode(_choice, 0, 1);
      if (symbol < Base.kNumMidLenSymbols) {
        rangeEncoder.encode(_choice, 1, 0);
        _midCoder[posState].encode(rangeEncoder, symbol);
      } else {
        rangeEncoder.encode(_choice, 1, 1);
        _highCoder.encode(rangeEncoder, symbol - Base.kNumMidLenSymbols);
      }
    }
  }

  void setPrices(int posState, int numSymbols, List<int> prices, int st) {
    var a0 = RangeEncoder.getPrice0(_choice[0]);
    var a1 = RangeEncoder.getPrice1(_choice[0]);
    var b0 = a1 + RangeEncoder.getPrice0(_choice[1]);
    var b1 = a1 + RangeEncoder.getPrice1(_choice[1]);
    var i = 0;
    for (i = 0; i < Base.kNumLowLenSymbols; ++ i) {
      if (i >= numSymbols) {
        return;
      }
      prices[st + i] = a0 + _lowCoder[posState].getPrice(i);
    }
    for (; i < Base.kNumLowLenSymbols + Base.kNumMidLenSymbols; ++ i) {
      if (i >= numSymbols) {
        return;
      }
      prices[st + i] = b0 + _midCoder[posState].getPrice(i - Base.kNumLowLenSymbols);
    }
    for (; i < numSymbols; i++) {
      prices[st + i] = b1 + _highCoder.getPrice(i - Base.kNumLowLenSymbols - Base.kNumMidLenSymbols);
    }
  }
}

class LenPriceTableEncoder extends LenEncoder {
  final List<int> _prices = new List<int>(Base.kNumLenSymbols<<Base.kNumPosStatesBitsEncodingMax);
  int _tableSize;
  final List<int> _counters = new List<int>(Base.kNumPosStatesEncodingMax);

  void setTableSize(int tableSize) {
    _tableSize = tableSize;
  }

  int getPrice(int symbol, int posState) =>
    _prices[posState * Base.kNumLenSymbols + symbol];

  void updateTable(int posState) {
    setPrices(posState, _tableSize, _prices, posState * Base.kNumLenSymbols);
    _counters[posState] = _tableSize;
  }

  void updateTables(int numPosStates) {
    for (var posState = 0; posState < numPosStates; ++ posState) {
      updateTable(posState);
    }
  }

  void encode(RangeEncoder rangeEncoder, int symbol, int posState) {
    super.encode(rangeEncoder, symbol, posState);
    if (--_counters[posState] == 0) {
      updateTable(posState);
    }
  }
}

class Optimal {
  int state;

  bool prev1IsChar;
  bool prev2;

  int posPrev2;
  int backPrev2;

  int price;
  int posPrev;
  int backPrev;

  int backs0;
  int backs1;
  int backs2;
  int backs3;

  void makeAsChar() {
    backPrev = -1;
    prev1IsChar = false;
  }

  void makeAsShortRep() {
    backPrev = 0;
    prev1IsChar = false;
  }

  bool isShortRep() => backPrev == 0;
}

class Encoder {
  static const int EMatchFinderTypeBT2 = 0;
  static const int EMatchFinderTypeBT4 = 1;

  static const _kIfinityPrice = 0xfffffff;

  static final List<int> _fastPos = _buildFastPos();

  static List<int> _buildFastPos() {
    var fastPos = new List<int>(0x800);

    var kFastSlots = 22;
    var c = 2;
    fastPos[0] = 0;
    fastPos[1] = 1;
    for (var slotFast = 2; slotFast < kFastSlots; ++ slotFast) {
      var k = 1 << ((slotFast >> 1) - 1);
      for (var j = 0; j < k; ++ j, ++ c) {
        fastPos[c] = slotFast;
      }
    }

    return fastPos;
  }

  static int _getPosSlot(int pos) {
    if (pos < 0x800) {
      return _fastPos[pos];
    }
    if (pos < 0x200000) {
      return _fastPos[pos >> 10] + 20;
    }
    return _fastPos[pos >> 20] + 40;
  }

  static int _getPosSlot2(int pos) {
    if (pos < 0x20000) {
      return _fastPos[pos >> 6] + 12;
    }
    if (pos < 0x8000000) {
      return _fastPos[pos >> 16] + 32;
    }
    return _fastPos[pos >> 26] + 52;
  }

  int _state = Base.stateInit;
  int _previousByte;
  final List<int> _repDistances = new List<int>(Base.kNumRepDistances);

  void _baseInit() {
    _state = Base.stateInit;
    _previousByte = 0;
    for (var i = 0; i < Base.kNumRepDistances; ++ i) {
      _repDistances[i] = 0;
    }
  }

  static const int _kDefaultDictionaryLogSize = 22;
  static const int _kNumFastBytesDefault = 0x20;

  static const int _kNumOpts = 0x1000;

  final List<Optimal> _optimum = new List<Optimal>(_kNumOpts);
  BinTree _matchFinder;
  final RangeEncoder _rangeEncoder = new RangeEncoder();

  final List<int> _isMatch = new List<int>(Base.kNumStates << Base.kNumPosStatesBitsMax);
  final List<int> _isRep = new List<int>(Base.kNumStates);
  final List<int> _isRepG0 = new List<int>(Base.kNumStates);
  final List<int> _isRepG1 = new List<int>(Base.kNumStates);
  final List<int> _isRepG2 = new List<int>(Base.kNumStates);
  final List<int> _isRep0Long = new List<int>(Base.kNumStates << Base.kNumPosStatesBitsMax);

  final List<BitTreeEncoder> _posSlotEncoder = new List<BitTreeEncoder>(Base.kNumLenToPosStates);

  final List<int> _posEncoders = new List<int>(Base.kNumFullDistances - Base.kEndPosModelIndex);
  final BitTreeEncoder _posAlignEncoder = new BitTreeEncoder(Base.kNumAlignBits);

  final LenPriceTableEncoder _lenEncoder = new LenPriceTableEncoder();
  final LenPriceTableEncoder _repMatchLenEncoder = new LenPriceTableEncoder();

  final LiteralEncoder _literalEncoder = new LiteralEncoder();

  final List<int> _matchDistances = new List<int>(Base.kMatchMaxLen * 2 + 2);

  int _numFastBytes = _kNumFastBytesDefault;
  int _longestMatchLength;
  int _numDistancePairs;

  int _additionalOffset;

  int _optimumEndIndex;
  int _optimumCurrentIndex;

  bool _longestMatchWasFound;

  final List<int> _posSlotPrices = new List<int>(1 << (Base.kNumPosSlotBits + Base.kNumLenToPosStatesBits));
  final List<int> _distancesPrices = new List<int>(Base.kNumFullDistances << Base.kNumLenToPosStatesBits);
  final List<int> _alignPrices = new List<int>(Base.kAlignTableSize);
  int _alignPriceCount;

  int _distTableSize = _kDefaultDictionaryLogSize * 2;

  int _posStateBits = 2;
  int _posStateMask = 4;
  int _numLiteralPosStateBits = 0;
  int _numLiteralContextBits = 3;

  int _dictionarySize = 1 << _kDefaultDictionaryLogSize;
  int _dictionarySizePrev = -1;
  int _numFastBytesPrev = -1;

  int _nowPos64;
  bool _finished;
  InStream _inStream;

  int _matchFinderType = 1;
  bool _writeEndMark = false;

  bool _needReleaseMFStream = false;

  void _create() {
    if (_matchFinder == null) {
      var bt = new BinTree();
      var numHashBytes = 4;
      if (_matchFinderType == EMatchFinderTypeBT2) {
        numHashBytes = 2;
      }
      bt.setType(numHashBytes);
      _matchFinder = bt;
    }
    _literalEncoder.create(_numLiteralPosStateBits, _numLiteralContextBits);

    if ((_dictionarySize == _dictionarySizePrev) && (_numFastBytesPrev == _numFastBytes)) {
      return;
    }
    _matchFinder.create2(_dictionarySize, _kNumOpts, _numFastBytes, Base.kMatchMaxLen + 1);
    _dictionarySizePrev = _dictionarySize;
    _numFastBytesPrev = _numFastBytes;
  }

  Encoder() {
    for (var i = 0; i < _kNumOpts; ++ i) {
      _optimum[i] = new Optimal();
    }
    for (var i = 0; i < Base.kNumLenToPosStates; ++ i) {
      _posSlotEncoder[i] = new BitTreeEncoder(Base.kNumPosSlotBits);
    }
  }

  void setWriteEndMarkerMode(bool writeEndMarker) {
    _writeEndMark = writeEndMarker;
  }

  void _init() {
    _baseInit();
    _rangeEncoder.init();

    RangeEncoder.initBitModels(_isMatch);
    RangeEncoder.initBitModels(_isRep0Long);
    RangeEncoder.initBitModels(_isRep);
    RangeEncoder.initBitModels(_isRepG0);
    RangeEncoder.initBitModels(_isRepG1);
    RangeEncoder.initBitModels(_isRepG2);
    RangeEncoder.initBitModels(_posEncoders);

    _literalEncoder.init();
    for (var i = 0; i < Base.kNumLenToPosStates; ++ i) {
      _posSlotEncoder[i].init();
    }

    _lenEncoder.init(1 << _posStateBits);
    _repMatchLenEncoder.init(1 << _posStateBits);

    _posAlignEncoder.init();

    _longestMatchWasFound = false;
    _optimumEndIndex = 0;
    _optimumCurrentIndex = 0;
    _additionalOffset = 0;
  }

  int _readMatchDistances() {
    var lenRes = 0;
    _numDistancePairs = _matchFinder.getMatches(_matchDistances);
    if (_numDistancePairs > 0) {
      lenRes = _matchDistances[_numDistancePairs - 2];
      if (lenRes == _numFastBytes) {
        lenRes += _matchFinder.getMatchLen(lenRes - 1, _matchDistances[_numDistancePairs - 1],
          Base.kMatchMaxLen - lenRes);
      }
    }
    ++ _additionalOffset;
    return lenRes;
  }

  void _movePos(int num) {
    if (num > 0) {
      _matchFinder.skip(num);
      _additionalOffset += num;
    }
  }

  int _getRepLen1Price(int state, int posState) =>
    RangeEncoder.getPrice0(_isRepG0[state]) +
        RangeEncoder.getPrice0(_isRep0Long[(state << Base.kNumPosStatesBitsMax) + posState]);

  int _getPureRepPrice(int repIndex, int state, int posState) {
    int price;
    if (repIndex == 0) {
      price = RangeEncoder.getPrice0(_isRepG0[state]);
      price += RangeEncoder.getPrice1(_isRep0Long[(state << Base.kNumPosStatesBitsMax) + posState]);
    } else {
      price = RangeEncoder.getPrice1(_isRepG0[state]);
      if (repIndex == 1) {
        price += RangeEncoder.getPrice0(_isRepG1[state]);
      } else {
        price += RangeEncoder.getPrice1(_isRepG1[state]);
        price += RangeEncoder.getPrice(_isRepG2[state], repIndex - 2);
      }
    }
    return price;
  }

  int _getRepPrice(int repIndex, int len, int state, int posState) {
    var price = _repMatchLenEncoder.getPrice(len - Base.kMatchMinLen, posState);
    return price + _getPureRepPrice(repIndex, state, posState);
  }

  int _getPosLenPrice(int pos, int len, int posState) {
    int price;
    int lenToPosState = Base.getLenToPosState(len);
    if (pos < Base.kNumFullDistances) {
      price = _distancesPrices[(lenToPosState * Base.kNumFullDistances) + pos];
    } else {
      price = _posSlotPrices[(lenToPosState << Base.kNumPosSlotBits) + _getPosSlot2(pos)] +
        _alignPrices[pos & Base.kAlignMask];
    }
    return price + _lenEncoder.getPrice(len - Base.kMatchMinLen, posState);
  }

  int _backward(int cur) {
    _optimumEndIndex = cur;
    var posMem = _optimum[cur].posPrev;
    var backMem = _optimum[cur].backPrev;
    do {
      if (_optimum[cur].prev1IsChar) {
        _optimum[posMem].makeAsChar();
        _optimum[posMem].posPrev = posMem - 1;
        if (_optimum[cur].prev2) {
          _optimum[posMem - 1].prev1IsChar = false;
          _optimum[posMem - 1].posPrev = _optimum[cur].posPrev2;
          _optimum[posMem - 1].backPrev = _optimum[cur].backPrev2;
        }
      }
      var posPrev = posMem;
      var backCur = backMem;

      backMem = _optimum[posPrev].backPrev;
      posMem = _optimum[posPrev].posPrev;

      _optimum[posPrev].backPrev = backCur;
      _optimum[posPrev].posPrev = cur;
      cur = posPrev;
    } while (cur > 0);
    backRes = _optimum[0].backPrev;
    _optimumCurrentIndex = _optimum[0].posPrev;
    return _optimumCurrentIndex;
  }

  final List<int> reps = new List<int>(Base.kNumRepDistances);
  final List<int> repLens = new List<int>(Base.kNumRepDistances);
  int backRes;

  int _getOptimum(int position) {
    if (_optimumEndIndex != _optimumCurrentIndex){
      var lenRes = _optimum[_optimumCurrentIndex].posPrev - _optimumCurrentIndex;
      backRes = _optimum[_optimumCurrentIndex].backPrev;
      _optimumCurrentIndex = _optimum[_optimumCurrentIndex].posPrev;
      return lenRes;
    }
    _optimumCurrentIndex = _optimumEndIndex = 0;

    int lenMain, numDistancePairs;
    if (!_longestMatchWasFound) {
      lenMain = _readMatchDistances();
    } else {
      lenMain = _longestMatchLength;
      _longestMatchWasFound = false;
    }
    numDistancePairs = _numDistancePairs;

    var numAvailableBytes = _matchFinder.getNumAvailableBytes() + 1;
    if (numAvailableBytes < 2) {
      backRes = -1;
      return 1;
    }
    if (numAvailableBytes > Base.kMatchMaxLen) {
      numAvailableBytes = Base.kMatchMaxLen;
    }

    int repMaxIndex = 0;
    int i;
    for (i = 0; i < Base.kNumRepDistances; ++ i) {
      reps[i] = _repDistances[i];
      repLens[i] = _matchFinder.getMatchLen(0 - 1, reps[i], Base.kMatchMaxLen);
      if (repLens[i] > repLens[repMaxIndex]) {
        repMaxIndex = i;
      }
    }
    if (repLens[repMaxIndex] >= _numFastBytes) {
      backRes = repMaxIndex;
      var lenRes = repLens[repMaxIndex];
      _movePos(lenRes - 1);
      return lenRes;
    }

    if (lenMain >= _numFastBytes) {
      backRes = _matchDistances[numDistancePairs - 1] + Base.kNumRepDistances;
      _movePos(lenMain - 1);
      return lenMain;
    }

    var currentByte = _matchFinder.getIndexByte(0 - 1);
    var matchByte = _matchFinder.getIndexByte(0 - _repDistances[0] - 1 - 1);

    if (lenMain < 2 && currentByte != matchByte && repLens[repMaxIndex] < 2) {
      backRes = -1;
      return 1;
    }

    _optimum[0].state = _state;

    var posState = (position & _posStateMask);

    _optimum[1].price = RangeEncoder.getPrice0(_isMatch[(_state << Base.kNumPosStatesBitsMax) + posState]) +
        _literalEncoder.getSubCoder(position, _previousByte).getPrice(!Base.stateIsCharState(_state), matchByte, currentByte);
    _optimum[1].makeAsChar();

    var matchPrice = RangeEncoder.getPrice1(_isMatch[(_state << Base.kNumPosStatesBitsMax) + posState]);
    var repMatchPrice = matchPrice + RangeEncoder.getPrice1(_isRep[_state]);

    if (matchByte == currentByte) {
      var shortRepPrice = repMatchPrice + _getRepLen1Price(_state, posState);
      if (shortRepPrice < _optimum[1].price) {
        _optimum[1].price = shortRepPrice;
        _optimum[1].makeAsShortRep();
      }
    }

    var lenEnd = lenMain >= repLens[repMaxIndex] ? lenMain : repLens[repMaxIndex];

    if (lenEnd < 2) {
      backRes = _optimum[1].backPrev;
      return 1;
    }

    _optimum[1].posPrev = 0;

    _optimum[0].backs0 = reps[0];
    _optimum[0].backs1 = reps[1];
    _optimum[0].backs2 = reps[2];
    _optimum[0].backs3 = reps[3];

    var len = lenEnd;
    do {
      _optimum[len--].price = _kIfinityPrice;
    } while (len >= 2);

    for (i = 0; i < Base.kNumRepDistances; ++ i)
    {
      var repLen = repLens[i];
      if (repLen < 2) {
        continue;
      }
      var price = repMatchPrice + _getPureRepPrice(i, _state, posState);
      do {
        var curAndLenPrice = price + _repMatchLenEncoder.getPrice(repLen - 2, posState);
        var optimum = _optimum[repLen];
        if (curAndLenPrice < optimum.price) {
          optimum.price = curAndLenPrice;
          optimum.posPrev = 0;
          optimum.backPrev = i;
          optimum.prev1IsChar = false;
        }
      } while (--repLen >= 2);
    }

    var normalMatchPrice = matchPrice + RangeEncoder.getPrice0(_isRep[_state]);

    len = repLens[0] >= 2 ? repLens[0] + 1 : 2;
    if (len <= lenMain) {
      var offs = 0;
      while (len > _matchDistances[offs]) {
        offs += 2;
      }
      for (; ; ++ len) {
        var distance = _matchDistances[offs + 1];
        var curAndLenPrice = normalMatchPrice + _getPosLenPrice(distance, len, posState);
        var optimum = _optimum[len];
        if (curAndLenPrice < optimum.price) {
          optimum.price = curAndLenPrice;
          optimum.posPrev = 0;
          optimum.backPrev = distance + Base.kNumRepDistances;
          optimum.prev1IsChar = false;
        }
        if (len == _matchDistances[offs]) {
          offs += 2;
          if (offs == numDistancePairs) {
            break;
          }
        }
      }
    }

    var cur = 0;

    while (true) {
      ++ cur;
      if (cur == lenEnd) {
        return _backward(cur);
      }
      var newLen = _readMatchDistances();
      numDistancePairs = _numDistancePairs;
      if (newLen >= _numFastBytes) {
        _longestMatchLength = newLen;
        _longestMatchWasFound = true;
        return _backward(cur);
      }
      ++ position;
      int posPrev = _optimum[cur].posPrev;
      int state;
      if (_optimum[cur].prev1IsChar) {
        -- posPrev;
        if (_optimum[cur].prev2) {
          state = _optimum[_optimum[cur].posPrev2].state;
          if (_optimum[cur].backPrev2 < Base.kNumRepDistances) {
            state = Base.stateUpdateRep(state);
          } else {
            state = Base.stateUpdateMatch(state);
          }
        } else {
          state = _optimum[posPrev].state;
        }
        state = Base.stateUpdateChar(state);
      } else {
        state = _optimum[posPrev].state;
      }
      if (posPrev == cur - 1) {
        if (_optimum[cur].isShortRep()) {
          state = Base.stateUpdateShortRep(state);
        } else {
          state = Base.stateUpdateChar(state);
        }
      } else {
        int pos;
        if (_optimum[cur].prev1IsChar && _optimum[cur].prev2) {
          posPrev = _optimum[cur].posPrev2;
          pos = _optimum[cur].backPrev2;
          state = Base.stateUpdateRep(state);
        } else {
          pos = _optimum[cur].backPrev;
          if (pos < Base.kNumRepDistances) {
            state = Base.stateUpdateRep(state);
          } else {
            state = Base.stateUpdateMatch(state);
          }
        }
        var opt = _optimum[posPrev];
        if (pos < Base.kNumRepDistances) {
          if (pos == 0) {
            reps[0] = opt.backs0;
            reps[1] = opt.backs1;
            reps[2] = opt.backs2;
            reps[3] = opt.backs3;
          } else if (pos == 1) {
            reps[0] = opt.backs1;
            reps[1] = opt.backs0;
            reps[2] = opt.backs2;
            reps[3] = opt.backs3;
          } else if (pos == 2) {
            reps[0] = opt.backs2;
            reps[1] = opt.backs0;
            reps[2] = opt.backs1;
            reps[3] = opt.backs3;
          } else {
            reps[0] = opt.backs3;
            reps[1] = opt.backs0;
            reps[2] = opt.backs1;
            reps[3] = opt.backs2;
          }
        } else {
          reps[0] = pos - Base.kNumRepDistances;
          reps[1] = opt.backs0;
          reps[2] = opt.backs1;
          reps[3] = opt.backs2;
        }
      }
      _optimum[cur].state = state;
      _optimum[cur].backs0 = reps[0];
      _optimum[cur].backs1 = reps[1];
      _optimum[cur].backs2 = reps[2];
      _optimum[cur].backs3 = reps[3];
      var curPrice = _optimum[cur].price;

      currentByte = _matchFinder.getIndexByte(0 - 1);
      matchByte = _matchFinder.getIndexByte(0 - reps[0] - 1 - 1);

      posState = (position & _posStateMask);

      var curAnd1Price = curPrice +
        RangeEncoder.getPrice0(_isMatch[(state << Base.kNumPosStatesBitsMax) + posState]) +
        _literalEncoder.getSubCoder(position, _matchFinder.getIndexByte(0 - 2)).
        getPrice(!Base.stateIsCharState(state), matchByte, currentByte);

      var nextOptimum = _optimum[cur + 1];

      var nextIsChar = false;
      if (curAnd1Price < nextOptimum.price) {
        nextOptimum.price = curAnd1Price;
        nextOptimum.posPrev = cur;
        nextOptimum.makeAsChar();
        nextIsChar = true;
      }

      matchPrice = curPrice + RangeEncoder.getPrice1(_isMatch[(state << Base.kNumPosStatesBitsMax) + posState]);
      repMatchPrice = matchPrice + RangeEncoder.getPrice1(_isRep[state]);

      if (matchByte == currentByte &&
        !(nextOptimum.posPrev < cur && nextOptimum.backPrev == 0)) {
        var shortRepPrice = repMatchPrice + _getRepLen1Price(state, posState);
        if (shortRepPrice <= nextOptimum.price) {
          nextOptimum.price = shortRepPrice;
          nextOptimum.posPrev = cur;
          nextOptimum.makeAsShortRep();
          nextIsChar = true;
        }
      }

      var numAvailableBytesFull = _matchFinder.getNumAvailableBytes() + 1;
      numAvailableBytesFull = math.min(_kNumOpts - 1 - cur, numAvailableBytesFull);
      numAvailableBytes = numAvailableBytesFull;

      if (numAvailableBytes < 2) {
        continue;
      }
      if (numAvailableBytes > _numFastBytes) {
        numAvailableBytes = _numFastBytes;
      }
      if ((!nextIsChar) && (matchByte != currentByte)) {
        var t = math.min(numAvailableBytesFull - 1, _numFastBytes);
        var lenTest2 = _matchFinder.getMatchLen(0, reps[0], t);
        if (lenTest2 >= 2) {
          var state2 = Base.stateUpdateChar(state);

          var posStateNext = (position + 1) & _posStateMask;
          var nextRepMatchPrice = curAnd1Price +
            RangeEncoder.getPrice1(_isMatch[(state2 << Base.kNumPosStatesBitsMax) + posStateNext]) +
            RangeEncoder.getPrice1(_isRep[state2]);

          var offset = cur + 1 + lenTest2;
          while (lenEnd < offset) {
            _optimum[++lenEnd].price = _kIfinityPrice;
          }
          var curAndLenPrice = nextRepMatchPrice + _getRepPrice(
              0, lenTest2, state2, posStateNext);
          var optimum = _optimum[offset];
          if (curAndLenPrice < optimum.price) {
            optimum.price = curAndLenPrice;
            optimum.posPrev = cur + 1;
            optimum.backPrev = 0;
            optimum.prev1IsChar = true;
            optimum.prev2 = false;
          }
        }
      }

      var startLen = 2;

      for (var repIndex = 0; repIndex < Base.kNumRepDistances; ++ repIndex) {
        int lenTest = _matchFinder.getMatchLen(0 - 1, reps[repIndex], numAvailableBytes);
        if (lenTest < 2) {
          continue;
        }
        var lenTestTemp = lenTest;
        do {
          while (lenEnd < cur + lenTest) {
            _optimum[++ lenEnd].price = _kIfinityPrice;
          }
          var curAndLenPrice = repMatchPrice + _getRepPrice(repIndex, lenTest, state, posState);
          var optimum = _optimum[cur + lenTest];
          if (curAndLenPrice < optimum.price) {
            optimum.price = curAndLenPrice;
            optimum.posPrev = cur;
            optimum.backPrev = repIndex;
            optimum.prev1IsChar = false;
          }
        }
        while (-- lenTest >= 2);
        lenTest = lenTestTemp;

        if (repIndex == 0) {
          startLen = lenTest + 1;
        }

        if (lenTest < numAvailableBytesFull) {
          var t = math.min(numAvailableBytesFull - 1 - lenTest, _numFastBytes);
          var lenTest2 = _matchFinder.getMatchLen(lenTest, reps[repIndex], t);
          if (lenTest2 >= 2) {
            var state2 = Base.stateUpdateRep(state);

            var posStateNext = (position + lenTest) & _posStateMask;
            var curAndLenCharPrice =
                repMatchPrice + _getRepPrice(repIndex, lenTest, state, posState) +
                RangeEncoder.getPrice0(_isMatch[(state2 << Base.kNumPosStatesBitsMax) + posStateNext]) +
                _literalEncoder.getSubCoder(position + lenTest,
                _matchFinder.getIndexByte(lenTest - 1 - 1)).getPrice(true,
                _matchFinder.getIndexByte(lenTest - 1 - (reps[repIndex] + 1)),
                _matchFinder.getIndexByte(lenTest - 1));
            state2 = Base.stateUpdateChar(state2);
            posStateNext = (position + lenTest + 1) & _posStateMask;
            var nextMatchPrice = curAndLenCharPrice + RangeEncoder.getPrice1(_isMatch[(state2 << Base.kNumPosStatesBitsMax) + posStateNext]);
            var nextRepMatchPrice = nextMatchPrice + RangeEncoder.getPrice1(_isRep[state2]);

            var offset = lenTest + 1 + lenTest2;
            while (lenEnd < cur + offset) {
              _optimum[++lenEnd].price = _kIfinityPrice;
            }
            var curAndLenPrice = nextRepMatchPrice + _getRepPrice(0, lenTest2, state2, posStateNext);
            var optimum = _optimum[cur + offset];
            if (curAndLenPrice < optimum.price) {
              optimum.price = curAndLenPrice;
              optimum.posPrev = cur + lenTest + 1;
              optimum.backPrev = 0;
              optimum.prev1IsChar = true;
              optimum.prev2 = true;
              optimum.posPrev2 = cur;
              optimum.backPrev2 = repIndex;
            }
          }
        }
      }

      if (newLen > numAvailableBytes) {
        newLen = numAvailableBytes;
        for (numDistancePairs = 0; newLen > _matchDistances[numDistancePairs]; numDistancePairs += 2) {}
        _matchDistances[numDistancePairs] = newLen;
        numDistancePairs += 2;
      }
      if (newLen >= startLen) {
        normalMatchPrice = matchPrice + RangeEncoder.getPrice0(_isRep[state]);
        while (lenEnd < cur + newLen) {
          _optimum[++lenEnd].price = _kIfinityPrice;
        }

        var offs = 0;
        while (startLen > _matchDistances[offs]) {
          offs += 2;
        }

        for (int lenTest = startLen; ; ++ lenTest) {
          var curBack = _matchDistances[offs + 1];
          var curAndLenPrice = normalMatchPrice + _getPosLenPrice(curBack, lenTest, posState);
          var optimum = _optimum[cur + lenTest];
          if (curAndLenPrice < optimum.price) {
            optimum.price = curAndLenPrice;
            optimum.posPrev = cur;
            optimum.backPrev = curBack + Base.kNumRepDistances;
            optimum.prev1IsChar = false;
          }

          if (lenTest == _matchDistances[offs]) {
            if (lenTest < numAvailableBytesFull) {
              var t = math.min(numAvailableBytesFull - 1 - lenTest, _numFastBytes);
              var lenTest2 = _matchFinder.getMatchLen(lenTest, curBack, t);
              if (lenTest2 >= 2) {
                var state2 = Base.stateUpdateMatch(state);

                var posStateNext = (position + lenTest) & _posStateMask;
                var curAndLenCharPrice = curAndLenPrice +
                  RangeEncoder.getPrice0(_isMatch[(state2 << Base.kNumPosStatesBitsMax) + posStateNext]) +
                  _literalEncoder.getSubCoder(position + lenTest,
                  _matchFinder.getIndexByte(lenTest - 1 - 1)).
                  getPrice(true,
                  _matchFinder.getIndexByte(lenTest - (curBack + 1) - 1),
                  _matchFinder.getIndexByte(lenTest - 1));
                state2 = Base.stateUpdateChar(state2);
                posStateNext = (position + lenTest + 1) & _posStateMask;
                var nextMatchPrice = curAndLenCharPrice + RangeEncoder.getPrice1(_isMatch[(state2 << Base.kNumPosStatesBitsMax) + posStateNext]);
                var nextRepMatchPrice = nextMatchPrice + RangeEncoder.getPrice1(_isRep[state2]);

                var offset = lenTest + 1 + lenTest2;
                while (lenEnd < cur + offset) {
                  _optimum[++lenEnd].price = _kIfinityPrice;
                }
                curAndLenPrice = nextRepMatchPrice + _getRepPrice(0, lenTest2, state2, posStateNext);
                optimum = _optimum[cur + offset];
                if (curAndLenPrice < optimum.price) {
                  optimum.price = curAndLenPrice;
                  optimum.posPrev = cur + lenTest + 1;
                  optimum.backPrev = 0;
                  optimum.prev1IsChar = true;
                  optimum.prev2 = true;
                  optimum.posPrev2 = cur;
                  optimum.backPrev2 = curBack + Base.kNumRepDistances;
                }
              }
            }
            offs += 2;
            if (offs == numDistancePairs) {
              break;
            }
          }
        }
      }
    }
  }

  void _writeEndMarker(int posState) {
    if (!_writeEndMark) {
      return;
    }

    _rangeEncoder.encode(_isMatch, (_state << Base.kNumPosStatesBitsMax) + posState, 1);
    _rangeEncoder.encode(_isRep, _state, 0);
    _state = Base.stateUpdateMatch(_state);
    var len = Base.kMatchMinLen;
    _lenEncoder.encode(_rangeEncoder, len - Base.kMatchMinLen, posState);
    var posSlot = (1 << Base.kNumPosSlotBits) - 1;
    var lenToPosState = Base.getLenToPosState(len);
    _posSlotEncoder[lenToPosState].encode(_rangeEncoder, posSlot);
    var footerBits = 30;
    var posReduced = (1 << footerBits) - 1;
    _rangeEncoder.encodeDirectBits(posReduced >> Base.kNumAlignBits, footerBits - Base.kNumAlignBits);
    _posAlignEncoder.reverseEncode(_rangeEncoder, posReduced & Base.kAlignMask);
  }

  void _flush(int nowPos) {
    _releaseMFStream();
    _writeEndMarker(nowPos & _posStateMask);
    _rangeEncoder.flushData();
    _rangeEncoder.flushStream();
  }

  void _codeOneBlock(List<int> inSize, List<int> outSize, List<bool> finished) {
    inSize[0] = 0;
    outSize[0] = 0;
    finished[0] = true;

    if (_inStream != null) {
      _matchFinder.setStream(_inStream);
      _matchFinder.init();
      _needReleaseMFStream = true;
      _inStream = null;
    }

    if (_finished) {
      return;
    }
    _finished = true;

    var progressPosValuePrev = _nowPos64;
    if (_nowPos64 == 0) {
      if (_matchFinder.getNumAvailableBytes() == 0) {
        _flush(_nowPos64);
        return;
      }

      _readMatchDistances();
      var posState = _nowPos64 & _posStateMask;
      _rangeEncoder.encode(_isMatch, (_state << Base.kNumPosStatesBitsMax) + posState, 0);
      _state = Base.stateUpdateChar(_state);
      var curByte = _matchFinder.getIndexByte(0 - _additionalOffset);
      _literalEncoder.getSubCoder(_nowPos64, _previousByte).encode(_rangeEncoder, curByte);
      _previousByte = curByte;
      -- _additionalOffset;
      ++ _nowPos64;
    }
    if (_matchFinder.getNumAvailableBytes() == 0) {
      _flush(_nowPos64);
      return;
    }
    while (true) {
      var len = _getOptimum(_nowPos64);
      var pos = backRes;
      var posState = (_nowPos64) & _posStateMask;
      var complexState = (_state << Base.kNumPosStatesBitsMax) + posState;
      if (len == 1 && pos == -1) {
        _rangeEncoder.encode(_isMatch, complexState, 0);
        var curByte = _matchFinder.getIndexByte(0 - _additionalOffset);
        var subCoder = _literalEncoder.getSubCoder(_nowPos64, _previousByte);
        if (!Base.stateIsCharState(_state)) {
          var matchByte = _matchFinder.getIndexByte(0 - _repDistances[0] - 1 - _additionalOffset);
          subCoder.encodeMatched(_rangeEncoder, matchByte, curByte);
        } else {
          subCoder.encode(_rangeEncoder, curByte);
        }
        _previousByte = curByte;
        _state = Base.stateUpdateChar(_state);
      } else {
        _rangeEncoder.encode(_isMatch, complexState, 1);
        if (pos < Base.kNumRepDistances) {
          _rangeEncoder.encode(_isRep, _state, 1);
          if (pos == 0) {
            _rangeEncoder.encode(_isRepG0, _state, 0);
            if (len == 1) {
              _rangeEncoder.encode(_isRep0Long, complexState, 0);
            } else {
              _rangeEncoder.encode(_isRep0Long, complexState, 1);
            }
          } else {
            _rangeEncoder.encode(_isRepG0, _state, 1);
            if (pos == 1) {
              _rangeEncoder.encode(_isRepG1, _state, 0);
            } else {
              _rangeEncoder.encode(_isRepG1, _state, 1);
              _rangeEncoder.encode(_isRepG2, _state, pos - 2);
            }
          }
          if (len == 1) {
            _state = Base.stateUpdateShortRep(_state);
          } else {
            _repMatchLenEncoder.encode(_rangeEncoder, len - Base.kMatchMinLen, posState);
            _state = Base.stateUpdateRep(_state);
          }
          var distance = _repDistances[pos];
          if (pos != 0) {
            for (var i = pos; i >= 1; -- i) {
              _repDistances[i] = _repDistances[i - 1];
            }
            _repDistances[0] = distance;
          }
        } else {
          _rangeEncoder.encode(_isRep, _state, 0);
          _state = Base.stateUpdateMatch(_state);
          _lenEncoder.encode(_rangeEncoder, len - Base.kMatchMinLen, posState);
          pos -= Base.kNumRepDistances;
          var posSlot = _getPosSlot(pos);
          var lenToPosState = Base.getLenToPosState(len);
          _posSlotEncoder[lenToPosState].encode(_rangeEncoder, posSlot);

          if (posSlot >= Base.kStartPosModelIndex) {
            var footerBits = (posSlot >> 1) - 1;
            var baseVal = (2 | (posSlot & 1)) << footerBits;
            var posReduced = pos - baseVal;

            if (posSlot < Base.kEndPosModelIndex) {
              BitTreeEncoder.reverseEncode2(_posEncoders,
                  baseVal - posSlot - 1, _rangeEncoder, footerBits, posReduced);
            } else {
              _rangeEncoder.encodeDirectBits(posReduced >> Base.kNumAlignBits, footerBits - Base.kNumAlignBits);
              _posAlignEncoder.reverseEncode(_rangeEncoder, posReduced & Base.kAlignMask);
              ++ _alignPriceCount;
            }
          }
          var distance = pos;
          for (var i = Base.kNumRepDistances - 1; i >= 1; -- i) {
            _repDistances[i] = _repDistances[i - 1];
          }
          _repDistances[0] = distance;
          ++ _matchPriceCount;
        }
        _previousByte = _matchFinder.getIndexByte(len - 1 - _additionalOffset);
      }
      _additionalOffset -= len;
      _nowPos64 += len;
      if (_additionalOffset == 0) {
        if (_matchPriceCount >= (1 << 7)) {
          _fillDistancesPrices();
        }
        if (_alignPriceCount >= Base.kAlignTableSize) {
          _fillAlignPrices();
        }
        inSize[0] = _nowPos64;
        outSize[0] = _rangeEncoder.getProcessedSizeAdd();
        if (_matchFinder.getNumAvailableBytes() == 0) {
          _flush(_nowPos64);
          return;
        }

        if (_nowPos64 - progressPosValuePrev >= (1 << 12)) {
          _finished = false;
          finished[0] = false;
          return;
        }
      }
    }
  }

  void _releaseMFStream() {
    if (_matchFinder != null && _needReleaseMFStream) {
      _matchFinder.releaseStream();
      _needReleaseMFStream = false;
    }
  }

  void _setOutStream(OutStream outStream) {
    _rangeEncoder.setStream(outStream);
  }

  void _releaseOutStream() {
    _rangeEncoder.releaseStream();
  }

  void _releaseStreams() {
    _releaseMFStream();
    _releaseOutStream();
  }

  void _setStreams(InStream inStream, OutStream outStream, int inSize, int outSize) {
    _inStream = inStream;
    _finished = false;

    _create();
    _setOutStream(outStream);
    _init();

    _fillDistancesPrices();
    _fillAlignPrices();

    _lenEncoder.setTableSize(_numFastBytes + 1 - Base.kMatchMinLen);
    _lenEncoder.updateTables(1 << _posStateBits);
    _repMatchLenEncoder.setTableSize(_numFastBytes + 1 - Base.kMatchMinLen);
    _repMatchLenEncoder.updateTables(1 << _posStateBits);

    _nowPos64 = 0;
  }

  final List<int> processedInSize = new List<int>(1);
  final List<int> processedOutSize = new List<int>(1);
  final List<bool> finished = new List<bool>(1);

  void code(InStream inStream, OutStream outStream,
      int inSize, int outSize) {
    _needReleaseMFStream = false;

    try {
      _setStreams(inStream, outStream, inSize, outSize);

      while (true) {
        _codeOneBlock(processedInSize, processedOutSize, finished);
        if (finished[0]) {
          return;
        }
      }
    } finally {
      _releaseStreams();
    }
  }

  void writeCoderProperties(OutStream outStream) {
    final kPropSize = 5;

    var properties = new List<int>(kPropSize);

    properties[0] = ((_posStateBits * 5 + _numLiteralPosStateBits) * 9) + _numLiteralContextBits;
    for (var i = 0; i < 4; ++ i) {
      properties[i + 1] = (_dictionarySize >> (8 * i)) & 0xff;
    }

    outStream.writeBlock(properties, 0, kPropSize);
  }

  final List<int> tempPrices = new List<int>(Base.kNumFullDistances);
  int _matchPriceCount;

  void _fillDistancesPrices() {
    for (var i = Base.kStartPosModelIndex; i < Base.kNumFullDistances; ++ i) {
      var posSlot = _getPosSlot(i);
      var footerBits = (posSlot >> 1) - 1;
      var baseVal = (2 | (posSlot & 1)) << footerBits;
      tempPrices[i] = BitTreeEncoder.reverseGetPrice2(_posEncoders,
        baseVal - posSlot - 1, footerBits, i - baseVal);
    }

    for (var lenToPosState = 0; lenToPosState < Base.kNumLenToPosStates; ++ lenToPosState) {
      int posSlot;
      final encoder = _posSlotEncoder[lenToPosState];

      final st = lenToPosState << Base.kNumPosSlotBits;
      for (posSlot = 0; posSlot < _distTableSize; ++ posSlot) {
        _posSlotPrices[st + posSlot] = encoder.getPrice(posSlot);
      }
      for (posSlot = Base.kEndPosModelIndex; posSlot < _distTableSize; ++ posSlot) {
        _posSlotPrices[st + posSlot] += ((((posSlot >> 1) - 1) - Base.kNumAlignBits) << RangeEncoder._kNumBitPriceShiftBits);
      }

      final st2 = lenToPosState * Base.kNumFullDistances;
      int i;
      for (i = 0; i < Base.kStartPosModelIndex; ++ i) {
        _distancesPrices[st2 + i] = _posSlotPrices[st + i];
      }
      for (; i < Base.kNumFullDistances; ++ i) {
        _distancesPrices[st2 + i] = _posSlotPrices[st + _getPosSlot(i)] + tempPrices[i];
      }
    }
    _matchPriceCount = 0;
  }

  void _fillAlignPrices() {
    for (var i = 0; i < Base.kAlignTableSize; ++ i) {
      _alignPrices[i] = _posAlignEncoder.reverseGetPrice(i);
    }
    _alignPriceCount = 0;
  }

  bool setDictionarySize(int dictionarySize) {
    if ((dictionarySize < (1 << Base.kDicLogSizeMin)) || (dictionarySize > 0x20000000)) {
      return false;
    }
    _dictionarySize = dictionarySize;

    int dicLogSize;
    for (dicLogSize = 0; dictionarySize > (1 << dicLogSize); ++ dicLogSize) {}
    _distTableSize = dicLogSize * 2;

    return true;
  }

  bool setNumFastBytes(int numFastBytes) {
    if ((numFastBytes < 5) || (numFastBytes > Base.kMatchMaxLen)) {
      return false;
    }
    _numFastBytes = numFastBytes;
    return true;
  }

  bool setMatchFinder(int matchFinderIndex) {
    if ((matchFinderIndex < 0) || (matchFinderIndex > 2)) {
      return false;
    }

    var matchFinderIndexPrev = _matchFinderType;
    _matchFinderType = matchFinderIndex;
    if ((_matchFinder != null) && (matchFinderIndexPrev != _matchFinderType)) {
      _dictionarySizePrev = -1;
      _matchFinder = null;
    }

    return true;
  }

  bool setLcLpPb(int lc, int lp, int pb) {
    if ((lp < 0) || (lp > Base.kNumLitPosStatesBitsEncodingMax) ||
        (lc < 0) || (lc > Base.kNumLitContextBitsMax) ||
        (pb < 0) || (pb > Base.kNumPosStatesBitsEncodingMax)) {
      return false;
    }

    _numLiteralPosStateBits = lp;
    _numLiteralContextBits = lc;
    _posStateBits = pb;
    _posStateMask = (1 << _posStateBits) - 1;

    return true;
  }

  void setEndMarkerMode(bool endMarkerMode) {
    _writeEndMark = endMarkerMode;
  }
}
