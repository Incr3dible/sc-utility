import 'dart:convert';

class Writer {
  List<int> buffer;

  int offset;

  Writer() {
    buffer = new List<int>();
    offset = 0;
  }

  void writeLong(int value) {
    buffer.add((value >> 64) & 0xFF);
    buffer.add((value >> 56) & 0xFF);
    buffer.add((value >> 40) & 0xFF);
    buffer.add((value >> 32) & 0xFF);
    buffer.add((value >> 24) & 0xFF);
    buffer.add((value >> 16) & 0xFF);
    buffer.add((value >> 8) & 0xFF);
    buffer.add(value & 0xFF);

    offset += 8;
  }

  void writeInt(int value) {
    buffer.add((value >> 24) & 0xFF);
    buffer.add((value >> 16) & 0xFF);
    buffer.add((value >> 8) & 0xFF);
    buffer.add(value & 0xFF);

    offset += 4;
  }

  void writeByte(int value) {
    buffer.add(value & 0xFF);
    offset++;
  }

  void writeBoolean(bool value) {
    writeByte(value ? 1 : 0);
  }

  void writeInt24(int value) {
    buffer.add((value >> 16) & 0xFF);
    buffer.add((value >> 8) & 0xFF);
    buffer.add(value & 0xFF);

    offset += 3;
  }

  void writeInt16(int value) {
    buffer.add((value >> 8) & 0xFF);
    buffer.add(value & 0xFF);

    offset += 2;
  }

  void writeString(String value) {
    if (value == null) {
      writeInt(-1);
      return;
    }

    var bytes = utf8.encode(value);
    writeInt(bytes.length);
    buffer.addAll(bytes);
  }

  void writeVInt(int value) {
    var temp = (value >> 25) & 0x40;
    var flipped = value ^ (value >> 31);

    temp |= value & 0x3F;
    value >>= 6;

    if ((flipped >>= 6) == 0) {
      writeByte(temp);
      return;
    }

    writeByte(temp | 0x80);

    do {
      writeByte((value & 0x7F) | ((flipped >>= 7) != 0 ? 0x80 : 0));
      value >>= 7;
    } while (flipped != 0);
  }

  void concatBuffer(List<int> data) {
    buffer.addAll(data);
    offset += data.length;
  }
}
