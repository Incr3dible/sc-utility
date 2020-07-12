import 'package:sc_utility/network/protocol/Message.dart';
import '../../../../resources.dart';

class ClientHelloMessage extends Message{
  ClientHelloMessage(Resources resources) : super.fromClient(resources){
    id = 10100;
  }

  @override
  void encode() {
    writer.writeInt(2); // Protocol
    writer.writeInt(29); // KeyVersion
    writer.writeInt(3); // Major
    writer.writeInt(0); // Minor
    writer.writeInt(2077); // Build
    writer.writeString(resources.fingerprintSha()); // SHA
    writer.writeInt(2); // Device
    writer.writeInt(2); // AppStore
  }
}