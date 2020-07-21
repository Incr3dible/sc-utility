import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:sc_utility/pages/statusPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sc_utility/network/Client.dart';

import 'pages/crclient.dart';
import 'main.dart';

class Resources {
  static Resources instance;
  static bool initialized = false;

  static Resources getInstance() {
    if (instance != null) return instance;
    print("Resources are null!");
    return null;
  }

  Resources() {
    instance = this;
  }

  BuildContext currentContext;
  MainPageState mainPage;
  StatusPageState statusPage;
  MyAppState myApp;
  CrClientPageState clientPageState;
  PackageInfo packageInfo;

  bool isPopupOpen = false;
  FirebaseMessaging firebaseMessaging;
  SharedPreferences prefs;
  Client client;

  Future<void> init() async {
    if (initialized) return;
    print("Initializing resources...");

    prefs = await SharedPreferences.getInstance();

    firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.configure();

    if (prefs.getBool("notifications") ?? true) {
      firebaseMessaging.subscribeToTopic("everyone");
    }

    packageInfo = await PackageInfo.fromPlatform();

    print("Initialized resources.");
    initialized = true;

    onResourcesLoaded();
  }

  void onResourcesLoaded(){
    statusPage.requestStatusList();
  }

  void clearPages() {
    Navigator.popUntil(currentContext, ModalRoute.withName("/"));
  }

  ThemeMode themeMode() {
    var mode = prefs.getInt("themeMode") ?? 2;

    switch (mode) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.system;
    }

    return ThemeMode.system;
  }

  int language(){
    return prefs?.getInt("language") ?? 0;
  }

  String fingerprintSha() {
    return prefs.getString("sha") ?? "unknown";
  }
}
