import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:sc_utility/pages/statusPage.dart';
import 'package:sc_utility/translationProvider.dart';
import 'package:sc_utility/utils/flutterextentions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/GithubApiClient.dart';
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
  PackageInfo packageInfo;

  bool isPopupOpen = false;
  FirebaseMessaging firebaseMessaging;
  SharedPreferences prefs;

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

  void onResourcesLoaded() async {
    statusPage.requestStatusList();
    await checkForUpdate(currentContext, true);
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

  int language() {
    return prefs?.getInt("language") ?? 0;
  }

  String fingerprintSha() {
    return prefs.getString("sha") ?? "unknown";
  }

  String devToken(){
    return prefs.getString("devToken") ?? "";
  }

  Future checkForUpdate(
      BuildContext context, bool onlyShowWhenUpdateAvailable) async {
    var appUpdate = await GithubApiClient.isNewTagAvailable(
        packageInfo.version.replaceAll(".debug", ""));

    if (appUpdate == null) {
      if (!onlyShowWhenUpdateAvailable)
        FlutterExtensions.showPopupDialog(
            context,
            TranslationProvider.get("TID_CONNECTION_ERROR"),
            TranslationProvider.get("TID_CONNECTION_ERROR_DESC"));
    } else if (appUpdate.isUpdateAvailable) {
      FlutterExtensions.showPopupDialogWithActionAndCancel(
          context,
          TranslationProvider.get("TID_UPDATE_AVAILABLE"),
          TranslationProvider.get("TID_UPDATE_AVAILABLE_DESC") +
              " (v" +
              appUpdate.latestVersion +
              ")",
          TranslationProvider.get("TID_DOWNLOAD"),
          () => {
                FlutterExtensions.launchUrl(
                    "https://github.com/Incr3dible/sc-utility/releases/tag/" +
                        appUpdate.latestVersion)
              },
          false);
    } else {
      if (!onlyShowWhenUpdateAvailable)
        FlutterExtensions.showPopupDialog(
            context,
            TranslationProvider.get("TID_UP_TO_DATE"),
            TranslationProvider.get("TID_LATEST_VERSION"));
    }
  }
}
