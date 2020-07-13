import 'package:sc_utility/resources.dart';

class TranslationProvider {
  static var texts = {
    {
      "TID_SETTINGS": "Settings",
      "TID_THEME": "Theme",
      "TID_LIGHT": "Light",
      "TID_DARK": "Dark",
      "TID_LANGUAGE": "Language",
      "TID_NOTIFICATIONS": "Notifications",
      "TID_MAINTENANCE_NOTIFICATIONS": "Maintenance Notifications",
      "TID_MAINTENANCE_NOTIFICATION_DESC":
          "receive a notification once a server is under maintenance",
      "TID_LATEST_VERSION": "You are on the latest version",
      "TID_UP_TO_DATE": "Up-to-date",
      "TID_DOWNLOAD": "Download",
      "TID_UPDATE_AVAILABLE": "Update available",
      "TID_UPDATE_AVAILABLE_DESC": "A new update for this app is available!",
      "TID_WELCOME_MESSAGE":
          "Welcome to the Supercell Utility!\nThis app requires root for some features so make sure you have given root access to this app.",
      "TID_MORE": "More",
      "TID_MORE_DESC":
          "do you need help or want to look at the code on Github?",
      "TID_OPEN_SOURCE_DESC": "an open source project"
    },
    {
      "TID_SETTINGS": "Einstellungen",
      "TID_THEME": "Thema",
      "TID_LIGHT": "Hell",
      "TID_DARK": "Dunkel",
      "TID_LANGUAGE": "Sprache",
      "TID_NOTIFICATIONS": "Benachrichtigungen",
      "TID_MAINTENANCE_NOTIFICATIONS": "Wartungsbenachrichtigungen",
      "TID_MAINTENANCE_NOTIFICATION_DESC":
          "eine Benachrichtigung erhalten, sobald ein Server in Wartung ist",
      "TID_LATEST_VERSION": "Die App befindet sich auf der neuesten Version",
      "TID_UP_TO_DATE": "Auf dem neuesten Stand",
      "TID_DOWNLOAD": "Herunterladen",
      "TID_UPDATE_AVAILABLE": "Update verfügbar",
      "TID_UPDATE_AVAILABLE_DESC":
          "Ein neues Update für diese App ist verfügbar!",
      "TID_WELCOME_MESSAGE":
          "Willkommen beim Supercell Utility!\nDiese Anwendung benötigt für einige Funktionen root, stelle also sicher, dass du dieser Anwendung root-Zugriff gewährt hast.",
      "TID_MORE": "Mehr",
      "TID_MORE_DESC":
          "brauchst du Hilfe oder möchtest den Code auf Github ansehen?",
      "TID_OPEN_SOURCE_DESC": "ein Open-Source-Projekt"
    },
  };

  static String get(String tid) {
    var language = Resources.getInstance().language();

    if (texts.length > language) {
      var languageTexts = texts.elementAt(language);

      if (languageTexts.containsKey(tid)) {
        return languageTexts[tid];
      }
    }

    return tid;
  }
}
