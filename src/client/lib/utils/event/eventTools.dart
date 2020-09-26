import 'package:sc_utility/api/ApiClient.dart';
import 'package:sc_utility/utils/rootutil.dart';

class EventTools {
  static Future<List<String>> getEvents(String gamePackage) async {
    var sourceDir = '/data/data/$gamePackage/cache/events';
    var sourceDirContent = await RootUtils.listContent(sourceDir);

    return sourceDirContent.where((item) {
      return item.endsWith(".png");
    }).toList();
  }

  static Future<bool> gameInstalled(String gamePackage) async {
    if (!await RootUtils.dirExists('/data/data/$gamePackage/')) {
      return true;
    } else if (!await RootUtils.dirExists(
        '/data/data/$gamePackage/cache/events/')) {
      return null;
    } else {
      return true;
    }
  }

  static Future<int> uploadEventFiles() async {
    int uploadedEventsCount = 0;

    await Future.forEach(games, (game) async {
      var isInstalled = await EventTools.gameInstalled(game.package);

      if (isInstalled == null) {
        print(game.name + " cache is empty!");
        uploadedEventsCount = -1;
        return;
      } else if (!isInstalled) {
        print(game.name + " is not installed!");
        uploadedEventsCount = -1;
        return;
      }

      var remoteEvents = await ApiClient.getEventImages(game.name);
      var localEvents = await EventTools.getEvents(game.package);

      for (var i = 0; i < localEvents.length; i++) {
        var localEvent = localEvents.elementAt(i);

        if (remoteEvents.indexWhere(
                (element) => element.imageUrl.contains(localEvent)) ==
            -1) {
          var result = await ApiClient.addEventImage(game.name, localEvent);

          if (result == null) {
            uploadedEventsCount = -1;
            break;
          }

          uploadedEventsCount++;
        }
      }
    });

    return uploadedEventsCount;
  }

  static var games = {
    new Game("Clash Royale", "com.supercell.clashroyale"),
    new Game("Clash of Clans", "com.supercell.clashofclans")
  };
}

class Game {
  String name;
  String package;

  Game(this.name, this.package);
}
