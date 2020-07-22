import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sc_utility/api/ApiClient.dart';
import 'package:sc_utility/api/models/FingerprintLog.dart';
import 'package:sc_utility/utils/flutterextentions.dart';
import '../resources.dart';
import '../translationProvider.dart';

class ChangelogPage extends StatefulWidget {
  String gameName;

  ChangelogPage(this.gameName);

  @override
  ChangelogPageState createState() => ChangelogPageState(gameName);
}

class ChangelogPageState extends State<ChangelogPage>
    with SingleTickerProviderStateMixin {
  Resources resources;
  TabController controller;
  String gameName;
  List<FingerprintLog> logList = new List<FingerprintLog>();
  bool isLoading = false;
  int currentIndex;

  ChangelogPageState(this.gameName);

  @override
  void initState() {
    resources = Resources.getInstance();
    var currentGameIndex = games.indexOf(gameName);
    controller = new TabController(
        length: tabs.length, vsync: this, initialIndex: currentGameIndex);
    controller.addListener(onGameChanged);

    super.initState();

    onGameChanged();
  }

  void onGameChanged() async {
    if (currentIndex == controller.index) return;
    currentIndex = controller.index;

    gameName = games[currentIndex];
    requestLog(gameName);
  }

  void requestLog(String gameName) async {
    setState(() {
      isLoading = true;
    });

    var fingerprintList = await ApiClient.getFingerprintLog(gameName);

    if (fingerprintList != null) {
      logList = fingerprintList;

      setState(() {
        isLoading = false;
      });
    } else {
      logList.clear();

      setState(() {
        isLoading = false;
      });

      FlutterExtensions.showPopupDialogWithActionAndCancel(
          context,
          TranslationProvider.get("TID_CONNECTION_ERROR"),
          TranslationProvider.get("TID_CONNECTION_ERROR_DESC"),
          TranslationProvider.get("TID_TRY_AGAIN"),
          () => {requestLog(gameName)},
          false);
    }
  }

  static const games = ["Clash Royale", "Brawl Stars", "HayDay Pop"];

  var tabs = games
      .map(
        (e) => Tab(
          text: e,
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(TranslationProvider.get("TID_FINGERPRINT_HISTORY")),
              bottom: TabBar(
                controller: controller,
                isScrollable: false,
                tabs: tabs,
              ),
            ),
            body: TabBarView(
                controller: controller,
                children: games.map((e) => buildChangelog()).toList())));
  }

  Future<Null> onRefresh(BuildContext context) async {
    requestLog(gameName);
  }

  Widget buildChangelog() {
    return RefreshIndicator(
        onRefresh: () {
          return onRefresh(context);
        },
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : logList.length == 0
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
                : ListView.builder(
                    padding: EdgeInsets.only(top: 8, left: 5, right: 5),
                    itemCount: logList.length,
                    itemBuilder: (BuildContext context, int index) {
                      var item = logList.elementAt(index);

                      return ListTile(
                        title: Text(item.sha),
                        subtitle: Text(item.timestamp.toString()),
                        trailing: IconButton(
                          icon: Icon(Icons.content_copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: item.sha));

                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Row(
                                children: [
                                  Container(
                                    child: Icon(Icons.attach_file),
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text('SHA copied to clipboard')
                                ],
                              ),
                              duration: Duration(seconds: 1),
                            ));
                          },
                        ),
                      );
                    },
                  ));
  }
}
