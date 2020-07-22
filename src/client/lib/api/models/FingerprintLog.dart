class FingerprintLog {
  String sha;
  String version;
  int timestamp;

  FingerprintLog();

  FingerprintLog.fromJson(Map<String, dynamic> json)
      : sha = json["sha"],
        version = json["version"],
        timestamp = json["timestamp"];
}
