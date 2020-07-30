import 'package:http/http.dart' as http;
import 'models/Tags.dart';

class GithubApiClient {
  static Future<AppUpdate> isNewTagAvailable(String currentTag) async {
    var request = await http
        .get("https://api.github.com/repos/Incr3dible/sc-utility/tags")
        .timeout(Duration(seconds: 5));

    if (request.statusCode == 200) {
      var tags = Tags.fromJson(request.body);

      return new AppUpdate(
          tags.tags.first.name != currentTag, tags.tags.first.name);
    } else {
      print(request.statusCode);
      return null;
    }
  }
}

class AppUpdate {
  bool isUpdateAvailable = false;
  String latestVersion;

  AppUpdate(this.isUpdateAvailable, this.latestVersion);
}
