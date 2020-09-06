import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sc_utility/compression/lzma/lzma.dart';
import 'package:sc_utility/helpers/reader.dart';

class CsvViewerPage extends StatefulWidget {
  @override
  CsvViewerPageState createState() => CsvViewerPageState();
}

class CsvViewerPageState extends State<CsvViewerPage> {
  String decompressedCsv = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CSV Viewer"),
        actions: [
          IconButton(
            onPressed: decompressCsv,
            icon: Icon(Icons.play_arrow),
          )
        ],
      ),
      body: buildDataTable(decompressedCsv),
    );
  }

  void decompressCsv() async {
    print("Loading file...");
    var compressed = await rootBundle.load("assets/csv/wo-sign.csv");
    var reader = new Reader(compressed.buffer.asUint8List());

    if (reader.readStringByLength(4) == "Sig:") {
      reader.skipBytes(64);

      print("Signature detected!");
    } else
      reader.offset = 0;

    var bytes = reader.readToEnd();

    var lzmaBytes = [93, 0, 0, 4];
    if (bytes.getRange(0, 4).toSet().intersection(lzmaBytes.toSet()).length >
        0) {
      print("LZMA detected!");

      print("Decompressing...");
      bytes = new Uint8List.fromList(lzma.decode(bytes));
      print("Decompressed!");
    }

    setState(() {
      decompressedCsv = utf8.decode(bytes);
    });

    print("Done!");
  }

  Widget buildDataTable(String csv) {
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csv);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          rows: rowsAsListOfValues
              .skip(1)
              .map((e) =>
                  DataRow(cells: e.map((c) => DataCell(Text(c.toString()))).toList()))
              .toList(),
          columns: rowsAsListOfValues.first
              .map((e) => DataColumn(label: Text(e)))
              .toList(),
        ),
      ),
    );
  }
}
