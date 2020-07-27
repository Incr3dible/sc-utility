import 'package:flutter/material.dart';
import 'package:sc_utility/api/ApiClient.dart';

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
  var images = new List<Widget>();

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

    requestEventImages();
  }

  static const games = ["Clash Royale", "Clash of Clans"];

  var tabs = games
      .map(
        (e) => Tab(
          text: e,
        ),
      )
      .toList();

  void requestEventImages() async {
    setState(() {
      isLoading = true;
      images.clear();
    });

    var events = await ApiClient.getEventImages(gameName);

    events.forEach((element) {
      var widget = Card(
          elevation: 5,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: EdgeInsets.all(5),
            child: Image.network(
              element.imageUrl,
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
          ));

      images.add(widget);
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.refresh),
            onPressed: () {
              requestEventImages();
            },
          ),
          appBar: AppBar(
            title: Text("Event Gallery"),
            bottom: TabBar(
              controller: controller,
              isScrollable: false,
              tabs: tabs,
            ),
          ),
          body: TabBarView(
              controller: controller,
              children: games.map((e) => buildImages()).toList()),
        ));
  }

  Widget buildImages() {
    final mediaQuery = MediaQuery.of(context);

    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : CustomScrollView(
            primary: false,
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
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
