class GameStatus {
  String gameName;
  int status;
  String latestFingerprintSha;
  String latestFingerprintVersion;
  int lastUpdated;

  GameStatus();

  GameStatus.fromJson(Map<String, dynamic> json)
      : gameName = json["gameName"],
        status = json["status"],
        latestFingerprintSha = json["latestFingerprintSha"],
        latestFingerprintVersion = json["latestFingerprintVersion"],
        lastUpdated = json["lastUpdated"];
}
