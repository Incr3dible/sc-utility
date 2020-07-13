import '../../Message.dart';

class LoginFailedMessage extends Message {
  LoginFailedMessage(){
    id = 20103;
  }

  int reason = 0;
  String fingerprint = "";
  String reasonMessage;

  @override
  void decode() {
    reason = reader.readVInt();

    if(reason == 7)
      fingerprint = reader.readString();
  }

  @override
  void encode(){
    writer.writeInt(reason);
    writer.writeString(null); // Fingerprint
    writer.writeString(null);
    writer.writeString(null); // ContentURL
    writer.writeString(null); // UpdateURL
    writer.writeString(reasonMessage);
  }

  @override
  void process() {
    var page = resources.clientPageState;

    if(reason == 10){
      page.setLoading(false, 4);
  }
    else if(reason == 7){
      var version = fingerprint.split(",\"version\":\"").last.split("\"}").first;
      var sha = fingerprint.split("sha\":\"").last.split("\",\"").first;

      print(sha);
      print(version);

      var log = resources.clientPageState.fingerprintLog;
      log.addFingerprint(sha, version);
      resources.prefs.setString("fingerprintLog", log.saveToJson());

      resources.prefs.setString("sha", sha);
      resources.prefs.setString("version", version);

      page.setLoading(false, 3);
    }
    else{
      print("Reason: $reason");
      page.setLoading(false, 2);
    }
  }
}
