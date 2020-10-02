import 'dart:convert';
import 'dart:typed_data';

class Reader {
  Uint8List buffer;
  int offset;
  int length;

  Reader(Uint8List bytes) {
    buffer = bytes;
    offset = 0;
    length = bytes.lengthInBytes;
  }

  int readByte() {
    if (offset + 1 > length) return -1;
    return buffer[offset++];
  }

  bool readBoolean() {
    return readByte() > 0;
  }

  int readInt32() {
    if (offset + 4 > length) return -1;

    return buffer[offset++] << 24 |
        buffer[offset++] << 16 |
        buffer[offset++] << 8 |
        buffer[offset++];
  }

  int readInt64() {
    if (offset + 8 > length) return -1;

    return buffer[offset++] << 56 |
        buffer[offset++] << 48 |
        buffer[offset++] << 40 |
        buffer[offset++] << 32 |
        buffer[offset++] << 24 |
        buffer[offset++] << 16 |
        buffer[offset++] << 8 |
        buffer[offset++];
  }

  String readString() {
    var length = readInt32();

    if (length <= -1) {
      return null;
    }

    if (length > 0) {
      var bytes = buffer.getRange(offset, offset + length).toList();
      offset += length;
      return utf8.decode(bytes);
    }

    return "";
  }

  String readStringByLength(int length) {
    if (length <= -1) {
      return null;
    }

    if (length > 0) {
      var bytes = buffer.getRange(offset, offset + length).toList();
      offset += length;
      return utf8.decode(bytes);
    }

    return "";
  }

  String readShortString() {
    var length = readInt16();

    if (length <= -1) {
      return null;
    }

    if (length > 0) {
      var bytes = buffer.getRange(offset, offset + length).toList();
      offset += length;
      return utf8.decode(bytes);
    }

    return "";
  }

  int readInt24() {
    if (offset + 3 > length) return -1;
    return buffer[offset++] << 16 | buffer[offset++] << 8 | buffer[offset++];
  }

  int readInt16() {
    if (offset + 2 > length) return -1;
    return buffer[offset++] << 8 | buffer[offset++];
  }

  int readVInt() {
    int b, sign = ((b = readByte()) >> 6) & 1, i = b & 0x3F, offset = 6;

    for (var j = 0; j < 4 && (b & 0x80) != 0; j++, offset += 7)
      i |= ((b = readByte()) & 0x7F) << offset;

    var val = (b & 0x80) != 0
        ? -1
        : i |
            (sign == 1 && offset < 32
                ? i | 0x7FFFFFFF & (0xFFFFFFFF << offset)
                : i);
    return val == 0x7FFFFFFF ? -1 : val;
  }

  void concatBuffer(Uint8List data) {
    var tempBuffer = new List<int>();
    tempBuffer.addAll(buffer);
    tempBuffer.addAll(data);

    buffer = Uint8List.fromList(tempBuffer);
    length = buffer.lengthInBytes;
  }

  void concatList(List<int> data) {
    var tempBuffer = new List<int>();
    tempBuffer.addAll(buffer);
    tempBuffer.addAll(data);

    buffer = Uint8List.fromList(tempBuffer);
    length = buffer.lengthInBytes;
  }

  Uint8List readToEnd() {
    if (offset + 1 == length) return new Uint8List(0);

    var oldOffset = offset;
    offset = length - 1;
    return buffer.sublist(oldOffset);
  }

  Uint8List readBytes(int bytesToRead) {
    if (offset == length) return new Uint8List(0);

    var oldOffset = offset;
    offset += bytesToRead;
    return Uint8List.fromList(buffer.getRange(oldOffset, offset).toList());
  }

  void skipBytes(int bytesToSkip) {
    offset += bytesToSkip;
  }
}
