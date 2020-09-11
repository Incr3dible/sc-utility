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
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {},
            )
          ],
        ),
        body: ListView(
          padding: EdgeInsets.only(left: 10, right: 10),
          children: [
            ListTile(
              title: Text("Authentication"),
            ),
            ListTile(
              //padding: EdgeInsets.only(bottom: 20),
              title: TextField(
                maxLength: 64,
                decoration: InputDecoration(
                    labelText: "Developer Token",
                    hintText: "Verify that you are the owner of this app",
                    border: const OutlineInputBorder()),
              ),
            ),
            Divider(),
            ListTile(
              title: Text("API Settings"),
            ),
            Container(
              child: ListTile(
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
            ),
          ],
        ));
  }
}
