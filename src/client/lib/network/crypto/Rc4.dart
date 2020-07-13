import 'dart:typed_data';
import 'dart:convert';
import 'Scrambler.dart';

class Rc4 {
  Rc4(Uint8List k) {
    key = ksa(k);
  }

  Uint8List key;
  int I = 0;
  int J = 0;

  int prga() {
    I = ((I + 1) % 256) & 0xFF;
    J = ((J + key[I]) % 256) & 0xFF;

    var temp = key[I];
    key[I] = key[J];
    key[J] = temp;

    return key[(key[I] + key[J]) % 256];
  }

  static Uint8List ksa(Uint8List k) {
    var s = new Uint8List(256);
    for (var i = 0; i != 256; i++) s[i] = i & 0xFF;

    int j = 0;

    for (var i = 0; i != 256; i++) {
      j = ((j + s[i] + k[i % k.length]) % 256) & 0xFF;

      var temp = s[i];
      s[i] = s[j];
      s[j] = temp;
    }

    return s;
  }
}

class Rc4Core {
  String initialKey = "fhsd6f86f67rt8fw78fw789we78r9789wer6re";
  String initialNonce = "nonce";

  Rc4Core() {
    initializeCiphers(utf8.encode((initialKey + initialNonce)));
  }

  Rc4 encryptor;
  Rc4 decryptor;

  List<int> encrypt(List<int> data) {
    for (var i = 0; i < data.length; i++) {
      data[i] = data[i] ^ encryptor.prga();
    }

    return data;
  }

  Uint8List decrypt(Uint8List data) {
    for (var i = 0; i < data.lengthInBytes; i++) {
      data[i] = data[i] ^ decryptor.prga();
    }

    return data;
  }

  void initializeCiphers(Uint8List key) {
    encryptor = new Rc4(key);
    decryptor = new Rc4(key);

    for (var k = 0; k < key.length; k++) {
      encryptor.prga();
      decryptor.prga();
    }
  }

  void updateCiphers(int clientSeed, Uint8List serverNonce) {
    var newNonce = scrambleNonce(clientSeed, serverNonce);
    var key = utf8.encode(initialKey + newNonce);

    initializeCiphers(key);
  }

  static String scrambleNonce(int clientSeed, Uint8List serverNonce) {
    var scrambler = new Scrambler(clientSeed);

    var byte100 = 0;
    for (var i = 0; i < 100; i++) byte100 = scrambler.getByte();

    String newNonce = "";

    for (var i = 0; i < serverNonce.lengthInBytes; i++) {
      int c = serverNonce[i] ^ (scrambler.getByte() & byte100);
      newNonce += c.toString();
    }

    return newNonce;
  }
}
