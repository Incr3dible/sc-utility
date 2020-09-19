import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sc_utility/api/ApiClient.dart';
import 'package:sc_utility/api/models/FingerprintLog.dart';
import 'package:sc_utility/pages/fingerprintComparePage.dart';
import 'package:sc_utility/utils/flutterextentions.dart';
import '../resources.dart';
import '../translationProvider.dart';

class ChangelogPage extends StatefulWidget {
  final String gameName;

  ChangelogPage(this.gameName);

  @override
  ChangelogPageState createState() => ChangelogPageState(gameName);
}

class ChangelogPageState extends State<ChangelogPage>
    with SingleTickerProviderStateMixin {
  Resources resources;
  TabController controller;
  String gameName;
  bool isLoading = false;
  int currentIndex;

  ChangelogPageState(this.gameName);

  bool compareModeOn = false;
  List<FingerprintLog> compareList = new List<FingerprintLog>();

  @override
  void initState() {
    resources = Resources.getInstance();
    var currentGameIndex = games.indexOf(gameName);
    controller = new TabController(
        length: games.length, vsync: this, initialIndex: currentGameIndex);
    controller.addListener(onGameChanged);

    super.initState();

    onGameChanged();
  }

  void onGameChanged() async {
    if (currentIndex == controller.index) return;

    currentIndex = controller.index;
    gameName = games[currentIndex];

    if (logList.elementAt(currentIndex).length == 0) requestLog(gameName);
  }

  void requestLog(String gameName) async {
    setState(() {
      isLoading = true;
    });

    var fingerprintList = await ApiClient.getFingerprintLog(gameName);

    if (fingerprintList != null) {
      setState(() {
        logList.update(currentIndex, fingerprintList);
        isLoading = false;
      });
    } else {
      setState(() {
        logList.update(currentIndex, null);
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

  List<List<FingerprintLog>> logList =
      games.map((e) => new List<FingerprintLog>()).toList();

  List<Widget> buildTabs() {
    var tabs = new List<Tab>();

    for (var i = 0; i < games.length; i++) {
      var game = games.elementAt(i);
      var count = logList.elementAt(i)?.length ?? 0;

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

  @override
  Widget build(BuildContext context) {
    var tabs = buildTabs();

    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
            appBar: AppBar(
              leading: compareModeOn
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          compareModeOn = false;
                        });
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
              actions: <Widget>[
                IconButton(
                  tooltip:
                      TranslationProvider.get("TID_FINGERPRINT_COMPARISON"),
                  icon: const Icon(Icons.compare_arrows),
                  onPressed: () {
                    setState(() {
                      compareModeOn = !compareModeOn;
                      compareList.clear();
                    });
                  },
                )
              ],
              title: Text(compareModeOn
                  ? compareList.length.toString()
                  : TranslationProvider.get("TID_FINGERPRINT_HISTORY")),
              bottom: compareModeOn
                  ? const PreferredSize(
                      preferredSize: Size.fromHeight(0),
                      child: SizedBox.shrink())
                  : TabBar(
                      controller: controller,
                      isScrollable: false,
                      tabs: tabs,
                    ),
            ),
            body: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : TabBarView(
                    controller: controller,
                    children: logList.map((e) => buildChangelog(e)).toList())));
  }

  Future<Null> onRefresh(BuildContext context) async {
    requestLog(gameName);
  }

  Widget buildChangelog(List<FingerprintLog> logs) {
    return RefreshIndicator(
        onRefresh: () {
          return onRefresh(context);
        },
        child: logs == null
            ? ListView(
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      const Padding(
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
                padding: const EdgeInsets.only(top: 8, left: 5, right: 5),
                itemCount: logs.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = logs.elementAt(index);
                  return buildLogItem(item);
                },
              ));
  }

  Widget buildLogItem(FingerprintLog log) {
    var date =
        new DateTime.fromMillisecondsSinceEpoch(log.timestamp, isUtc: true)
            .toLocal();
    var dateString = date.month.toString() +
        "/" +
        date.day.toString() +
        "/" +
        date.year.toString();

    return Builder(
      builder: (BuildContext context) => ListTile(
        title: Text(log.sha),
        subtitle: Text(dateString),
        onLongPress: log.hasJson
            ? () {
                setState(() {
                  if (!compareModeOn) {
                    compareList.clear();
                    compareList.add(log);
                    compareModeOn = true;
                  }
                });
              }
            : null,
        onTap: () {
          setState(() {
            if (compareList.contains(log)) {
              compareList.remove(log);
            }
          });
        },
        trailing: compareModeOn
            ? log.hasJson
                ? Checkbox(
                    onChanged:
                        compareList.length == 2 && !compareList.contains(log)
                            ? null
                            : (bool value) {
                                setState(() {
                                  if (value) {
                                    compareList.add(log);

                                    if (compareList.length == 2) {
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              new FingerprintComparePage(
                                                  compareList, gameName),
                                        ),
                                      );

                                      setState(() {
                                        compareModeOn = false;
                                      });
                                    }
                                  } else {
                                    compareList.remove(log);
                                  }
                                });
                              },
                    value: compareList.contains(log),
                  )
                : null
            : IconButton(
                icon: const Icon(Icons.content_copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: log.sha));

                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Row(
                      children: [
                        Container(
                          child: const Icon(Icons.attach_file),
                          padding: const EdgeInsets.all(5),
                        ),
                        const Text('SHA copied to clipboard')
                      ],
                    ),
                    duration: const Duration(seconds: 1),
                  ));
                },
              ),
      ),
    );
  }
}
