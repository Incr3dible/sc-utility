import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(TranslationProvider.get("TID_DEV_SETTINGS")),
        ),
        body: ListView(
          padding: EdgeInsets.only(left: 10, right: 10),
          children: [
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
              leading: Text("API Status"),
              trailing: IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {},
              ),
            ),
            ListTile(
              leading: Icon(Icons.dns),
              title: Text("Total Requests"),
              trailing: Text("102"),
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text("Uptime"),
              trailing: Text("2d, 4h"),
            ),
            Divider(),
            ListTile(
              leading: Text("API Settings"),
              trailing: IconButton(
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
}
