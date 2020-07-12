import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:sc_utility/network/helpers/Reader.dart';
import 'package:sc_utility/network/protocol/messages/client/ClientHelloMessage.dart';
import 'package:sc_utility/network/protocol/MessageFactory.dart';

import '../resources.dart';

class Client {
  Socket socket;
  Resources resources;

  Client() {
    resources = Resources.getInstance();
    resources.client = this;
  }

  Future<void> connectAsync() async {
    try {
      socket = await Socket.connect("game.clashroyaleapp.com", 9339,
          timeout: const Duration(seconds: 2));
    } catch (e) {
      print("Failed to connect.");
      return;
    }

    socket.setOption(SocketOption.tcpNoDelay, true);

    await onReceive();

    print("Connected to " +
        socket.address.host +
        " (" +
        socket.address.address +
        ")");

    new ClientHelloMessage(resources).sendToServer();

    print("Sent ClientHello!");
  }

  Future<void> processMessage(Reader reader) async {
    try {
      var id = reader.readInt16();
      var length = reader.readInt24();
      var version = reader.readInt16();

      try {
        if (MessageFactory.hasMessage(id)) {
          print("Processing $id with $length bytes and version $version");

          var message = MessageFactory.create(id)
              .fromServer(id, length, version, reader, resources);
          message.decode();
          message.process();
        } else {
          print("Message $id is unhandled.");
        }
      } catch (exception) {
        print("Failed to process message $id, Length: $length.");
      }
    } catch (exception) {
      print("Failed to process message.");
    }
  }

  Future<void> onReceive() async {
    var reader = new Reader(new Uint8List(0));

    socket.listen((Uint8List data) async {
      //print("Received " + data.length.toString() + " bytes");

      var bytesRead = 0;
      var bytesReceived = data.length;

      while (bytesRead < bytesReceived) {
        var bytesAvailable = bytesReceived - bytesRead;

        if (bytesReceived > 0 && reader.length >= 7) {
          var pl = Uint8List.fromList(reader.buffer.skip(2).take(3).toList());
          var payloadLength = pl[0] << 16 | pl[1] << 8 | pl[2];

          //print(payloadLength);

          var bytesNeeded = payloadLength - (reader.length - 7);
          if (bytesAvailable >= bytesNeeded) {
            reader.concatList(data.skip(bytesRead).take(bytesNeeded).toList());
            bytesRead += bytesNeeded;

            await processMessage(reader);
            reader = new Reader(new Uint8List(0));
          } else {
            reader
                .concatList(data.skip(bytesRead).take(bytesAvailable).toList());
            bytesRead = bytesReceived;
          }
        } else if (bytesAvailable >= 7) {
          reader.concatList(data.skip(bytesRead).take(7).toList());
          bytesRead += 7;
        } else {
          reader.concatList(data.skip(bytesRead).take(bytesAvailable).toList());
          bytesRead = bytesReceived;
        }
      }
    }, cancelOnError: true);
  }

  void disconnect() async {
    if (socket == null) return;

    await socket.close();
    socket = null;

    print("Disconnected.");
  }
}
