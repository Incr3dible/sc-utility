import 'package:sc_utility/network/helpers/Reader.dart';
import 'package:sc_utility/network/helpers/Writer.dart';
import 'package:sc_utility/network/logic/device.dart';
import '../../resources.dart';

abstract class Message {
  Message();

  Message.fromClient(Resources resources) {
    id = 0;
    length = 0;
    writer = new Writer();
    this.resources = resources;
  }

  Message fromServer(
      int id, int length, int version, Reader reader, Resources resources) {
    this.id = id;
    this.length = length;
    this.version = version;
    this.reader = reader;
    this.resources = resources;
    return this;
  }

  Message toServer(
      int id, int length, int version, Reader reader, Resources resources, Device device) {
    this.id = id;
    this.length = length;
    this.version = version;
    this.reader = reader;
    this.resources = resources;
    this.device = device;
    return this;
  }

  int id;
  int length;
  int version = 0;

  Writer writer;
  Reader reader;

  Device device;
  Resources resources;

  void decrypt() {
    if (length <= 0) return;

    var buffer = reader.readToEnd();
    var decrypted = device.rc4.decrypt(buffer);

    reader = new Reader(decrypted);
  }

  void encrypt() {
    if (writer.buffer.length == 0) return;

    var encrypted = device.rc4.encrypt(writer.buffer);

    writer = new Writer();
    writer.concatBuffer(encrypted);
  }

  void decode() {}
  void encode() {}
  void process() {}

  void sendToServer() {
    var client = resources.client;

    encode();

    var header = new Writer();
    header.writeInt16(id);
    header.writeInt24(writer.buffer.length);
    header.writeInt16(version);

    client.socket.add(header.buffer);

    if (writer.buffer.length > 0) client.socket.add(writer.buffer);

    print("Message $id has been sent!");
  }

  void sendToClient(Device device) {
    this.device = device;
    writer = new Writer();

    encode();
    encrypt();

    var header = new Writer();
    header.writeInt16(id);
    header.writeInt24(writer.buffer.length);
    header.writeInt16(version);

    device.socket.add(header.buffer);

    if (writer.buffer.length > 0) device.socket.add(writer.buffer);

    print("Message $id has been sent!");
  }
}