import 'dart:typed_data';
import '../../Message.dart';

class ServerHelloMessage extends Message {
  ServerHelloMessage();

  Uint8List sessionKey;

  @override
  void decode(){
    var length = reader.readInt32();
    sessionKey = reader.readBytes(length);
  }

  @override
  void process() {
    var page = resources.clientPageState;

    //print("SessionKey: " + hex.encode(sessionKey));

    page.setLoading(false, 1);
  }
}