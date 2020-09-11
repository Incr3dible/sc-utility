import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sc_utility/pages/csvViewerPage.dart';
import 'package:sc_utility/pages/customWebviewPage.dart';
import 'package:sc_utility/pages/devSettingsPage.dart';
import 'package:sc_utility/pages/eventGalleryPage.dart';
import 'package:sc_utility/pages/eventImageFinderPage.dart';
import 'package:sc_utility/pages/settingsPage.dart';
import 'package:sc_utility/pages/statusPage.dart';
import 'package:sc_utility/resources.dart';
import 'package:sc_utility/translationProvider.dart';
import 'dart:async';
import 'package:root_access/root_access.dart';
import 'package:sc_utility/utils/customWidgets.dart';
import 'package:sc_utility/utils/flutterextentions.dart';
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
        '/settings': (context) => SettingsPage(),
        '/event-finder': (context) => EventImageFinderPage(),
        '/event-gallery': (context) => EventGalleryPage(),
        '/csv-test': (context) => CsvViewerPage(),
        '/dev-settings': (context) => DevSettingsPage()
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
    //await RootUtils.grantStoragePermissions();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
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
                  CustomWidgets.roundedListTile(
                    ListTile(
                      leading: const Icon(Icons.collections),
                      title: Text(TranslationProvider.get("TID_EVENT_GALLERY")),
                      onTap: () {
                        Navigator.pushNamed(context, '/event-gallery');
                      },
                    ),
                  ),
                  /*CustomWidgets.roundedListTile(
                    ListTile(
                      leading: const Icon(Icons.table_chart),
                      title: Text(TranslationProvider.get("TID_CSV")),
                      onTap: () {
                        Navigator.pushNamed(context, '/csv-test');
                      },
                    ),
                  ),*/
                  /*CustomWidgets.roundedListTile(
                    ListTile(
                      leading: const Icon(Icons.web),
                      title: Text("News"),
                      onTap: () {

                      },
                    ),
                  ),*/
                  CustomWidgets.roundedListTile(
                    ListTile(
                      enabled: _rootStatus,
                      title: Text(
                        'Event Compass (ROOT)',
                      ),
                      leading: const Icon(
                        Icons.cloud_upload,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/event-finder');
                      },
                    ),
                  ),
                  CustomWidgets.roundedListTile(
                    ListTile(
                      title: Text(
                        TranslationProvider.get("TID_SETTINGS"),
                      ),
                      leading: const Icon(
                        Icons.settings,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                      enabled: true,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: Text(TranslationProvider.get("TID_MORE")),
              subtitle: Text(TranslationProvider.get("TID_MORE_DESC")),
            ),
            Divider(),
            ListTile(
              title: const Text(
                'Discord',
              ),
              leading: const Icon(
                Icons.chat,
              ),
              onTap: () {
                FlutterExtensions.launchUrl('https://discord.gg/XdTw2PZ');
              },
            ),
            ListTile(
              title: const Text(
                'API Status',
              ),
              leading: const Icon(
                Icons.announcement,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) => new CustomWebViewPage(
                        "https://status.incinc.xyz/", "API Status"),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Github',
              ),
              leading: const Icon(
                Icons.code,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) => new CustomWebViewPage(
                        "https://github.com/Incr3dible/sc-utility", "Github"),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
