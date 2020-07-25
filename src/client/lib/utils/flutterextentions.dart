import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:sc_utility/translationProvider.dart';
import '../resources.dart';

class FlutterExtensions {
  static void showPopupDialog(BuildContext ctx, String title, String text) {
    var resources = Resources.getInstance();
    if (resources.isPopupOpen) {
      Navigator.pop(ctx);
    }

    resources.isPopupOpen = true;
    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: AlertDialog(
              title: Text(
                title,
              ),
              content: Text(text),
              actions: <Widget>[
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                    resources.isPopupOpen = false;
                  },
                ),
              ],
            ));
      },
    );
  }

  static void showPopupDialogWithAction(BuildContext ctx, String title,
      String text, String buttonText, Function function) {
    var resources = Resources.getInstance();

    if (resources.isPopupOpen) {
      Navigator.pop(ctx);
    }

    resources.isPopupOpen = true;
    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: AlertDialog(
              title: Text(title),
              content: Text(text),
              actions: <Widget>[
                FlatButton(
                  child: Text(buttonText),
                  onPressed: () => {
                    Navigator.pop(context),
                    resources.isPopupOpen = false,
                    function(),
                  },
                ),
              ],
            ));
      },
    );
  }

  static void showPopupDialogWithActionAndCancel(BuildContext ctx, String title,
      String text, String buttonText, Function function, bool canDismiss) {
    var resources = Resources.getInstance();

    if (resources.isPopupOpen) {
      Navigator.pop(ctx);
    }

    resources.isPopupOpen = true;
    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () {
              if (canDismiss) resources.isPopupOpen = false;
              return Future.value(canDismiss);
            },
            child: AlertDialog(
              title: Text(title),
              content: Text(text),
              actions: <Widget>[
                FlatButton(
                  child: Text(TranslationProvider.get("TID_CANCEL")),
                  onPressed: () => {
                    Navigator.pop(context),
                    resources.isPopupOpen = false,
                  },
                ),
                FlatButton(
                  child: Text(buttonText),
                  onPressed: () => {
                    Navigator.pop(context),
                    resources.isPopupOpen = false,
                    function(),
                  },
                ),
              ],
            ));
      },
    );
  }
}
