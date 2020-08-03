class FingerprintLog {
  String sha;
  String version;
  int timestamp;

  FingerprintLog();

  FingerprintLog.fromJson(Map<String, dynamic> json)
      : sha = json["sha"],
        version = json["version"],
        timestamp = json["timestamp"];

  int isNewer(String oldVersion) {
    var versionSplit = version.split('.');
    var oldSplit = oldVersion.split('.');

    var major = int.parse(versionSplit[0]);
    var build = int.parse(versionSplit[1]);
    var minor = int.parse(versionSplit[2]);

    if (major > int.parse(oldSplit[0])) {
      return 1;
    } else if (build > int.parse(oldSplit[1])) {
      return 1;
    } else if (minor > int.parse(oldSplit[2])) {
      return 1;
    }

    return 0;
  }
}
