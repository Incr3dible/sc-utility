import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sc_utility/api/ApiClient.dart';
import 'package:sc_utility/api/models/ApiConfig.dart';
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
  bool obscureToken = true;

  @override
  void initState() {
    resources = Resources.getInstance();

    tokenController.addListener(() {
      saveDevToken();

      setState(() {
        settingsEnabled = tokenController.text.length >= 64;
      });
    });

    tokenController.text = resources.devToken();

    onRefresh(null);
    super.initState();
  }

  String uptime = "0s";
  int totalRequests = 0;
  bool statusLoading = false;
  bool settingsLoading = false;
  bool settingsEnabled = false;

  Future<Null> onRefresh(BuildContext context) async {
    requestApiStatus();
    requestApiConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationProvider.get("TID_DEV_SETTINGS")),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return onRefresh(context);
        },
        child: ListView(
          padding:
              const EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 10),
          children: [
            ListTile(
              leading: Text("API Status"),
              trailing: statusLoading
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: requestApiStatus,
                    ),
            ),
            ListTile(
              leading: const Icon(Icons.dns),
              title: Text("Total Requests"),
              trailing: Text(totalRequests.toString()),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text("Uptime"),
              trailing: Text(uptime),
            ),
            Divider(),
            ListTile(
              leading: Text(
                TranslationProvider.get("TID_AUTHENTICATION"),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.remove_red_eye),
                onPressed: () {
                  setState(() {
                    obscureToken = !obscureToken;
                  });
                },
              ),
            ),
            ListTile(
              title: TextField(
                controller: tokenController,
                maxLength: 64,
                obscureText: obscureToken,
                decoration: InputDecoration(
                    labelText: TranslationProvider.get("TID_DEV_TOKEN"),
                    hintText: "Verify that you are the owner of this app",
                    border: const OutlineInputBorder()),
              ),
            ),
            Divider(),
            ListTile(
              leading: Text(TranslationProvider.get("TID_API_SETTINGS")),
              trailing: settingsLoading
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: settingsEnabled ? saveSettings : null,
                    ),
            ),
            ListTile(
              enabled: settingsEnabled,
              onTap: switchMaintenance,
              leading: const Icon(Icons.warning),
              title: Text(
                TranslationProvider.get("TID_MAINTENANCE"),
              ),
              subtitle: Text(
                TranslationProvider.get("TID_MAINTENANCE_DESC"),
              ),
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
      ),
    );
  }

  void saveSettings() async {
    setState(() {
      settingsLoading = true;
    });

    var config = new ApiConfig();
    config.maintenance = maintenance;

    var response = await ApiClient.saveApiConfig(tokenController.text, config);

    if (response != null) {
      if (response) {
        // SUCCESS
      } else {
        FlutterExtensions.showPopupDialog(context, "Invalid Token",
            "We couldn't verify that you are the owner or administrator of the API.");
      }
    } else {
      FlutterExtensions.showPopupDialog(
          context,
          TranslationProvider.get("TID_CONNECTION_ERROR"),
          TranslationProvider.get("TID_CONNECTION_ERROR_DESC"));
    }

    setState(() {
      settingsLoading = false;
    });
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

  void requestApiConfig() async {
    setState(() {
      settingsLoading = true;
    });

    var config = await ApiClient.getApiConfig();

    if (config != null) {
      setState(() {
        maintenance = config.maintenance;
      });
    } else {
      FlutterExtensions.showPopupDialog(
          context,
          TranslationProvider.get("TID_CONNECTION_ERROR"),
          TranslationProvider.get("TID_CONNECTION_ERROR_DESC"));
    }

    setState(() {
      settingsLoading = false;
    });
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
