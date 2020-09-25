class AssetFile {
  String sha;
  String file;
  String fingerprintSha;

  AssetFile.fromJson(Map<String, dynamic> json)
      : sha = json["sha"],
        file = json["file"];
}
