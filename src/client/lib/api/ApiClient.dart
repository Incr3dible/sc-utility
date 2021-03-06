import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:sc_utility/api/models/ApiConfig.dart';
import 'package:sc_utility/api/models/ApiStatus.dart';
import 'package:sc_utility/api/models/FingerprintLog.dart';
import 'package:sc_utility/api/models/eventImageUrl.dart';
import 'models/GameStatus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseHost = "https://api.incinc.xyz";
  //static const String baseHost = "http://192.168.2.150:5000";

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

  static Future<ApiStatus> getApiStatus() async {
    try {
      var request =
          await http.get(baseHost + "/apistatus").timeout(Duration(seconds: 5));

      if (request.statusCode == 200) {
        var status = ApiStatus.fromJson(json.decode(request.body));

        debugPrint("GET /apistatus - 200");
        return status;
      } else {
        debugPrint("GET /apistatus - " + request.statusCode.toString());
        return null;
      }
    } catch (exception) {
      debugPrint("GET /apistatus - " + exception.toString());
      return null;
    }
  }

  static Future<ApiConfig> getApiConfig() async {
    try {
      var request =
          await http.get(baseHost + "/config").timeout(Duration(seconds: 5));

      if (request.statusCode == 200) {
        var status = ApiConfig.fromJson(json.decode(request.body));

        debugPrint("GET /config - 200");
        return status;
      } else {
        debugPrint("GET /config - " + request.statusCode.toString());
        return null;
      }
    } catch (exception) {
      debugPrint("GET /config - " + exception.toString());
      return null;
    }
  }

  static Future<List<FingerprintLog>> getFingerprintLog(String gameName) async {
    try {
      var request = await http
          .get(baseHost + "/fingerprintHistory?gameName=" + gameName)
          .timeout(Duration(seconds: 5));

      if (request.statusCode == 200) {
        var list = (json.decode(request.body) as List)
            .map((p) => FingerprintLog.fromJson(p))
            .toList();

        debugPrint("GET /fingerprintHistory?gameName=" + gameName + " - 200");
        return list;
      } else {
        debugPrint("GET /fingerprintHistory?gameName=" +
            gameName +
            " - " +
            request.statusCode.toString());
        return null;
      }
    } catch (exception) {
      debugPrint("GET /fingerprintHistory?gameName=" +
          gameName +
          " - " +
          exception.toString());
      return null;
    }
  }

  static Future<bool> addEventImage(String gameName, String imageUrl) async {
    try {
      var request = await http.post(baseHost + "/event",
          body: jsonEncode(new EventImageUrl(gameName, imageUrl).toJson()),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json"
          }).timeout(Duration(seconds: 5));

      if (request.statusCode == 200) {
        //debugPrint("POST /event - 200");
        return true;
      } else {
        debugPrint("POST /event - " + request.statusCode.toString());
        return false;
      }
    } catch (exception) {
      debugPrint("POST /event - " + exception.toString());
      return null;
    }
  }

  static Future<bool> saveApiConfig(String devToken, ApiConfig config) async {
    try {
      var request = await http.post(baseHost + "/config?devToken=" + devToken,
          body: jsonEncode(config.toJson()),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json"
          }).timeout(Duration(seconds: 5));

      if (request.statusCode == 200) {
        return true;
      } else {
        debugPrint("POST /config - " + request.statusCode.toString());
        return false;
      }
    } catch (exception) {
      debugPrint("POST /config - " + exception.toString());
      return null;
    }
  }

  static Future<List<EventImageUrl>> getEventImages(String gameName) async {
    try {
      var request = await http
          .get(baseHost + "/event?gameName=" + gameName)
          .timeout(Duration(seconds: 5));

      if (request.statusCode == 200) {
        var list = (json.decode(request.body) as List)
            .map((p) => EventImageUrl.fromJson(p))
            .toList();

        debugPrint("GET /event?gameName=" + gameName + " - 200");
        return list;
      } else {
        debugPrint("GET /event?gameName=" +
            gameName +
            " - " +
            request.statusCode.toString());
        return null;
      }
    } catch (exception) {
      debugPrint(
          "GET /event?gameName=" + gameName + " - " + exception.toString());
      return null;
    }
  }
}
