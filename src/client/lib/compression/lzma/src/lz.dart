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

class OutWindow {
  List<int> _buffer;
  int _pos;
  int _windowSize = 0;
  int _streamPos;
  OutStream _stream;

  void create(int windowSize) {
    if ((_buffer == null) || (_windowSize != windowSize)) {
      _buffer = new List<int>(windowSize);
    }

    _windowSize = windowSize;
    _pos = 0;
    _streamPos = 0;
  }

  void setStream(OutStream stream) {
    releaseStream();
    _stream = stream;
  }

  void releaseStream() {
    flush();
    _stream = null;
  }

  void init(bool solid) {
    if (!solid) {
      _streamPos = 0;
      _pos = 0;
    }
  }

  void flush() {
    var size = _pos - _streamPos;
    if (size != 0) {
      _stream.writeBlock(_buffer, _streamPos, size);

      if (_pos >= _windowSize) {
        _pos = 0;
      }
      _streamPos = _pos;
    }
  }

  void copyBlock(int distance, int len) {
    var pos = _pos - distance - 1;
    if (pos < 0) {
      pos += _windowSize;
    }

    for (var i = 0; i < len; ++ i) {
      if (pos >= _windowSize) {
        pos = 0;
      }

      _buffer[_pos ++] = _buffer[pos ++];

      if (_pos >= _windowSize) {
        flush();
      }
    }
  }

  void putByte(int b) {
    _buffer[_pos ++] = b;

    if (_pos >= _windowSize) {
      flush();
    }
  }

  int getByte(int distance) {
    var pos = _pos - distance - 1;
    if (pos < 0) {
      pos += _windowSize;
    }
    return _buffer[pos];
  }
}

class InWindow {
  List<int> _bufferBase;
  InStream _stream;
  int _posLimit;
  bool _streamEndWasReached;
  int _pointerToLastSafePosition;
  int _bufferOffset;
  int _blockSize;
  int _pos;
  int _keepSizeBefore;
  int _keepSizeAfter;
  int _streamPos;

  void moveBlock() {
    var offset = _bufferOffset + _pos - _keepSizeBefore;
    if (offset > 0) {
      -- offset;
    }

    var numBytes = _bufferOffset + _streamPos - offset;
    for (var i = 0; i < numBytes; ++ i) {
      _bufferBase[i] = _bufferBase[offset + i];
    }
    _bufferOffset -= offset;
  }

  void readBlock() {
    if (_streamEndWasReached) {
      return;
    }

    while (true) {
      var size = -_bufferOffset + _blockSize - _streamPos;
      if (size == 0) {
        return;
      }

      var numReadBytes = _stream.readBlock(_bufferBase, _bufferOffset + _streamPos, size);

      if (numReadBytes == -1) {
        _posLimit = _streamPos;
        if ((_bufferOffset + _posLimit) > _pointerToLastSafePosition) {
          _posLimit = _pointerToLastSafePosition - _bufferOffset;
        }
        _streamEndWasReached = true;
        return;
      }

      _streamPos += numReadBytes;
      if (_streamPos >= (_pos + _keepSizeAfter)) {
        _posLimit = _streamPos - _keepSizeAfter;
      }
    }
  }

  void free() {
    _bufferBase = null;
  }

  void create(int keepSizeBefore, int keepSizeAfter, int keepSizeReserv) {
    _keepSizeBefore = keepSizeBefore;
    _keepSizeAfter = keepSizeAfter;

    var blockSize = keepSizeBefore + keepSizeAfter + keepSizeReserv;
    if ((_bufferBase == null) || (_blockSize != blockSize)) {
      free();

      _blockSize = blockSize;
      _bufferBase = new List<int>(_blockSize);
    }
    _pointerToLastSafePosition = _blockSize - keepSizeAfter;
  }

  void setStream(InStream stream) {
    _stream = stream;
  }

  void releaseStream() {
    _stream = null;
  }

  void init() {
    _bufferOffset = 0;
    _pos = 0;
    _streamPos = 0;
    _streamEndWasReached = false;

    readBlock();
  }

  void movePos() {
    ++ _pos;
    if (_pos > _posLimit) {
      if ((_bufferOffset + _pos) > _pointerToLastSafePosition) {
        moveBlock();
      }
      readBlock();
    }
  }

