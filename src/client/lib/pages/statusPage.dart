import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sc_utility/api/models/ApiConfig.dart';
import 'package:sc_utility/translationProvider.dart';
import 'package:sc_utility/utils/flutterextentions.dart';
import 'package:sc_utility/widgets/ExpansionListTile.dart';
import '../resources.dart';
import '../api/models/GameStatus.dart';
import '../api/ApiClient.dart';
import 'changelogPage.dart';

class StatusPage extends StatefulWidget {
  @override
  StatusPageState createState() => StatusPageState();
}

class StatusPageState extends State<StatusPage>
    with SingleTickerProviderStateMixin {
  Resources resources;
  List<GameStatus> gameList = new List<GameStatus>();
  bool isLoading = true;
  Timer statusTimer;
  AnimationController animationController;
  Animation<double> opacityAnimation;
  bool liveModeOn = false;
  bool maintenance = false;

  @override
  void initState() {
    super.initState();

    resources = Resources.getInstance();
    resources.statusPage = this;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);

    opacityAnimation = Tween<double>(begin: 0.4, end: 1.0)
        .animate(animationController)
          ..addStatusListener(handleStatusChanged);

    animationController.forward();

    prepare();
  }

  void prepare() async {
    var config = await ApiClient.getApiConfig();
    if (config != null) {
      setState(() {
        maintenance = config.maintenance;
      });

      if (config.globalLiveMode ?? false) switchLiveMode();
    }
  }

  void handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reverse();
    } else if (status == AnimationStatus.dismissed) {
      animationController.forward();
    }
  }

  void requestStatusList({bool showLoading = true}) async {
    var config = await ApiClient.getApiConfig();
    if (config != null) {
      setState(() {
        maintenance = config.maintenance;
      });
    } else
      setState(() {
        maintenance = false;
      });

    if (showLoading)
      setState(() {
        isLoading = true;
      });

    var statusList = await ApiClient.getGameStatus();

    if (statusList != null) {
      setState(() {
        gameList = statusList;

        if (showLoading) isLoading = false;
      });
    } else {
      if (showLoading) {
        setState(() {
          isLoading = false;
        });

        FlutterExtensions.showPopupDialogWithActionAndCancel(
            context,
            TranslationProvider.get("TID_CONNECTION_ERROR"),
            TranslationProvider.get("TID_CONNECTION_ERROR_DESC"),
            TranslationProvider.get("TID_TRY_AGAIN"),
            () => {requestStatusList()},
            false);
      }
    }
  }

  Future<Null> onRefresh(BuildContext context) async {
    requestStatusList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return onRefresh(context);
      },
      child: maintenance
          ? buildMaintenaceInfo()
          : Column(
              children: <Widget>[
                buildLive(),
                Flexible(
                  fit: FlexFit.tight,
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : gameList.length == 0
                          ? buildConnectionError()
                          : ListView.builder(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              itemCount: gameList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return buildGameStatus(
                                    gameList.elementAt(index));
                              },
                            ),
                ),
              ],
            ),
    );
  }

  Widget buildMaintenaceInfo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: AnimatedBuilder(
                animation: animationController,
                builder: (_, child) {
                  return Opacity(
                    opacity: liveModeOn ? opacityAnimation.value : 1,
                    child: const Icon(
                      Icons.warning,
                      color: Colors.orange,
                      size: 50,
                    ),
                  );
                }),
          ),
          Container(
            margin: const EdgeInsets.only(left: 5, right: 5),
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Text(
                        TranslationProvider.get("TID_MAINTENANCE"),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Text(
                          TranslationProvider.get("TID_API_MAINTENANCE_DESC"),
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      OutlineButton(
                        onPressed: () {
                          requestStatusList();

                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Row(
                              children: [
                                Container(
                                  child: const Icon(Icons.refresh),
                                  padding: const EdgeInsets.all(5),
                                ),
                                const Text('Refreshed!')
                              ],
                            ),
                            duration: const Duration(seconds: 1),
                          ));
                        },
                        child: Text(
                          TranslationProvider.get("TID_TRY_AGAIN")
                              .toUpperCase(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void switchLiveMode() {
    if (liveModeOn) {
      statusTimer.cancel();
    } else {
      statusTimer = new Timer.periodic(Duration(seconds: 10), (timer) {
        requestStatusList(showLoading: false);
      });
    }

    setState(() {
      liveModeOn = !liveModeOn;
      debugPrint("LiveMode: " + liveModeOn.toString());
    });
  }

  Widget buildLive() {
    return Container(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedBuilder(
                    animation: animationController,
                    builder: (_, child) {
                      return Opacity(
                        opacity: liveModeOn ? opacityAnimation.value : 1,
                        child: const Icon(
                          Icons.brightness_1,
                          color: Colors.red,
                        ),
                      );
                    })
              ],
            ),
            title: const Text("LIVE"),
            subtitle: Text(TranslationProvider.get("TID_LIVE_DESC")),
            trailing: OutlineButton(
              highlightedBorderColor: Colors.red,
              onPressed: switchLiveMode,
              child: Text(liveModeOn ? "STOP" : "START"),
            ),
          ),
        ),
      ),
      margin: const EdgeInsets.only(top: 8, left: 5, right: 5),
    );
  }

  Widget buildConnectionError() {
    return ListView(
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
    );
  }

  Widget buildGameStatus(GameStatus status) {
    var statusColor = Colors.green;
    var statusName = "Online";

    switch (status.status) {
      case 0:
        statusColor = Colors.green;
        statusName = "Online";
        break;
      case 1:
        statusColor = Colors.red;
        statusName = "Offline";
        break;
      case 2:
        statusColor = Colors.orange;
        statusName = TranslationProvider.get("TID_MAINTENANCE");
        break;
      case 3:
        statusName = TranslationProvider.get("TID_CONTENT_UPDATE");
        statusColor = Colors.yellow;
        break;
    }

    return Container(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
            decoration: BoxDecoration(
                border: Border(left: BorderSide(color: statusColor, width: 4))),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    status.gameName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                ExpansionListTile(
                    leading: Icon(
                      Icons.brightness_1,
                      color: statusColor,
                    ),
                    title: const Text("Status"),
                    subtitle: Text(statusName),
                    /*trailing: IconButton(
                    icon: Icon(Icons.report),
                    onPressed: () {},
                  ),*/
                    children: status.latestFingerprintVersion == "unknown"
                        ? null
                        : [
                            ListTile(
                              trailing: Builder(
                                builder: (context) => IconButton(
                                  icon: const Icon(Icons.history),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                new ChangelogPage(
                                                    status.gameName)));
                                  },
                                ),
                              ),
                              leading: const Icon(
                                Icons.fingerprint,
                              ),
                              title: Text(status.latestFingerprintVersion),
                              subtitle: Text(status.latestFingerprintSha),
                            )
                          ]),
              ],
            )),
      ),
      margin: const EdgeInsets.only(top: 8),
    );
  }
}
