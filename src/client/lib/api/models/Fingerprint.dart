import 'package:sc_utility/api/models/AssetFile.dart';

class Fingerprint {
  String sha;
  String version;
  List<AssetFile> files;

  Fingerprint.fromJson(Map<String, dynamic> json) {
    sha = json["sha"];
    version = json["version"];
    files = (json["files"] as List).map((p) => AssetFile.fromJson(p)).toList();
  }
}