  int getIndexByte(int index) => _bufferBase[_bufferOffset + _pos + index];

  int getMatchLen(int index, int distance, int limit) {
    if (_streamEndWasReached) {
      if ((_pos + index + limit) > _streamPos) {
        limit = _streamPos - (_pos + index);
      }
    }
    ++ distance;

    var pby = _bufferOffset + _pos + index;

    var i = 0;
    for (; (i < limit) && (_bufferBase[pby + i] == _bufferBase[pby + i - distance]); ++ i) {}
    return i;
  }

  int getNumAvailableBytes() => _streamPos - _pos;

  void reduceOffsets(int subValue) {
    _bufferOffset += subValue;
    _posLimit -= subValue;
    _pos -= subValue;
    _streamPos -= subValue;
  }
}

class BinTree extends InWindow {
  int _cyclicBufferPos;
  int _cyclicBufferSize = 0;
  int _matchMaxLen;

  List<int> _son;
  List<int> _hash;

  int _cutValue = 0xff;
  int _hashMask;
  int _hashSizeSum = 0;

  bool _hashArray = true;

  static const int _kHash2Size = 0x400;
  static const int _kHash3Size = 0x10000;
  static const int _kBT2HashSize = 0x10000;
  static const int _kStartMaxLen = 1;
  static const int _kHash3Offset = _kHash2Size;
  static const int _kEmptyHashValue = 0;
  static const int _kMaxValForNormalize = 0x3fffffff;

  int _kNumHashDirectBytes = 0;
  int _kMinMatchCheck = 4;
  int _kFixHashSize = _kHash2Size + _kHash3Size;

  void setType(int numHashBytes) {
    _hashArray = numHashBytes > 2;
    if (_hashArray) {
      _kNumHashDirectBytes = 0;
      _kMinMatchCheck = 4;
      _kFixHashSize = _kHash2Size + _kHash3Size;
    } else {
      _kNumHashDirectBytes = 2;
      _kMinMatchCheck = 3;
      _kFixHashSize = 0;
    }
  }

  void init() {
    super.init();

    for (var i = 0; i < _hashSizeSum; ++ i) {
      _hash[i] = _kEmptyHashValue;
    }
    _cyclicBufferPos = 0;

    reduceOffsets(-1);
  }

  void movePos() {
    if (++_cyclicBufferPos >= _cyclicBufferSize) {
      _cyclicBufferPos = 0;
    }

    super.movePos();

    if (_pos == _kMaxValForNormalize) {
      normalize();
    }
  }

  bool create2(int historySize, int keepAddBufferBefore,
      int matchMaxLen, int keepAddBufferAfter) {
    if (historySize > (_kMaxValForNormalize - 256)) {
      return false;
    }
    _cutValue = 16 + (matchMaxLen >> 1);

    var windowReservSize = ((historySize + keepAddBufferBefore +
        matchMaxLen + keepAddBufferAfter) ~/ 2) + 256;

    super.create(historySize + keepAddBufferBefore, matchMaxLen + keepAddBufferAfter, windowReservSize);

    _matchMaxLen = matchMaxLen;

    var cyclicBufferSize = historySize + 1;
    if (_cyclicBufferSize != cyclicBufferSize) {
      _cyclicBufferSize = cyclicBufferSize;
      _son = new List<int>(_cyclicBufferSize * 2);
    }

    var hs = _kBT2HashSize;

    if (_hashArray) {
      hs = historySize - 1;
      hs |= (hs >> 1);
      hs |= (hs >> 2);
      hs |= (hs >> 4);
      hs |= (hs >> 8);
      hs >>= 1;
      hs |= 0xffff;
      if (hs > 0x1000000) {
        hs >>= 1;
      }
      _hashMask = hs;
      hs += _kFixHashSize + 1;
    }

    if (hs != _hashSizeSum) {
      _hashSizeSum = hs;
      _hash = new List<int>(_hashSizeSum);
    }

    return true;
  }

