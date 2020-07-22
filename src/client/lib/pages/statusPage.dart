import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sc_utility/pages/changelog.dart';
import 'package:sc_utility/translationProvider.dart';
import 'package:sc_utility/utils/flutterextentions.dart';
import '../resources.dart';
import '../api/models/GameStatus.dart';
import '../api/ApiClient.dart';

class StatusPage extends StatefulWidget {
  @override
  StatusPageState createState() => StatusPageState();
}

class StatusPageState extends State<StatusPage>
    with SingleTickerProviderStateMixin {
  Resources resources;
  List<GameStatus> gameList = new List<GameStatus>();
  bool isLoading = true;
  bool isTimedOut = false;
  Timer statusTimer;
  AnimationController animationController;
  Animation<double> opacityAnimation;

  @override
  void initState() {
    super.initState();

    resources = Resources.getInstance();
    resources.statusPage = this;

    statusTimer = new Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        isTimedOut = true;
      });
    });

    animationController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    opacityAnimation =
        Tween<double>(begin: 0.5, end: 1.0).animate(animationController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              animationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              animationController.forward();
            }
          });

    animationController.forward();
  }

  void requestStatusList() async {
    setState(() {
      isLoading = true;
    });

    var statusList = await ApiClient.getGameStatus();

    if (statusList != null) {
      setState(() {
        gameList = statusList;
        isLoading = false;
      });
    } else {
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

  Future<Null> onRefresh(BuildContext context) async {
    requestStatusList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return onRefresh(context);
      },
      child: Column(
        children: <Widget>[
          buildLive(),
          Flexible(
            fit: FlexFit.tight,
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : gameList.length == 0
                    ? buildConnectionError()
                    : ListView.builder(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        itemCount: gameList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return buildGameStatus(gameList.elementAt(index));
                        },
                      ),
          ),
        ],
      ),
    );
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
                        opacity: opacityAnimation.value,
                        child: Icon(
                          Icons.brightness_1,
                          color: Colors.red,
                        ),
                      );
                    })
              ],
            ),
            title: Text("LIVE"),
            subtitle: Text("updating the status every 20 seconds"),
            trailing: OutlineButton(
              highlightedBorderColor: Colors.red,
              onPressed: () {},
              child: Text("PAUSE"),
            ),
          ),
          padding: EdgeInsets.all(0),
        ),
      ),
      margin: EdgeInsets.only(top: 8, left: 5, right: 5),
    );
  }

  Widget buildConnectionError() {
    return ListView(
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
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    status.gameName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.brightness_1,
                    color: statusColor,
                  ),
                  title: Text("Status"),
                  subtitle: Text(statusName),
                ),
                ListTile(
                  trailing: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.history),
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new ChangelogPage(status.gameName)));
                      },
                    ),
                  ),
                  leading: Icon(
                    Icons.fingerprint,
                  ),
                  title: Text(status.latestFingerprintVersion),
                  subtitle: Text(status.latestFingerprintSha),
                )
              ],
            )),
      ),
      margin: EdgeInsets.only(top: 8),
    );
  }
}
