import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../resources.dart';
import '../translationProvider.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<SettingsPage> {
  Resources resources;

  bool notificationsOn = false;
  bool nightModeOn = false;
  int nightModeState = 2;
  int language = 0;

  @override
  void initState() {
    resources = Resources.getInstance();
    nightModeState = resources.prefs.getInt("themeMode") ?? 2;
    notificationsOn = resources.prefs.getBool("notifications") ?? true;
    language = resources.language();

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

  void onLanguageChanged(int value) {
    setState(() {
      language = value;
      resources.prefs.setInt("language", value);
    });
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
    var version = resources.packageInfo.version;
    var build = resources.packageInfo.buildNumber;

    return Scaffold(
        appBar: AppBar(
          title: Text(TranslationProvider.get("TID_SETTINGS")),
        ),
        body: Column(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: Text(TranslationProvider.get("TID_NOTIFICATIONS")),
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
                        TranslationProvider.get("TID_MAINTENANCE_NOTIFICATIONS"),
                      ),
                      subtitle: Text(TranslationProvider.get("TID_MAINTENANCE_NOTIFICATION_DESC")),
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
                      leading: Icon(Icons.style),
                      title: Text(
                        TranslationProvider.get("TID_THEME"),
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
                        Text(TranslationProvider.get("TID_LIGHT")),
                        Radio<int>(
                          value: 1,
                          groupValue: nightModeState,
                          onChanged: handleRadioValueChanged,
                        ),
                        Text(TranslationProvider.get("TID_DARK")),
                        Radio<int>(
                          value: 2,
                          groupValue: nightModeState,
                          onChanged: handleRadioValueChanged,
                        ),
                        Text("System"),
                      ],
                    ),
                  ),
                  Divider(),
                  ListTile(
                      leading: Icon(Icons.language),
                      title: Text(TranslationProvider.get("TID_LANGUAGE"))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      flagButton(0, "assets/uk.png", language == 0),
                      flagButton(1, "assets/de.png", language == 1),
                    ],
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text(
                      "Info",
                    ),
                    subtitle: Text("Version: $version Build: $build"),
                  ),
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

  Widget flagButton(int index, String assetImage, bool selected) {
    return Stack(
      children: <Widget>[
        Container(
          child: GestureDetector(
            onTap: () {
              onLanguageChanged(index);
            },
          ),
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          width: 45,
          height: 30,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(assetImage), fit: BoxFit.fill),
              borderRadius: BorderRadius.circular(6)),
        ),
        selected
            ? Positioned.fill(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                child: Icon(
                  Icons.done,
                  size: 20,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ))
            : SizedBox.shrink()
      ],
    );
  }
}