  int getMatches(List<int> distances) {
    int lenLimit;

    if ((_pos + _matchMaxLen) <= _streamPos) {
      lenLimit = _matchMaxLen;
    } else {
      lenLimit = _streamPos - _pos;
      if (lenLimit < _kMinMatchCheck) {
        movePos();
        return 0;
      }
    }

    var offset = 0;
    var matchMinPos = _pos > _cyclicBufferSize ? _pos - _cyclicBufferSize : 0;
    var cur = _bufferOffset + _pos;
    var maxLen = _kStartMaxLen;
    int hashValue, hash2Value = 0, hash3Value = 0;

    if (_hashArray) {
      var temp =  (_crcTable[_bufferBase[cur] & 0xff]) ^ (_bufferBase[cur + 1] & 0xff);
      hash2Value = temp & (_kHash2Size - 1);
      temp ^= (_bufferBase[cur + 2] & 0xff) << 8;
      hash3Value = temp & (_kHash3Size - 1);
      hashValue = (temp ^ (_crcTable[_bufferBase[cur + 3] & 0xff] << 5)) & _hashMask;
    } else {
      hashValue = (_bufferBase[cur] & 0xff) ^ ((_bufferBase[cur + 1] & 0xff) << 8);
    }

    var curMatch = _hash[_kFixHashSize + hashValue];
    if (_hashArray) {
      var curMatch2 = _hash[hash2Value];
      var curMatch3 = _hash[_kHash3Offset + hash3Value];

      _hash[hash2Value] = _pos;
      _hash[_kHash3Offset + hash3Value] = _pos;

      if (curMatch2 > matchMinPos) {
        if (_bufferBase[_bufferOffset + curMatch2] == _bufferBase[cur]) {
          distances[offset++] = maxLen = 2;
          distances[offset++] = _pos - curMatch2 - 1;
        }
      }
      if (curMatch3 > matchMinPos) {
        if (_bufferBase[_bufferOffset + curMatch3] == _bufferBase[cur]) {
          if (curMatch3 == curMatch2) {
            offset -= 2;
          }
          distances[offset++] = maxLen = 3;
          distances[offset++] = _pos - curMatch3 - 1;
          curMatch2 = curMatch3;
        }
      }
      if ((offset != 0) && (curMatch2 == curMatch)) {
        offset -= 2;
        maxLen = _kStartMaxLen;
      }
    }

    _hash[_kFixHashSize + hashValue.toInt()] = _pos;

    var ptr0 = (_cyclicBufferPos << 1) + 1;
    var ptr1 = _cyclicBufferPos << 1;

    var len0 = _kNumHashDirectBytes;
    var len1 = _kNumHashDirectBytes;

    if (_kNumHashDirectBytes != 0) {
      if (curMatch > matchMinPos) {
        if (_bufferBase[_bufferOffset + curMatch + _kNumHashDirectBytes] !=
            _bufferBase[cur + _kNumHashDirectBytes]) {
          distances[offset ++] = maxLen = _kNumHashDirectBytes;
          distances[offset ++] = _pos - curMatch - 1;
        }
      }
    }

    var count = _cutValue;

    while (true) {
      if ((curMatch <= matchMinPos) || (count -- == 0)) {
        _son[ptr0] = _son[ptr1] = _kEmptyHashValue;
        break;
      }

      int delta = _pos - curMatch;
      var cyclicPos = ((delta <= _cyclicBufferPos) ?
        (_cyclicBufferPos - delta) :
        (_cyclicBufferPos - delta + _cyclicBufferSize)) << 1;

      var pby1 = _bufferOffset + curMatch;
      var len = math.min(len0, len1);

      if (_bufferBase[pby1 + len] == _bufferBase[cur + len]) {
        while(++ len != lenLimit) {
          if (_bufferBase[pby1 + len] != _bufferBase[cur + len]) {
            break;
          }
        }
        if (maxLen < len) {
          distances[offset ++] = maxLen = len;
          distances[offset ++] = delta - 1;
          if (len == lenLimit) {
            _son[ptr1] = _son[cyclicPos];
            _son[ptr0] = _son[cyclicPos + 1];
            break;
          }
        }
      }

      if ((_bufferBase[pby1 + len] & 0xff) < (_bufferBase[cur + len] & 0xff)) {
        _son[ptr1] = curMatch;
        ptr1 = cyclicPos + 1;
        curMatch = _son[ptr1];
        len1 = len;
      } else {
        _son[ptr0] = curMatch;
        ptr0 = cyclicPos;
        curMatch = _son[ptr0];
        len0 = len;
      }
    }

    movePos();

    return offset;
  }

