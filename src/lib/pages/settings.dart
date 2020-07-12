import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../resources.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<SettingsPage> {
  Resources resources;

  bool notificationsOn = false;
  bool nightModeOn = false;
  int nightModeState = 2;

  @override
  void initState() {
    resources = Resources.getInstance();
    nightModeState = resources.prefs.getInt("themeMode") ?? 2;
    notificationsOn = resources.prefs.getBool("notifications") ?? true;

    super.initState();
  }

  void onNotificationsChanged() {
    if (notificationsOn) {
      resources.prefs.setBool("notifications", true);
      resources.firebaseMessaging.subscribeToTopic("everyone");
    } else {
      resources.prefs.setBool("notifications", false);
      resources.firebaseMessaging.unsubscribeFromTopic("everyone");
    }
  }

  void handleRadioValueChanged(int value) {
    setState(() {
      nightModeState = value;
      resources.prefs.setInt("themeMode", value);

      switch (value) {
        case 0:
          {
            resources.myApp.updateThemeMode(ThemeMode.light);
            break;
          }

        case 1:
          {
            resources.myApp.updateThemeMode(ThemeMode.dark);
            break;
          }

        case 2:
          {
            resources.myApp.updateThemeMode(ThemeMode.system);
            break;
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          backgroundColor: Colors.blueGrey[900],
        ),
        body: Column(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: Text("Notifications"),
                  ),
                  Container(
                    child: ListTile(
                      onTap: () => {
                        setState(() {
                          notificationsOn = !notificationsOn;
                          onNotificationsChanged();
                        })
                      },
                      leading: notificationsOn
                          ? Icon(Icons.notifications_active)
                          : Icon(Icons.notifications_off),
                      title: Text(
                        "Maintenance Notifications",
                      ),
                      trailing: Switch(
                        value: notificationsOn,
                        onChanged: (value) {
                          setState(() {
                            notificationsOn = value;
                            onNotificationsChanged();
                          });
                        },
                        activeTrackColor: Colors.blueGrey[600],
                        activeColor: Colors.blueGrey[800],
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                      title: Text(
                    "Theme",
                  )),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<int>(
                          value: 0,
                          groupValue: nightModeState,
                          onChanged: handleRadioValueChanged,
                        ),
                        Text("Light"),
                        Radio<int>(
                          value: 1,
                          groupValue: nightModeState,
                          onChanged: handleRadioValueChanged,
                        ),
                        Text("Dark"),
                        Radio<int>(
                          value: 2,
                          groupValue: nightModeState,
                          onChanged: handleRadioValueChanged,
                        ),
                        Text("System"),
                      ],
                    ),
                  ),
                  Divider()
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              child: Center(
                  child: Text(
                "Built with ❤",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              )),
            )
          ],
        ));
  }
}
