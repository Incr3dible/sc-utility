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

class Base {
  static const int kNumRepDistances = 4;
  static const int kNumStates = 12;

  static const stateInit = 0;

  static int stateUpdateChar(int index) =>
      index < 4 ? 0 : (index < 10 ? index - 3 : index - 6);

  static int stateUpdateMatch(int index) => index < 7 ? 7 : 10;

  static int stateUpdateRep(int index) => index < 7 ? 8 : 11;

  static int stateUpdateShortRep(int index) => index < 7 ? 9 : 11;

  static bool stateIsCharState(int index) => index < 7;

  static const int kNumPosSlotBits = 6;
  static const int kDicLogSizeMin = 0;

  static const int kNumLenToPosStatesBits = 2;
  static const int kNumLenToPosStates = 1 << kNumLenToPosStatesBits;

  static const int kMatchMinLen = 2;

  static int getLenToPosState(int len) =>
      len - kMatchMinLen < kNumLenToPosStates
          ? len - kMatchMinLen
          : kNumLenToPosStates - 1;

  static const int kNumAlignBits = 4;
  static const int kAlignTableSize = 1 << kNumAlignBits;
  static const int kAlignMask = kAlignTableSize - 1;

  static const int kStartPosModelIndex = 4;
  static const int kEndPosModelIndex = 14;

  static const int kNumFullDistances = 1 << (kEndPosModelIndex >> 1);

  static const int kNumLitPosStatesBitsEncodingMax = 4;
  static const int kNumLitContextBitsMax = 8;

  static const int kNumPosStatesBitsMax = 4;
  static const int kNumPosStatesMax = 1 << kNumPosStatesBitsMax;
  static const int kNumPosStatesBitsEncodingMax = 4;
  static const int kNumPosStatesEncodingMax = 1 << kNumPosStatesBitsEncodingMax;

  static const int kNumLowLenBits = 3;
  static const int kNumMidLenBits = 3;
  static const int kNumHighLenBits = 8;
  static const int kNumLowLenSymbols = 1 << kNumLowLenBits;
  static const int kNumMidLenSymbols = 1 << kNumMidLenBits;
  static const int kNumLenSymbols =
      kNumLowLenSymbols + kNumMidLenSymbols + (1 << kNumHighLenBits);

  static const int kMatchMaxLen = kMatchMinLen + kNumLenSymbols - 1;
}