  void skip(int num) {
    do {
      int lenLimit;
      if ((_pos + _matchMaxLen) <= _streamPos) {
        lenLimit = _matchMaxLen;
      } else {
        lenLimit = _streamPos - _pos;
        if (lenLimit < _kMinMatchCheck) {
          movePos();
          continue;
        }
      }

      var matchMinPos = (_pos > _cyclicBufferSize) ? (_pos - _cyclicBufferSize) : 0;
      var cur = _bufferOffset + _pos;

      int hashValue;

      if (_hashArray) {
        var temp = (new Int32(_crcTable[_bufferBase[cur] & 0xff]) ^ (_bufferBase[cur + 1] & 0xff)).toInt();
        var hash2Value = temp & (_kHash2Size - 1);
        _hash[hash2Value] = _pos;
        temp ^= (_bufferBase[cur + 2] & 0xff) << 8;
        var hash3Value = temp & (_kHash3Size - 1);
        _hash[_kHash3Offset + hash3Value] = _pos;
        hashValue = (temp ^ (_crcTable[_bufferBase[cur + 3] & 0xff] << 5)) & _hashMask;
      } else {
        hashValue = (new Int32(_bufferBase[cur] & 0xff) ^ ((_bufferBase[cur + 1] & 0xff) << 8)).toInt();
      }

      var curMatch = _hash[_kFixHashSize + hashValue];
      _hash[_kFixHashSize + hashValue] = _pos;

      var ptr0 = (_cyclicBufferPos << 1) + 1;
      var ptr1 = _cyclicBufferPos << 1;

      var len0 = _kNumHashDirectBytes, len1 = _kNumHashDirectBytes;

      var count = _cutValue;
      while (true) {
        if ((curMatch <= matchMinPos) || (count -- == 0)) {
          _son[ptr0] = _son[ptr1] = _kEmptyHashValue;
          break;
        }

        int delta = _pos - curMatch;
        var cyclicPos = ((delta <= _cyclicBufferPos) ?
          (_cyclicBufferPos - delta) :
          (_cyclicBufferPos - delta + _cyclicBufferSize)) << 1;

        var pby1 = _bufferOffset + curMatch;
        var len = math.min(len0, len1);
        if (_bufferBase[pby1 + len] == _bufferBase[cur + len]) {
          while (++ len != lenLimit) {
            if (_bufferBase[pby1 + len] != _bufferBase[cur + len]) {
              break;
            }
          }
          if (len == lenLimit) {
            _son[ptr1] = _son[cyclicPos];
            _son[ptr0] = _son[cyclicPos + 1];
            break;
          }
        }
        if ((_bufferBase[pby1 + len] & 0xff) < (_bufferBase[cur + len] & 0xff)) {
          _son[ptr1] = curMatch;
          ptr1 = cyclicPos + 1;
          curMatch = _son[ptr1];
          len1 = len;
        } else {
          _son[ptr0] = curMatch;
          ptr0 = cyclicPos;
          curMatch = _son[ptr0];
          len0 = len;
        }
      }

      movePos();

    } while (-- num != 0);
  }

  void normalizeLinks(List<int> items, int numItems, int subValue) {
    for (var i = 0; i < numItems; ++ i) {
      var value = items[i];
      if (value <= subValue) {
        value = _kEmptyHashValue;
      } else {
        value -= subValue;
      }
      items[i] = value;
    }
  }

  void normalize() {
    var subValue = _pos - _cyclicBufferSize;
    normalizeLinks(_son, _cyclicBufferSize * 2, subValue);
    normalizeLinks(_hash, _hashSizeSum, subValue);
    reduceOffsets(subValue);
  }

  void setCutValue(int cutValue) {
    _cutValue = cutValue;
  }

  static final List<int> _crcTable = _buildCrcTable();

  static List<int> _buildCrcTable() {
    var crcTable = new List<int>(256);

    for (var i = 0; i < 256; ++ i) {
      var r = i;
      for (var j = 0; j < 8; ++ j) {
        if ((r & 1) != 0) {
          r = (r >> 1) ^ 0xedb88320;
        } else {
          r >>= 1;
        }
      }
      crcTable[i] = r;
    }

    return crcTable;
  }
}
