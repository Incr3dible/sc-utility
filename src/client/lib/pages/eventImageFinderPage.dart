import 'package:flutter/material.dart';
import 'package:sc_utility/api/ApiClient.dart';
import 'package:sc_utility/translationProvider.dart';
import 'package:sc_utility/utils/rootutil.dart';

class EventImageFinderPage extends StatefulWidget {
  @override
  EventImageFinderPageState createState() => EventImageFinderPageState();
}

class EventImageFinderPageState extends State<EventImageFinderPage> {
  bool isLoading = true;
  bool errorOccurred = false;

  var games = {
    new Game("Clash Royale", "com.supercell.clashroyale"),
    new Game("Clash of Clans", "com.supercell.clashofclans")
  };

  @override
  void initState() {
    super.initState();

    searchForEvents();
  }

  void searchForEvents() async {
    await Future.delayed(Duration(milliseconds: 500));

    await Future.forEach(games, (game) async {
      var isInstalled = await gameInstalled(game.package);

      if (isInstalled == null) {
        print(game.name + " cache is empty!");
        return;
      } else if (!isInstalled) {
        print(game.name + " is not installed!");
        return;
      }

      var remoteEvents = await ApiClient.getEventImages(game.name);
      var localEvents = await getEvents(game.package);

      for (var i = 0; i < localEvents.length; i++) {
        var localEvent = localEvents.elementAt(i);

        if (remoteEvents.indexWhere(
                (element) => element.imageUrl.contains(localEvent)) ==
            -1) {
          var result = await ApiClient.addEventImage(game.name, localEvent);

          if (result == null) {
            setState(() {
              errorOccurred = true;
            });
            break;
          }
        }
      }
    });

    setState(() {
      isLoading = false;
    });
  }

  Future<List<String>> getEvents(String gamePackage) async {
    var sourceDir = '/data/data/$gamePackage/cache/events';
    var sourceDirContent = await RootUtils.listContent(sourceDir);

    return sourceDirContent.where((item) {
      return item.endsWith(".png");
    }).toList();
  }

  Future<bool> gameInstalled(String gamePackage) async {
    if (!await RootUtils.dirExists('/data/data/$gamePackage/')) {
      return true;
    } else if (!await RootUtils.dirExists(
        '/data/data/$gamePackage/cache/events/')) {
      return null;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Event Image Finder"),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        ),
        body: errorOccurred
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.error,
                          size: 40,
                        )),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        TranslationProvider.get("TID_UNKNOWN_ERROR"),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: OutlineButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("OK"),
                        ))
                  ],
                ),
              )
            : isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const CircularProgressIndicator(),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(TranslationProvider.get("TID_UPLOAD")),
                        )
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.cloud_done,
                              size: 40,
                            )),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            TranslationProvider.get("TID_EVENT_DESC"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child: OutlineButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("OK"),
                            ))
                      ],
                    ),
                  ));
  }
}

class Game {
  String name;
  String package;

  Game(this.name, this.package);
}
