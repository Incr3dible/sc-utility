import 'dart:io';
import 'package:sc_utility/network/crypto/Rc4.dart';

class Device{
  Rc4Core rc4;
  Socket socket;

  Device(Socket clientSocket){
    socket = clientSocket;
    rc4 = new Rc4Core();
  }
}