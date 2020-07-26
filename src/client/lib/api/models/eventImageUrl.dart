class EventImageUrl {
  String gameName;
  String imageUrl;

  EventImageUrl(this.gameName, this.imageUrl);

  Map<String, dynamic> toJson() => {"gameName": gameName, "imageUrl": imageUrl};
}
