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
          "receive a notification once a server is under maintenance"
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
      "eine Benachrichtigung erhalten, sobald ein Server in Wartung ist"
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
