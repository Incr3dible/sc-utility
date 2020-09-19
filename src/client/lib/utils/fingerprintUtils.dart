import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sc_utility/api/models/AssetFile.dart';
import 'package:sc_utility/api/models/Fingerprint.dart';
import 'package:sc_utility/api/models/FingerprintLog.dart';

class FingerprintUtils {
  static List<AssetFile> getChangedFiles(
      Fingerprint oldFingerprint, Fingerprint newFingerprint) {
    var changedFiles = new List<AssetFile>();

    oldFingerprint.files.forEach((file) {
      if (newFingerprint.files.indexWhere((element) =>
              element.file == file.file && element.sha != file.sha) >
          -1) {
        changedFiles.add(file);
      }
    });

    return changedFiles;
  }

  static List<AssetFile> getAddedFiles(
      Fingerprint oldFingerprint, Fingerprint newFingerprint) {
    var addedFiles = new List<AssetFile>();

    newFingerprint.files.forEach((file) {
      if (oldFingerprint.files
              .indexWhere((element) => element.file == file.file) ==
          -1) {
        addedFiles.add(file);
      }
    });

    return addedFiles;
  }

  static List<AssetFile> getRemovedFiles(
      Fingerprint oldFingerprint, Fingerprint newFingerprint) {
    var removedFiles = new List<AssetFile>();

    oldFingerprint.files.forEach((file) {
      if (newFingerprint.files
              .indexWhere((element) => element.file == file.file) ==
          -1) {
        removedFiles.add(file);
      }
    });

    return removedFiles;
  }

  static Future<Fingerprint> downloadFingerprint(
      FingerprintLog log, String gameName) async {
    var fingerprintJson = await http.get(
        "https://api.incinc.xyz/fingerprint?gameName=" +
            gameName +
            "&sha=" +
            log.sha);

    if (fingerprintJson.statusCode == 200)
      return Fingerprint.fromJson(json.decode(fingerprintJson.body));
    else
      return null;
  }

  static String getAssetHostByName(String gameName) {
    switch (gameName) {
      case "Clash Royale":
        return "http://7166046b142482e67b30-2a63f4436c967aa7d355061bd0d924a1.r65.cf1.rackcdn.com/";
      case "Clash of Clans":
        return "http://b46f744d64acd2191eda-3720c0374d47e9a0dd52be4d281c260f.r11.cf2.rackcdn.com/";
      case "Boom Beach":
        return "http://df70a89d32075567ba62-1e50fe9ed7ef652688e6e5fff773074c.r40.cf1.rackcdn.com/";
      case "Brawl Stars":
        return "http://a678dbc1c015a893c9fd-4e8cc3b1ad3a3c940c504815caefa967.r87.cf2.rackcdn.com/";
      case "HayDay Pop":
        return "https://d3br6iao8asuhe.cloudfront.net/";
      case "HayDay":
        return "https://c12049120.ssl.cf2.rackcdn.com/";
      default:
        return null;
    }
  }
}
