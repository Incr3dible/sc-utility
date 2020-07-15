import 'package:flutter/cupertino.dart';
import 'models/GameStatus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseHost = "http://192.168.2.150:5000";

  static Future<List<GameStatus>> getGameStatus() async {
    try {
      var request = await http
          .get(baseHost + "/gamestatus")
          .timeout(Duration(seconds: 5));

      if (request.statusCode == 200) {
        var list = (json.decode(request.body) as List)
            .map((p) => GameStatus.fromJson(p))
            .toList();

        debugPrint("GET /gamestatus - 200");
        return list;
      } else {
        debugPrint("GET /gamestatus - " + request.statusCode.toString());
        return null;
      }
    } catch (exception) {
      debugPrint("GET /gamestatus - " + exception.toString());
      return null;
    }
  }
}
