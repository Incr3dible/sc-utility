class Tag {
  String name;
  String ZipBallUrl;
  String TarBallUrl;
  String NodeId;

  Tag();

  Tag.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        ZipBallUrl = json["zipball_url"],
        TarBallUrl = json["tarball_url"],
        NodeId = json["node_id"];
}
