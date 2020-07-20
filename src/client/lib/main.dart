import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sc_utility/pages/changelog.dart';
import 'package:sc_utility/pages/crclient.dart';
import 'package:sc_utility/pages/eventpage.dart';
import 'package:sc_utility/pages/settings.dart';
import 'package:sc_utility/pages/statusPage.dart';
import 'package:sc_utility/resources.dart';
import 'package:sc_utility/translationProvider.dart';
import 'package:sc_utility/utils/rootutil.dart';
import 'dart:async';
import 'package:root_access/root_access.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

bool _rootStatus = false;
String title = 'Supercell-Utility';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Resources resources = new Resources();
  ThemeMode themeMode = ThemeMode.system;

  @override
  void initState() {
    prepare();
    super.initState();
  }

  void prepare() async {
    await resources.init();
    resources.myApp = this;

    updateThemeMode(resources.themeMode());
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = Colors.green;

    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: themeColor,
        accentColor: themeColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
          primarySwatch: themeColor,
          accentColor: themeColor,
          toggleableActiveColor: themeColor,
          appBarTheme: AppBarTheme(color: themeColor),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.dark),
      themeMode: themeMode,
      home: MainPage(),
      routes: {
        '/cr-client': (context) => CrClientPage(),
        '/settings': (context) => SettingsPage(),
        '/changelog': (context) => ChangelogPage()
      },
    );
  }

  void updateThemeMode(ThemeMode tm) {
    setState(() {
      themeMode = tm;
    });
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = true;
  Resources resources;

  Future<void> initRootRequest() async {
    bool rootStatus = await RootAccess.rootAccess;
    if (rootStatus) {
      setState(() {
        _rootStatus = rootStatus;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      /*FlutterExtensions.showPopupDialogWithActionAndCancel(
          context,
          "Root error",
          "Root is required for this app, please make sure you give this app root access.",
          "Try again",
          () => {
                initRootRequest(),
                setState(() {
                  isLoading = false;
                })
              },
          false);*/
    }
  }

  void prepare() async {
    await initRootRequest();
    await Permission.storage.request();
    await RootUtils.grantStoragePermissions();

    //games = getGames();
  }

  @override
  void initState() {
    resources = Resources.getInstance();
    resources.currentContext = context;
    resources.mainPage = this;

    prepare();

    super.initState();
    print('Initialized app.');
  }

  Future<Null> onRefresh(BuildContext context) async {
    resources.clientPageState.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        //backgroundColor: Colors.blueGrey[900],
        /*flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: <Color>[
              Colors.green[800],
              Colors.green[600]
            ]))),*/
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        centerTitle: true,
      ),
      body: StatusPage(),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Flexible(
              fit: FlexFit.tight,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                    ),
                    accountEmail:
                        Text(TranslationProvider.get("TID_OPEN_SOURCE_DESC")),
                    accountName: Text(title),
                  ),
                  ListTile(
                    enabled: _rootStatus,
                    title: Text('CR Event Images (ROOT)'),
                    leading: Icon(
                      Icons.image,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (BuildContext context) => new EventPage(
                                "Clash Royale",
                                "com.supercell.clashroyale",
                                "events"),
                          ));
                    },
                  ),
                  ListTile(
                    enabled: _rootStatus,
                    title: Text(
                      'COC Event Images (ROOT)',
                    ),
                    leading: Icon(
                      Icons.image,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (BuildContext context) => new EventPage(
                                "Clash of Clans",
                                "com.supercell.clashofclans",
                                "events-coc"),
                          ));
                    },
                  ),
                  ListTile(
                    title: Text(
                      TranslationProvider.get("TID_SETTINGS"),
                    ),
                    leading: Icon(
                      Icons.settings,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    enabled: true,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.open_in_new),
              title: Text(TranslationProvider.get("TID_MORE")),
              subtitle: Text(TranslationProvider.get("TID_MORE_DESC")),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Discord',
              ),
              leading: Icon(
                Icons.chat,
              ),
              onTap: () {
                launchURL('https://discord.gg/XdTw2PZ');
              },
            ),
            ListTile(
              title: Text(
                'Github',
              ),
              leading: Icon(
                Icons.code,
              ),
              onTap: () {
                launchURL('https://github.com/Incr3dible/sc-utility');
              },
            )
          ],
        ),
      ),
    );
  }

  /*Widget buildMainMenuCards() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    var widgets = new List<Widget>();

    widgets.add(Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Center(
          child: Text(
            TranslationProvider.get("TID_WELCOME_MESSAGE"),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    ));

    widgets.addAll(buildGames());

    return ListView.builder(
        padding: EdgeInsets.only(top: 8, left: 5, right: 5),
        itemCount: widgets.length,
        itemBuilder: (BuildContext ctx, int index) {
          return widgets[index];
        });
  }

  List<ApplicationWithIcon> getGames() {
    var games = {
      "com.supercell.clashroyale",
      "com.supercell.clashofclans",
      "com.supercell.brawlstars",
      "com.supercell.haydaypop",
      "com.supercell.boombeach",
      "com.supercell.hayday"
    };

    var list = new List<ApplicationWithIcon>();

    games.forEach((element) async {
      if (await DeviceApps.isAppInstalled(element)) {
        list.add(await DeviceApps.getApp(element, true));

        if (list.length == games.length) {
          setState(() {
            isLoading = false;
          });
        }
      } else
        games.remove(element);
    });

    return list;
  }

  List<Widget> buildGames() {
    var list = new List<Widget>();

    if (games != null)
      games.forEach((app) async {
        list.add(
          Card(
            elevation: 2,
            child: InkWell(
                onTap: () => {},
                child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Image.memory(app.icon),
                              width: 60,
                              padding: EdgeInsets.all(10.0),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.appName,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  app.versionName.replaceAll("_", "."),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic),
                                )
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        FlatButton(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.play_arrow,
                                  color: Colors.green[500],
                                ),
                                Text(
                                  'Open',
                                )
                              ],
                            ),
                            onPressed: () =>
                                DeviceApps.openApp(app.packageName))
                      ],
                    ))),
          ),
        );
      });

    if (list.isEmpty) {
      list.add(Card(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Text("NO GAMES INSTALLED"),
          ),
        ),
      ));
    }

    return list;
  }*/

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
