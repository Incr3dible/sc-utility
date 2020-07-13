import 'dart:convert';
import 'Tag.dart';

class Tags {
  List<Tag> tags;

  Tags.fromJson(String value) {
    tags = (json.decode(value) as List).map((p) => Tag.fromJson(p)).toList();
  }
}
