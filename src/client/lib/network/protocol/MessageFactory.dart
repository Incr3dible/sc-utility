import 'Message.dart';
import 'messages/server/LoginFailedMessage.dart';
import 'messages/server/ServerHelloMessage.dart';

class MessageFactory {
  static final messages = {
    20100: () => ServerHelloMessage(),
    20103: () => LoginFailedMessage(),
  };

  static bool hasMessage(int id) {
    return messages.containsKey(id);
  }

  static Message create(int id) {
    return messages[id]();
  }
}