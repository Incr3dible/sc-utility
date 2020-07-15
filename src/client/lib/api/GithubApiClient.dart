import 'package:http/http.dart' as http;
import 'models/Tags.dart';

class GithubApiClient {
  static Future<bool> isNewTagAvailable(String currentTag) async {
    var request = await http
        .get("https://api.github.com/repos/Incr3dible/sc-utility/tags");

    if (request.statusCode == 200) {
      var tags = Tags.fromJson(request.body);

      return tags.tags.first.name != currentTag;
    } else {
      print(request.statusCode);
      return false;
    }
  }
}
