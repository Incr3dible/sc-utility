import 'package:flutter/material.dart';
import 'package:sc_utility/api/ApiClient.dart';
import 'package:sc_utility/api/models/eventImageUrl.dart';
import 'package:share/share.dart';
import 'package:sc_utility/utils/flutterextentions.dart';

import '../translationProvider.dart';

class EventGalleryPage extends StatefulWidget {
  @override
  EventGalleryPageState createState() => EventGalleryPageState();
}

class EventGalleryPageState extends State<EventGalleryPage>
    with SingleTickerProviderStateMixin {
  TabController controller;
  int currentIndex = 0;
  String gameName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = new TabController(length: tabs.length, vsync: this);
    controller.addListener(onGameChanged);

    gameName = games[0];
    requestEventImages();
  }

  void onGameChanged() async {
    if (currentIndex == controller.index) return;
    currentIndex = controller.index;

    gameName = games[currentIndex];

    if (images.elementAt(currentIndex).length == 0) requestEventImages();
  }

  static const games = ["Clash Royale", "Clash of Clans"];

  var tabs = games
      .map(
        (e) => Tab(
          text: e,
        ),
      )
      .toList();

  List<List<Widget>> images = games.map((e) => new List<Widget>()).toList();

  void requestEventImages() async {
    setState(() {
      isLoading = true;
      images.update(currentIndex, null);
    });

    var events = await ApiClient.getEventImages(gameName);

    if (events != null) {
      images.update(currentIndex, new List<Widget>());

      events.forEach((element) {
        images.elementAt(currentIndex).add(buildImage(element));
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(TranslationProvider.get("TID_EVENT_GALLERY")),
            bottom: TabBar(
              controller: controller,
              isScrollable: false,
              tabs: tabs,
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  requestEventImages();
                },
              )
            ],
          ),
          body: TabBarView(
              controller: controller,
              children: images.map((e) => buildImages(e)).toList()),
        ));
  }

  Widget buildImage(EventImageUrl eventImage) {
    var date = new DateTime.fromMillisecondsSinceEpoch(eventImage.timestamp,
            isUtc: true)
        .toLocal();
    var dateString = date.month.toString() +
        "/" +
        date.day.toString() +
        "/" +
        date.year.toString();

    return Card(
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
          onTap: () => {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new ImageView(eventImage),
                    ))
              },
          child: Stack(
            children: <Widget>[
              Center(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Image.network(
                    eventImage.imageUrl,
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    decoration: new BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                        )),
                    padding: EdgeInsets.all(5),
                    child: Text(
                      dateString,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget buildImages(List<Widget> images) {
    final mediaQuery = MediaQuery.of(context);

    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : images == null
            ? ListView(
                padding: EdgeInsets.all(20),
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Icon(Icons.cloud_off),
                      ),
                      Text(
                        TranslationProvider.get("TID_SWIPE_RETRY"),
                        textAlign: TextAlign.center,
                      )
                    ],
                  )
                ],
              )
            : CustomScrollView(
                primary: false,
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.all(10),
                    sliver: SliverGrid.count(
                        mainAxisSpacing: 1,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 5,
                        crossAxisCount:
                            mediaQuery.orientation == Orientation.portrait
                                ? 2
                                : 4,
                        children: images),
                  ),
                ],
              );
  }
}

class ImageView extends StatefulWidget {
  final EventImageUrl image;
  ImageView(this.image);

  @override
  ImageViewState createState() => ImageViewState(image);
}

class ImageViewState extends State<ImageView> {
  ImageViewState(this.image);

  EventImageUrl image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(image.gameName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(image.imageUrl);
            },
          )
        ],
      ),
      body: InteractiveViewer(
        child: Center(
          child: Container(
            child: Image.network(image.imageUrl),
          ),
        ),
      ),
    );
  }
}
