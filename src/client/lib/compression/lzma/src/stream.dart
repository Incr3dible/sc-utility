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

part of lzma;

abstract class _InStream<T> {
  T read();

  int readBlock(List<T> buffer, int offset, int size);

  int length();
}

abstract class _OutStream<T> {
  void write(T value);

  void writeBlock(List<T> buffer, int offset, int size);

  void flush();
}

class InStream implements _InStream<int> {
  final List<int> _data;

  InStream(this._data);

  int _offset = 0;

  int read() {
    if (_offset >= length()) {
      return -1;
    }
    return _data[_offset++];
  }

  int readBlock(List<int> buffer, int offset, int size) {
    if (_offset >= length()) {
      return -1;
    }
    var len = math.min(size, length() - _offset);
    for (var i = 0; i < len; ++i) {
      buffer[offset++] = _data[_offset++];
    }
    return len;
  }

  int length() => _data.length;
}

class OutStream implements _OutStream<int> {
  final List<int> data = new List<int>();

  void write(int value) {
    data.add(value);
  }

  void writeBlock(List<int> buffer, int offset, int size) {
    if (size > 0) {
      data.addAll(buffer.sublist(offset, offset + size));
    }
  }

  void flush() {}
}
