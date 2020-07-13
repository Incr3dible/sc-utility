import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sc_utility/network/logic/fingerprintLog.dart';
import 'package:sc_utility/resources.dart';
import '../network/Client.dart';

class CrClientPage extends StatefulWidget {
  @override
  CrClientPageState createState() => CrClientPageState();
}

class CrClientPageState extends State<CrClientPage> {
  Client client;
  Resources resources;
  var isLoading = true;
  Color statusColor = Colors.green;
  String statusText = "Unknown";
  FingerprintLog fingerprintLog = new FingerprintLog();

  @override
  void initState() {
    client = new Client();
    resources = client.resources;
    resources.clientPageState = this;
    resources.currentContext = context;
    fingerprintLog.fromJson(resources.prefs.getString("fingerprintLog"));

    prepare();
    super.initState();
  }

  void prepare() async {
    await client.connectAsync();
  }

  int errorCode = -1;

  void setLoading(bool loading, int code) {
    setState(() {
      isLoading = loading;
      errorCode = code;

      if (code == 1) {
        //showSnackbar("Server is online", Icon(Icons.done));
        statusColor = Colors.green;
        statusText = "Online";
      } else if (code == 2) {
        showSnackbar("We received an unknown reason!", Icon(Icons.close));
        statusColor = Colors.red;
        statusText = "Unknown";
      } else if (code == 3) {
        showSnackbar("A new content update is available", Icon(Icons.update));
        statusColor = Colors.yellow;
        statusText = "Update";
      } else if (code == 4) {
        showSnackbar("The servers are currently under maintenance",
            Icon(Icons.info_outline));
        statusText = "Maintenance";
        statusColor = Colors.orange;
      }
    });
  }

  void reload() async {
    setLoading(true, -1);
    await client.connectAsync();
  }

  void showSnackbar(String text, Icon icon) {
    resources.mainPage.scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        children: [
          Container(
            child: icon,
            padding: EdgeInsets.all(5),
          ),
          Text(text)
        ],
      ),
      duration: Duration(milliseconds: 1500),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      String sha = resources.fingerprintSha();
      String version = resources.prefs.getString("version") ?? "unknown";

      return Center(
        child: ListView(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          children: [
            ListTile(
              leading: Icon(
                Icons.brightness_1,
                color: statusColor,
              ),
              title: Text("Status"),
              subtitle: Text(statusText),
            ),
            ListTile(
              trailing: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.content_copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: sha));

                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Row(
                        children: [
                          Container(
                            child: Icon(Icons.attach_file),
                            padding: EdgeInsets.all(5),
                          ),
                          Text('SHA copied to clipboard')
                        ],
                      ),
                      duration: Duration(seconds: 1),
                    ));
                  },
                ),
              ),
              leading: Icon(
                Icons.fingerprint,
              ),
              title: Text("Fingerprint SHA"),
              subtitle: Text(sha),
            ),
            ListTile(
              leading: Icon(
                Icons.info_outline,
              ),
              title: Text("Fingerprint Version"),
              subtitle: Text(version),
            )
          ],
        ),
      );
    }
  }
}
