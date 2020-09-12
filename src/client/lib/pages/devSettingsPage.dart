import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sc_utility/api/ApiClient.dart';
import 'package:sc_utility/utils/flutterextentions.dart';
import 'package:sc_utility/utils/timeUtils.dart';
import '../resources.dart';
import '../translationProvider.dart';

class DevSettingsPage extends StatefulWidget {
  @override
  DevSettingsPageState createState() => DevSettingsPageState();
}

class DevSettingsPageState extends State<DevSettingsPage> {
  Resources resources;
  TextEditingController tokenController = new TextEditingController();

  bool maintenance = false;

  @override
  void initState() {
    resources = Resources.getInstance();

    tokenController.addListener(() {
      print(tokenController.text);
      saveDevToken();

      setState(() {
        settingsEnabled = tokenController.text.length >= 64;
      });
    });

    tokenController.text = resources.devToken();

    requestApiStatus();
    super.initState();
  }

  String uptime = "0s";
  int totalRequests = 0;
  bool statusLoading = false;
  bool settingsLoading = false;
  bool settingsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationProvider.get("TID_DEV_SETTINGS")),
      ),
      body: ListView(
        padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 10),
        children: [
          ListTile(
            leading: Text("API Status"),
            trailing: statusLoading
                ? const CircularProgressIndicator()
                : IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: requestApiStatus,
                  ),
          ),
          ListTile(
            leading: Icon(Icons.dns),
            title: Text("Total Requests"),
            trailing: Text(totalRequests.toString()),
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text("Uptime"),
            trailing: Text(uptime),
          ),
          Divider(),
          ListTile(
            leading: Text("Authentication"),
          ),
          ListTile(
            title: TextField(
              controller: tokenController,
              maxLength: 64,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: "Developer Token",
                  hintText: "Verify that you are the owner of this app",
                  border: const OutlineInputBorder()),
            ),
          ),
          Divider(),
          ListTile(
            leading: Text("API Settings"),
            trailing: settingsLoading
                ? const CircularProgressIndicator()
                : IconButton(
                    icon: Icon(Icons.save),
                    onPressed: settingsEnabled ? saveSettings : null,
                  ),
          ),
          ListTile(
            enabled: settingsEnabled,
            onTap: switchMaintenance,
            leading: const Icon(Icons.warning),
            title: Text(
              "Maintenance",
            ),
            subtitle: Text("enable or disable the maintenance mode of the API"),
            trailing: Switch(
              value: maintenance,
              onChanged: settingsEnabled
                  ? (value) {
                      switchMaintenance();
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void saveSettings() {
    print("SAVE");
  }

  void switchMaintenance() {
    setState(() {
      maintenance = !maintenance;
    });
  }

  void saveDevToken() {
    var token = tokenController.text;
    resources.prefs.setString("devToken", token);
  }

  void requestApiStatus() async {
    setState(() {
      statusLoading = true;
    });

    var status = await ApiClient.getApiStatus();

    if (status != null) {
      setState(() {
        totalRequests = status.totalApiRequests;
        uptime = TimeUtils.secondsToTime(status.uptimeSeconds);
        maintenance = status.maintenance;
      });
    } else {
      FlutterExtensions.showPopupDialogWithAction(
          context,
          TranslationProvider.get("TID_CONNECTION_ERROR"),
          TranslationProvider.get("TID_CONNECTION_ERROR_DESC"),
          "OK", () {
        Navigator.pop(context);
      });
    }

    setState(() {
      statusLoading = false;
    });
  }
}
