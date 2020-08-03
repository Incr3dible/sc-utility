class AssetFile {
  String sha;
  String file;

  AssetFile.fromJson(Map<String, dynamic> json)
      : sha = json["sha"],
        file = json["file"];
}
