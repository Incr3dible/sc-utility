import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sc_utility/api/models/AssetFile.dart';
import 'package:sc_utility/api/models/Fingerprint.dart';
import 'package:sc_utility/api/models/FingerprintLog.dart';
import 'package:sc_utility/translationProvider.dart';
import 'package:sc_utility/utils/fingerprintUtils.dart';

class FingerprintComparePage extends StatefulWidget {
  final List<FingerprintLog> logs;
  final String gameName;

  FingerprintComparePage(this.logs, this.gameName);

  @override
  FingerprintComparePageState createState() =>
      FingerprintComparePageState(logs, gameName);
}

class FingerprintComparePageState extends State<FingerprintComparePage>
    with SingleTickerProviderStateMixin {
  List<FingerprintLog> logs;
  String gameName;
  TabController controller;

  bool isLoading = true;

  List<AssetFile> addedFiles;
  List<AssetFile> changedFiles;
  List<AssetFile> removedFiles;

  FingerprintComparePageState(this.logs, this.gameName);

  var tabs = {
    Tab(
      text: TranslationProvider.get("TID_ADDED"),
    ),
    Tab(
      text: TranslationProvider.get("TID_CHANGED"),
    ),
    Tab(
      text: TranslationProvider.get("TID_REMOVED"),
    ),
  }.toList();

  @override
  void initState() {
    super.initState();
    controller =
        new TabController(length: tabs.length, vsync: this, initialIndex: 1);

    downloadFingerprints();
  }

  void downloadFingerprints() async {
    setState(() {
      isLoading = true;
    });

    var fingerprints = new List<Fingerprint>();
    logs.sort((a, b) => a.isNewer(b.version));

    await Future.forEach(logs, (log) async {
      var fingerprint =
          await FingerprintUtils.downloadFingerprint(log, gameName);

      if (fingerprint != null) {
        fingerprints.add(fingerprint);
      }
    });

    if (fingerprints.length == 2) {
      compareFingerprints(fingerprints.elementAt(0), fingerprints.elementAt(1));
    }

    setState(() {
      isLoading = false;
    });
  }

  void compareFingerprints(
      Fingerprint oldFingerprint, Fingerprint newFingerprint) {
    addedFiles = FingerprintUtils.getAddedFiles(oldFingerprint, newFingerprint);
    removedFiles =
        FingerprintUtils.getRemovedFiles(oldFingerprint, newFingerprint);
    changedFiles =
        FingerprintUtils.getChangedFiles(oldFingerprint, newFingerprint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationProvider.get("TID_FINGERPRINT_COMPARISON")),
        bottom: TabBar(
          controller: controller,
          isScrollable: false,
          tabs: tabs,
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              controller: controller,
              children: <Widget>[
                buildList(addedFiles, Colors.green[400]),
                buildList(changedFiles, Colors.orange),
                buildList(removedFiles, Colors.red[400])
              ],
            ),
    );
  }

  Future<Null> onRefresh(BuildContext context) async {
    downloadFingerprints();
  }

  Widget buildList(List<AssetFile> files, Color color) {
    if (files == null) {
      return RefreshIndicator(
          onRefresh: () {
            return onRefresh(context);
          },
          child: ListView(
            padding: EdgeInsets.all(20),
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Icon(Icons.cloud_off),
                  ),
                  Text(
                    TranslationProvider.get("TID_SWIPE_RETRY"),
                    textAlign: TextAlign.center,
                  )
                ],
              )
            ],
          ));
    }

    if (files?.length == 0) {
      return Center(
        child: Text(TranslationProvider.get("TID_NO_CHANGES")),
      );
    }

    return ListView.builder(
        padding: EdgeInsets.only(top: 8, left: 5, right: 5),
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index) {
          var file = files.elementAt(index);
          return ListTile(
            leading: Icon(
              Icons.insert_drive_file,
              color: color,
            ),
            title: Text(file.file),
            subtitle: Text(file.sha),
            trailing: IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: file.file));

                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Row(
                    children: [
                      Container(
                        child: Icon(Icons.attach_file),
                        padding: EdgeInsets.all(5),
                      ),
                      Text('Filename copied to clipboard')
                    ],
                  ),
                  duration: Duration(seconds: 1),
                ));
              },
            ),
          );
        });
  }
}
