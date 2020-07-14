import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../resources.dart';

class ChangelogPage extends StatefulWidget {
  @override
  ChangelogPageState createState() => ChangelogPageState();
}

class ChangelogPageState extends State<ChangelogPage>
    with SingleTickerProviderStateMixin {
  Resources resources;
  TabController controller;

  @override
  void initState() {
    controller = new TabController(length: tabs.length, vsync: this);

    super.initState();
    resources = Resources.getInstance();
  }

  var tabs = [
    const Tab(text: "Clash Royale"),
    const Tab(text: "Clash of Clans"),
    const Tab(text: "Brawl Stars")
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text("Fingerprint Changelog"),
              bottom: TabBar(
                controller: controller,
                isScrollable: false,
                tabs: tabs,
              ),
            ),
            body: TabBarView(controller: controller, children: <Widget>[
              buildChangelog(),
              buildChangelog(),
              buildChangelog()
            ])));
  }

  Widget buildChangelog() {
    var test = {
      new FingerprintTest(
          "04044a73124aa57114be9a20a8c4c6dfec9ebefa", "14.07.20"),
      new FingerprintTest(
          "tr87etg2347986t34b796ton34qo938n6f539478", "13.07.20"),
      new FingerprintTest(
          "eriutz348t79o24659o34786496g754397623469", "10.07.20"),
      new FingerprintTest(
          "8743ctb78341t6h349tn1634t9v134t89134bt49", "09.07.20"),
      new FingerprintTest(
          "34t90v6814t6h934vtb6349765v349bn6934t984", "04.07.20")
    };

    return ListView.builder(
      padding: EdgeInsets.only(top: 8, left: 5, right: 5),
      itemCount: test.length,
      itemBuilder: (BuildContext context, int index) {
        var item = test.elementAt(index);

        return ListTile(
          title: Text(item.sha),
          subtitle: Text(item.date),
          trailing: IconButton(
            icon: Icon(Icons.content_copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: item.sha));

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
        );
      },
    );
  }
}

class FingerprintTest {
  String sha;
  String date;

  FingerprintTest(this.sha, this.date);
}
