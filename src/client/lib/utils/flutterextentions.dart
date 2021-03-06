import 'package:flutter/material.dart';
import 'package:sc_utility/translationProvider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  static void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

extension ListUpdate<T> on List {
  void update(int pos, T t) {
    removeAt(pos);
    insert(pos, t);
  }
}
