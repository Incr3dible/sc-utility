import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:sc_utility/utils/flutterextentions.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomWebviewPage extends StatefulWidget {
  String url;
  String name;

  CustomWebviewPage(this.url, this.name);

  @override
  CustomWebviewPageState createState() => CustomWebviewPageState(url, name);
}

class CustomWebviewPageState extends State<CustomWebviewPage> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  String url;
  String name;

  CustomWebviewPageState(this.url, this.name);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: url,
      mediaPlaybackRequiresUserGesture: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () async {
            await flutterWebViewPlugin.close();
            Navigator.pop(context);
          },
        ),
        title: Text(name),
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: const Center(
        child: CircularProgressIndicator(),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                await flutterWebViewPlugin.goBack();
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () async {
                await flutterWebViewPlugin.goForward();
              },
            ),
            IconButton(
              icon: const Icon(Icons.autorenew),
              onPressed: () async {
                await flutterWebViewPlugin.reloadUrl(url);
              },
            ),
            Spacer(),
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () {
                FlutterExtensions.launchUrl(url);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
