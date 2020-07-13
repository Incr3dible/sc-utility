import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sc_utility/resources.dart';
import 'package:sc_utility/utils/rootutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sc_utility/utils/flutterextentions.dart';
import 'package:share/share.dart';

class EventPage extends StatefulWidget {
  EventPage(this.gameName, this.gamePackage, this.gameDir);

  final String gamePackage;
  final String gameName;
  final String gameDir;

  @override
  EventPageState createState() =>
      EventPageState(gameName, gamePackage, gameDir);
}

bool loadingFinished = false;
bool onlyShowCurrent = true;
List<EventImage> images;

class EventImage {
  Image image;
  String name;
  String path;
  String gameName;

  EventImage(this.image, this.name, this.path, this.gameName);
}

class EventPageState extends State<EventPage> {
  String gamePackage = "com.supercell.clashroyale";
  String gameName = "Clash Royale";
  String gameDir = "events";
  Resources resources;

  EventPageState(this.gameName, this.gamePackage, this.gameDir);

  @override
  void initState() {
    super.initState();

    resources = Resources.getInstance();

    loadingFinished = false;
    checkInstallation();
  }

  void checkInstallation() async {
    //await new Future.delayed(const Duration(milliseconds: 500)); // Let the UI load

    if (!await RootUtils.dirExists('/data/data/$gamePackage/')) {
      showErrorDialog(
          'No installation found', '$gameName can\'t be found on your device.');
    } else if (!await RootUtils.dirExists(
        '/data/data/$gamePackage/cache/events/')) {
      showErrorDialog('No Events found',
          '$gameName has been detected but no events are in the cache.\nTry running $gameName first and return back.');
    } else {
      await copyEventImages();
    }
  }

  Future<void> copyEventImages() async {
    var sourceDir = '/data/data/$gamePackage/cache/events';
    var destinationDir =
        (await getExternalStorageDirectory()).path + '/$gameDir';
    var list = (await RootUtils.listContent(sourceDir)).where((item) {
      return item.endsWith(".png");
    });

    if (!await RootUtils.dirExists(destinationDir)) {
      await RootUtils.createDir(destinationDir);
    }

    await Future.forEach(
        list,
        (item) async =>
            {await RootUtils.copyFile(sourceDir, item, destinationDir, item)});

    var files = await RootUtils.listContent(destinationDir);

    images = new List();
    await Future.forEach(
        files,
        (item) => {
              images.add(new EventImage(
                  Image.file(File('$destinationDir/$item')),
                  item,
                  '$destinationDir/$item',
                  gameName))
            });

    if (onlyShowCurrent)
      await remapImages();
    else
      setState(() {
        loadingFinished = true;
      });
  }

  Future<void> remapImages() async {
    setState(() {
      loadingFinished = false;
    });

    var sourceDir = '/data/data/$gamePackage/cache/events';
    var destinationDir =
        (await getExternalStorageDirectory()).path + '/$gameDir';
    var files = onlyShowCurrent
        ? (await RootUtils.listContent(sourceDir)).where((item) {
            return item.endsWith(".png");
          })
        : (await RootUtils.listContent(destinationDir)).where((item) {
            return item.endsWith(".png");
          });

    images = new List();
    await Future.forEach(
        files,
        (item) => {
              images.add(new EventImage(
                  Image.file(File('$destinationDir/$item')),
                  item,
                  '$destinationDir/$item',
                  gameName))
            });

    setState(() {
      loadingFinished = true;
    });
  }

  Widget buildCards(BuildContext context) {
    if (loadingFinished) {
      var builder = ListView.builder(
        itemCount: images.length,
        itemBuilder: (BuildContext ctx, int index) {
          var image = images[index];

          return Card(
            elevation: 8.0,
            child: InkWell(
              onTap: () => {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => new ImageView(image),
                    ))
              },
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(children: <Widget>[
                  image.image,
                ]),
              ),
            ),
          );
        },
        padding: EdgeInsets.all(15.0),
      );

      return builder;
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$gameName Event Images"),
        backgroundColor: Colors.blueGrey[900],
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              FlutterExtensions.showPopupDialog(context, "Event Images",
                  "Here you can see all event images that have been added while using this app.\n\nYou can view the original image from your file explorer (no root).");
            },
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: CheckedPopupMenuItem(
                    child: Text(
                      'Only show newest',
                    ),
                    checked: onlyShowCurrent,
                    value: 1,
                  ),
                )
              ].toList();
            },
            onSelected: (s) async {
              switch (s) {
                case 1:
                  {
                    onlyShowCurrent = !onlyShowCurrent;
                    await remapImages();
                    break;
                  }
              }
            },
          ),
        ],
      ),
      body: buildCards(context),
    );
  }

  void showErrorDialog(String title, String text) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(text),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class ImageView extends StatefulWidget {
  EventImage image;
  ImageView(this.image);

  @override
  ImageViewState createState() => ImageViewState(image);
}

class ImageViewState extends State<ImageView> {
  ImageViewState(this.image);

  EventImage image;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blueGrey[900], title: Text(image.name)),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;

            if (index == 0) {
              if (image.gameName == "Clash Royale") {
                Share.share(
                    'https://event-assets.clashroyale.com/' + image.name);
              } else {
                Share.share(
                    'https://event-assets.clashofclans.com/' + image.name);
              }
            } else {
              FlutterExtensions.showPopupDialog(context, "Not supported",
                  "This feature is not available yet.");
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.share,
            ),
            title: Text(
              "Share",
              style: TextStyle(),
            ),
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.save,
              ),
              title: Text(
                "Save",
                style: TextStyle(),
              ))
        ],
      ),
      body: Container(
          child: PhotoView(
        imageProvider: image.image.image,
      )),
    );
  }
}
