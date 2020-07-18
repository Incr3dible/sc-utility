import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sc_utility/utils/flutterextentions.dart';
import '../resources.dart';
import '../api/models/GameStatus.dart';
import '../api/ApiClient.dart';

class StatusPage extends StatefulWidget {
  @override
  StatusPageState createState() => StatusPageState();
}

class StatusPageState extends State<StatusPage> {
  Resources resources;
  List<GameStatus> gameList = new List<GameStatus>();
  bool isLoading = false;

  @override
  void initState() {
    resources = Resources.getInstance();
    requestStatusList();

    super.initState();
  }

  void requestStatusList() async {
    setState(() {
      isLoading = true;
    });

    var statusList = await ApiClient.getGameStatus();

    if (statusList != null) {
      gameList = statusList;

      setState(() {
        isLoading = false;
      });
    } else {
      FlutterExtensions.showPopupDialogWithActionAndCancel(
          context,
          "Connection error",
          "Couldn't connect to the server. Please try again.",
          "Try again",
          () => {requestStatusList()},
          false);
      setState(() {
        isLoading = false;
      });
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
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : gameList.length == 0
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
                          "Swipe down to try again and check your internet connection.",
                          textAlign: TextAlign.center,
                        )
                      ],
                    )
                  ],
                )
              : ListView.builder(
                  padding: EdgeInsets.only(top: 8, left: 5, right: 5),
                  itemCount: gameList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildGameStatus(gameList.elementAt(index));
                  },
                ),
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
        statusName = "Maintenance";
        break;
      case 3:
        statusName = "Content Update";
        statusColor = Colors.yellow;
        break;
    }

    return Container(
      child: Card(
        elevation: 5,
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
                        Navigator.pushNamed(context, "/changelog");
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
      margin: EdgeInsets.only(top: 5, bottom: 5),
    );
  }
}
