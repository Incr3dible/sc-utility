import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sc_utility/pages/changelog.dart';
import 'package:sc_utility/pages/crclient.dart';
import 'package:sc_utility/pages/customWebview.dart';
import 'package:sc_utility/pages/eventImageFinder.dart';
import 'package:sc_utility/pages/eventpage.dart';
import 'package:sc_utility/pages/settings.dart';
import 'package:sc_utility/pages/statusPage.dart';
import 'package:sc_utility/resources.dart';
import 'package:sc_utility/translationProvider.dart';
import 'package:sc_utility/utils/flutterextentions.dart';
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
        '/event-finder': (context) => EventImageFinderPage()
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

  void setUpdate() {
    setState(() {
      print("UPDATE");
    });
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
              Colors.green[500]
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
                    /*otherAccountsPictures: <Widget>[
                      CircleAvatar(
                        backgroundImage: AssetImage("assets/inc.jpeg"),
                      ),
                      CircleAvatar(
                          backgroundImage: AssetImage("assets/kyle.jpeg"))
                    ],*/
                    currentAccountPicture: Image.asset("assets/icon.png"),
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
                    //enabled: _rootStatus,
                    title: Text(
                      'Event Image Finder (ROOT)',
                    ),
                    leading: Icon(
                      Icons.image,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/event-finder');
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
                'API Status',
              ),
              leading: Icon(
                Icons.announcement,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new CustomWebviewPage(
                                "https://status.incinc.xyz/", "API Status")));
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
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new CustomWebviewPage(
                                "https://github.com/Incr3dible/sc-utility",
                                "Github")));
              },
            )
          ],
        ),
      ),
    );
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
