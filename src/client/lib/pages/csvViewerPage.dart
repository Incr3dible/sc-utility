import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:sc_utility/compression/lzma/lzma.dart';
import 'package:sc_utility/helpers/reader.dart';
import 'package:http/http.dart' as http;
import 'package:sc_utility/utils/flutterextentions.dart';

import '../translationProvider.dart';

class CsvViewerPage extends StatefulWidget {
  final String csvUrl;
  final String fileName;

  CsvViewerPage(this.csvUrl, this.fileName);

  @override
  CsvViewerPageState createState() => CsvViewerPageState();
}

class CsvViewerPageState extends State<CsvViewerPage> {
  List<List<dynamic>> table;
  bool loading = true;
  List<DataRow> _rows;
  List<DataColumn> _columns;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : buildDataTable(),
    );
  }

  @override
  void initState() {
    super.initState();

    decompressCsv();
  }

  Future<void> decompressCsv() async {
    print("Loading file...");
    var compressed = await downloadCsv(widget.csvUrl);

    if (compressed == null) {
      FlutterExtensions.showPopupDialogWithAction(
          context,
          TranslationProvider.get("TID_CONNECTION_ERROR"),
          TranslationProvider.get("TID_CONNECTION_ERROR_DESC"),
          "OK", () {
        Navigator.pop(context);
      });

      print("NO CONNECTION");
      return;
    }

    var reader = new Reader(compressed.buffer.asUint8List());

    if (reader.readStringByLength(4) == "Sig:") {
      reader.skipBytes(64);

      print("Signature detected!");
    } else
      reader.offset = 0;

    var bytes = reader.readToEnd();

    const lzmaBytes = [93, 0, 0, 4];
    if (bytes.getRange(0, 4).toSet().intersection(lzmaBytes.toSet()).length >
        0) {
      print("LZMA detected!");

      print("Decompressing...");
      bytes = new Uint8List.fromList(lzma.decode(bytes));
      print("Decompressed!");
    }

    var converter = new CsvToListConverter();
    table = converter.convert(utf8.decode(bytes));

    _rows = buildRows();
    _columns = buildColumns();

    setState(() {
      loading = false;
    });

    print("Done!");
  }

  static Future<Uint8List> downloadCsv(String url) async {
    try {
      var request = await http.get(url);

      if (request.statusCode == 200)
        return request.bodyBytes;
      else
        return null;
    } catch (e) {
      return null;
    }
  }

  List<DataRow> buildRows() {
    return table
        .skip(1)
        .map(
          (e) => DataRow(
            cells: e
                .map(
                  (c) => DataCell(
                    Text(
                      c.toString(),
                    ),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  List<DataColumn> buildColumns() {
    return table.first
        .map(
          (e) => DataColumn(
            label: Text(
              e.toString(),
            ),
          ),
        )
        .toList();
  }

  Widget buildDataTable() {
    if (table == null)
      return Center(
        child: Text("No CSV loaded"),
      );

    return SafeArea(
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 0,
              horizontalMargin: 10,
              dataRowHeight: 30,
              rows: _rows,
              columns: _columns,
            ),
          ),
        ),
      ),
    );
  }
}
