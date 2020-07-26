class EventImageUrl {
  String gameName;
  String imageUrl;
  int timestamp;

  EventImageUrl(this.gameName, this.imageUrl);

  Map<String, dynamic> toJson() => {"gameName": gameName, "imageUrl": imageUrl};

  EventImageUrl.fromJson(Map<String, dynamic> json)
      : gameName = json["gameName"],
        imageUrl = json["imageUrl"],
        timestamp = json["timestamp"];
}
