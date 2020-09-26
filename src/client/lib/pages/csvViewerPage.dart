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
  bool loading = true;
  CsvTable table;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: loading
          ? const Center(
              child: const CircularProgressIndicator(),
            )
          : buildDataTable(),
    );
  }

  @override
  void initState() {
    super.initState();

    prepare();
  }

  void prepare() async {
    await decompressCsv();
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

    var reader = new Reader(compressed);

    if (reader.readStringByLength(4) == "Sig:") {
      reader.skipBytes(64);

      print("Signature detected!");
    } else
      reader.offset = 0;

    var bytes = reader.readToEnd();
    reader.buffer = null;

    var decompressedString = await decompressString(bytes);
    var csvTable = await decodeCsvTable(decompressedString);

    var rows = buildRows(csvTable);
    var columns = buildColumns(csvTable);

    table = CsvTable(columns, rows);

    setState(() {
      loading = false;
    });

    print("Done!");
  }

  Future<List<List<dynamic>>> decodeCsvTable(String csv) async {
    return const CsvToListConverter().convert(csv);
  }

  Future<String> decompressString(Uint8List buffer) async {
    const lzmaBytes = [93, 0, 0, 4];
    if (buffer.getRange(0, 4).toSet().intersection(lzmaBytes.toSet()).length >
        0) {
      var decoded = lzma.decode(buffer);
      return utf8.decode(decoded);
    }

    return utf8.decode(buffer);
  }

  Future<Uint8List> downloadCsv(String url) async {
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

  List<DataRow> buildRows(List<List<dynamic>> table) {
    return table
        .skip(1)
        .map(
          (e) => DataRow(
            cells: e
                .map(
                  (c) => DataCell(
                    Text(
                      c.toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  List<DataColumn> buildColumns(List<List<dynamic>> table) {
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

    return table;
  }
}

class CsvTable extends StatelessWidget {
  final List<DataRow> rows;
  final List<DataColumn> columns;

  CsvTable(this.columns, this.rows);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 5,
            horizontalMargin: 10,
            dataRowHeight: 30,
            rows: rows,
            columns: columns,
          ),
        ),
      ),
    );
  }
}
