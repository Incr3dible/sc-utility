import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sc_utility/api/ApiClient.dart';
import 'package:sc_utility/api/models/eventImageUrl.dart';
import 'package:share/share.dart';
import 'package:sc_utility/utils/flutterextentions.dart';

import '../resources.dart';
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
  Resources resources;

  @override
  void initState() {
    super.initState();
    resources = Resources.getInstance();

    controller = new TabController(length: games.length, vsync: this);
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

  List<Widget> buildTabs() {
    var tabs = new List<Tab>();

    for (var i = 0; i < games.length; i++) {
      var game = games.elementAt(i);
      var count = images.elementAt(i)?.length ?? 0;

      tabs.add(Tab(
        child: count > 0
            ? Text(
                game + " (" + count.toString() + ")",
                textAlign: TextAlign.center,
              )
            : Text(game),
      ));
    }

    return tabs;
  }

  List<List<Widget>> images = games.map((e) => new List<Widget>()).toList();

  void requestEventImages({String keywordFilter}) async {
    setState(() {
      isLoading = true;
      images.update(currentIndex, null);
    });

    var events = await ApiClient.getEventImages(gameName);

    if (events != null) {
      images.update(currentIndex, new List<Widget>());

      events.forEach((element) {
        if (keywordFilter == null)
          images.elementAt(currentIndex).add(buildImage(element));
        else if (element.imageUrl.contains(keywordFilter))
          images.elementAt(currentIndex).add(buildImage(element));
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var tabs = buildTabs();

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
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  print(value);
                  requestEventImages(keywordFilter: value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "",
                    child: Text(
                      TranslationProvider.get("TID_SHOW_ALL"),
                    ),
                  ),
                  PopupMenuItem(
                    value: "offer",
                    child: Text(
                      TranslationProvider.get("TID_SHOP_OFFERS"),
                    ),
                  ),
                  PopupMenuItem(
                    value: "popup",
                    child: Text(
                      "Popup",
                    ),
                  ),
                  PopupMenuItem(
                    value: "header",
                    child: Text(
                      "Header",
                    ),
                  ),
                  PopupMenuItem(
                    value: "challenge",
                    child: Text(
                      TranslationProvider.get("TID_CHALLENGE"),
                    ),
                  )
                ],
                elevation: 4,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  requestEventImages();
                },
              )
            ],
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : TabBarView(
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
                  padding: const EdgeInsets.all(5),
                  child: Hero(
                    tag: eventImage.imageUrl,
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
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      dateString,
                      style: const TextStyle(
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

    return images == null
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
                        mediaQuery.orientation == Orientation.portrait ? 2 : 4,
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
        title: Text(
          image.imageUrl.split(".com/")[1],
          overflow: TextOverflow.fade,
        ),
        actions: <Widget>[
          Builder(
              builder: (context) => IconButton(
                    icon: Icon(Icons.content_copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: image.imageUrl));

                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Row(
                          children: [
                            Container(
                              child: const Icon(Icons.attach_file),
                              padding: const EdgeInsets.all(5),
                            ),
                            Text(TranslationProvider.get("TID_COPIED"))
                          ],
                        ),
                        duration: const Duration(seconds: 1),
                      ));
                    },
                  )),
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
            child: Hero(
              tag: image.imageUrl,
              child: Image.network(image.imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}
