import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../resources.dart';

class StatusPage extends StatefulWidget {
  @override
  StatusPageState createState() => StatusPageState();
}

class StatusPageState extends State<StatusPage> {
  Resources resources;

  @override
  void initState() {
    super.initState();
    resources = Resources.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 8, left: 5, right: 5),
      children: <Widget>[
        buildGameStatus(
            "Clash Royale",
            "04044a73124aa57114be9a20a8c4c6dfec9ebefa",
            "3.2077.38",
            GameStatus.Online),
        buildGameStatus(
            "Clash of Clans",
            "04044a73124aa57114be9a20a8c4c6dfec9ebefa",
            "13.343.34",
            GameStatus.Maintenance),
        buildGameStatus(
            "Brawl Stars",
            "04044a73124aa57114be9a20a8c4c6dfec9ebefa",
            "13.343.34",
            GameStatus.Offline)
      ],
    );
  }

  Widget buildGameStatus(
      String gameName, String sha, String shaVersion, GameStatus status) {
    var statusColor = Colors.green;
    var statusName = "Online";

    switch (status) {
      case GameStatus.Online:
        statusColor = Colors.green;
        statusName = "Online";
        break;
      case GameStatus.Offline:
        statusColor = Colors.red;
        statusName = "Offline";
        break;
      case GameStatus.Maintenance:
        statusColor = Colors.orange;
        statusName = "Maintenance";
        break;
      case GameStatus.Update:
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
                    gameName,
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
                  title: Text(sha),
                  subtitle: Text(shaVersion),
                )
              ],
            )),
      ),
      margin: EdgeInsets.only(top: 5, bottom: 5),
    );
  }
}

enum GameStatus { Online, Offline, Maintenance, Update }
