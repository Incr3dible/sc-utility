import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../resources.dart';

class ChangelogPage extends StatefulWidget {
  @override
  ChangelogPageState createState() => ChangelogPageState();
}

class ChangelogPageState extends State<ChangelogPage> {
  Resources resources;

  @override
  void initState() {
    super.initState();
    resources = Resources.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          backgroundColor: Colors.blueGrey[900],
        ),
        body: Center());
  }
}
