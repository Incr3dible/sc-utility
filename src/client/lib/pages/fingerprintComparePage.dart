import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sc_utility/api/models/AssetFile.dart';
import 'package:sc_utility/api/models/Fingerprint.dart';
import 'package:sc_utility/api/models/FingerprintLog.dart';
import 'package:http/http.dart' as http;

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
      text: "Added",
    ),
    Tab(
      text: "Changed",
    ),
    Tab(
      text: "Removed",
    ),
  }.toList();

  @override
  void initState() {
    super.initState();
    controller = new TabController(length: tabs.length, vsync: this);

    downloadFingerprints();
  }

  void downloadFingerprints() async {
    var fingerprints = new List<Fingerprint>();
    logs.sort((a, b) => a.isNewer(b.version));

    await Future.forEach(logs, (log) async {
      var fingerprint = await downloadFingerprint(log);

      if (fingerprint != null) {
        fingerprints.add(fingerprint);
      }
    });

    if (fingerprints.length == 2) {
      compareFingerprints(fingerprints.elementAt(0), fingerprints.elementAt(1));
    } else
      print("ERROR");
  }

  void compareFingerprints(
      Fingerprint oldFingerprint, Fingerprint newFingerprint) {
    print(oldFingerprint.version);
    print(newFingerprint.version);

    addedFiles = getAddedFiles(oldFingerprint, newFingerprint);
    removedFiles = getRemovedFiles(oldFingerprint, newFingerprint);
    changedFiles = getChangedFiles(oldFingerprint, newFingerprint);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fingerprint Comparison"),
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
                buildList(addedFiles, Colors.green),
                buildList(changedFiles, Colors.orange),
                buildList(removedFiles, Colors.red)
              ],
            ),
    );
  }

  Widget buildList(List<AssetFile> files, Color color) {
    if (files == null || files?.length == 0) {
      return Center(
        child: Text("Empty here..."),
      );
    }

    return ListView.builder(
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
          );
        });
  }

  List<AssetFile> getChangedFiles(
      Fingerprint oldFingerprint, Fingerprint newFingerprint) {
    var changedFiles = new List<AssetFile>();

    oldFingerprint.files.forEach((file) {
      if (newFingerprint.files.indexWhere((element) =>
              element.file == file.file && element.sha != file.sha) >
          -1) {
        changedFiles.add(file);
      }
    });

    return changedFiles;
  }

  List<AssetFile> getAddedFiles(
      Fingerprint oldFingerprint, Fingerprint newFingerprint) {
    var addedFiles = new List<AssetFile>();

    newFingerprint.files.forEach((file) {
      if (oldFingerprint.files
              .indexWhere((element) => element.file == file.file) ==
          -1) {
        addedFiles.add(file);
      }
    });

    return addedFiles;
  }

  List<AssetFile> getRemovedFiles(
      Fingerprint oldFingerprint, Fingerprint newFingerprint) {
    var removedFiles = new List<AssetFile>();

    oldFingerprint.files.forEach((file) {
      if (newFingerprint.files
              .indexWhere((element) => element.file == file.file) ==
          -1) {
        removedFiles.add(file);
      }
    });

    return removedFiles;
  }

  Future<Fingerprint> downloadFingerprint(FingerprintLog log) async {
    var fingerprintJson = await http
        .get(getAssetHostByName(gameName) + log.sha + "/fingerprint.json");

    if (fingerprintJson.statusCode == 200)
      return Fingerprint.fromJson(json.decode(fingerprintJson.body));
    else
      return null;
  }

  String getAssetHostByName(String gameName) {
    switch (gameName) {
      case "Clash Royale":
        return "http://7166046b142482e67b30-2a63f4436c967aa7d355061bd0d924a1.r65.cf1.rackcdn.com/";
      case "Clash of Clans":
        return "http://b46f744d64acd2191eda-3720c0374d47e9a0dd52be4d281c260f.r11.cf2.rackcdn.com/";
      case "Boom Beach":
        return "http://df70a89d32075567ba62-1e50fe9ed7ef652688e6e5fff773074c.r40.cf1.rackcdn.com/";
      case "Brawl Stars":
        return "http://a678dbc1c015a893c9fd-4e8cc3b1ad3a3c940c504815caefa967.r87.cf2.rackcdn.com/";
      default:
        return null;
    }
  }
}
