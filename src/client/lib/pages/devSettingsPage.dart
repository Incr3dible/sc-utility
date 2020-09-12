import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sc_utility/api/ApiClient.dart';
import 'package:sc_utility/utils/timeUtils.dart';
import '../resources.dart';
import '../translationProvider.dart';

class DevSettingsPage extends StatefulWidget {
  @override
  DevSettingsPageState createState() => DevSettingsPageState();
}

class DevSettingsPageState extends State<DevSettingsPage> {
  Resources resources;

  @override
  void initState() {
    resources = Resources.getInstance();

    requestApiStatus();

    super.initState();
  }

  String uptime = "0s";
  int totalRequests = 0;
  bool statusLoading = false;
  bool settingsLoading = false;

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
                      onPressed: () {},
                    ),
            ),
            ListTile(
              onTap: () => {},
              leading: const Icon(Icons.warning),
              title: Text(
                "Maintenance",
              ),
              subtitle:
                  Text("enable or disable the maintenance mode of the API"),
              trailing: Switch(
                value: false,
                onChanged: (value) {},
              ),
            ),
          ],
        ));
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
      print("ERROR");
    }

    setState(() {
      statusLoading = false;
    });
  }
}
