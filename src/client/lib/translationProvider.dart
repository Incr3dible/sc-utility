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
      "TID_MORE": "More",
      "TID_MORE_DESC": "here you can find out more about this project",
      "TID_OPEN_SOURCE_DESC": "an open source project",
      "TID_DISCLAIMER": "Disclaimer",
      "TID_DISCLAIMER_DESC":
          "This content is not affiliated with, endorsed, sponsored, or specifically approved by Supercell and Supercell is not responsible for it.",
      "TID_MAINTENANCE": "Maintenance",
      "TID_CONTENT_UPDATE": "Content Update",
      "TID_CANCEL": "Cancel",
      "TID_CONNECTION_ERROR": "Connection error",
      "TID_TRY_AGAIN": "Try again",
      "TID_CONNECTION_ERROR_DESC":
          "Couldn't connect to the server. Please try again.",
      "TID_SWIPE_RETRY":
          "Swipe down to try again and check your internet connection",
      "TID_FINGERPRINT_HISTORY": "Fingerprint History",
      "TID_LIVE_DESC": "refreshes every 10 seconds",
      "TID_EVENT_DESC":
          "Thank you for contributing to this project as root user. Users without root can also see this images now through the event gallery in this app.",
      "TID_UPLOAD": "Uploading...",
      "TID_UNKNOWN_ERROR": "An unknown error occurred",
      "TID_EVENT_GALLERY": "Event Gallery",
      "TID_FINGERPRINT_COMPARISON": "Fingerprint Comparison",
      "TID_ADDED": "Added",
      "TID_CHANGED": "Changed",
      "TID_REMOVED": "Removed",
      "TID_NO_CHANGES": "No changes",
      "TID_COPIED": "Copied to clipboard"
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
      "TID_MORE": "Mehr",
      "TID_MORE_DESC": "hier findest du mehr zu diesem Projekt",
      "TID_OPEN_SOURCE_DESC": "ein Open-Source-Projekt",
      "TID_DISCLAIMER": "Ausschlussklausel",
      "TID_DISCLAIMER_DESC":
          "Dieser Inhalt ist nicht mit Supercell verbunden, unterstützt, gesponsert oder speziell von Supercell genehmigt und Supercell ist nicht dafür verantwortlich.",
      "TID_MAINTENANCE": "Wartungspause",
      "TID_CONTENT_UPDATE": "Inhalts-Update",
      "TID_CANCEL": "Abbrechen",
      "TID_CONNECTION_ERROR": "Verbindungsfehler",
      "TID_TRY_AGAIN": "Erneut versuchen",
      "TID_CONNECTION_ERROR_DESC":
          "Es konnte keine Verbindung zum Server hergestellt werden. Bitte versuche es noch einmal.",
      "TID_SWIPE_RETRY":
          "Um es erneut zu versuchen wische nach unten und überprüfe deine Internetverbindung",
      "TID_FINGERPRINT_HISTORY": "Fingerabdruckverlauf",
      "TID_LIVE_DESC": "aktualisierung alle 10 Sekunden",
      "TID_EVENT_DESC":
          "Danke, dass du als Root-User zu diesem Projekt beigetragen hast. Benutzer ohne root können diese Bilder jetzt auch über die Eventgalerie in dieser App sehen.",
      "TID_UPLOAD": "Hochladen...",
      "TID_UNKNOWN_ERROR": "Ein unbekannter Fehler ist aufgetreten",
      "TID_EVENT_GALLERY": "Eventgalerie",
      "TID_FINGERPRINT_COMPARISON": "Fingerabdruckvergleich",
      "TID_ADDED": "Hinzugefügt",
      "TID_CHANGED": "Geändert",
      "TID_REMOVED": "Entfernt",
      "TID_NO_CHANGES": "Keine Änderungen",
      "TID_COPIED": "In die Zwischenablage kopiert"
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
