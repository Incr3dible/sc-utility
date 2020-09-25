import 'package:sc_utility/utils/fingerprintUtils.dart';

class AssetFile {
  String sha;
  String file;
  String fingerprintSha;

  AssetFile.fromJson(Map<String, dynamic> json)
      : sha = json["sha"],
        file = json["file"];

  String getAssetUrl(String gameName) {
    return FingerprintUtils.getAssetHostByName(gameName) +
        fingerprintSha +
        "/" +
        file;
  }
}
