import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:sc_utility/utils/flutterextentions.dart';

class CustomWebViewPage extends StatefulWidget {
  final String url;
  final String name;

  CustomWebViewPage(this.url, this.name);

  @override
  CustomWebViewPageState createState() => CustomWebViewPageState(url, name);
}

class CustomWebViewPageState extends State<CustomWebViewPage> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  String url;
  String name;

  CustomWebViewPageState(this.url, this.name);

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
