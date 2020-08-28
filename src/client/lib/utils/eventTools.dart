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
}
