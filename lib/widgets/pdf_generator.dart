import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PdfGenerator {
  static List<List<dynamic>> transformData(List<Map<String, dynamic>> rawData) {
    List<List<dynamic>> data = [];
    int totalCost = 0, serial = 1;
    data.add(['SL No.', 'Teacher ID', 'Name', 'Cost(tk)']);
    for (var entry in rawData) {
      if (entry['name'] != null) {
        List list = [];
        list.add(serial);
        serial++;
        for (var field in entry.values) {
          list.add(field);
        }
        totalCost += entry['cost'];
        data.add(list);
      }
    }
    List totalEntry = [];
    totalEntry.add(" ");
    totalEntry.add(" ");
    totalEntry.add("Total");
    totalEntry.add("$totalCost");
    data.add(totalEntry);
    return data;
  }

  static Future<Uint8List> generate(List<Map<String, dynamic>> rawData,
      List<Map<String, String>> managers) async {
    var myTheme = pw.ThemeData.withFont(
      base: pw.Font.ttf(await rootBundle.load("assets/OpenSans-Regular.ttf")),
      bold: pw.Font.ttf(await rootBundle.load("assets/OpenSans-Bold.ttf")),
      italic: pw.Font.ttf(await rootBundle.load("assets/OpenSans-Italic.ttf")),
      boldItalic:
          pw.Font.ttf(await rootBundle.load("assets/OpenSans-BoldItalic.ttf")),
    );

    final pw.Document doc = pw.Document(theme: myTheme);

    List<pw.Widget> textWidgets = [];
    for (var entry in managers) {
      textWidgets.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                pw.Text("Manager\t",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(entry['manager']),
              ],
            ),
            pw.Row(
              children: [
                pw.Text("Duration\t",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(entry['duration']),
              ],
            ),
          ],
        ),
      );
      textWidgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(bottom: 20.0),
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat:
            PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        build: (pw.Context context) => <pw.Widget>[
          pw.Center(
            child: pw.Text(
              "Shahid Smrity Hall Teachers' Block",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          pw.Center(
            child: pw.Text(
              "Mess Charge",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 20.0),
          ),
          ...textWidgets,
          pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 20.0),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: transformData(rawData),
            headerAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
            },
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
            },
            columnWidths: {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(4),
              3: pw.FlexColumnWidth(2),
            },
          ),
        ],
      ),
    );
    return doc.save();
  }

  static Future<void> saveAsFile(
      BuildContext context, Uint8List pdfData) async {
    final appDocDir = await getExternalStorageDirectory();
    final appDocPath = appDocDir.path;
    final file = File(
        appDocPath + '/' + 'Document-${DateTime.now().toIso8601String()}.pdf');
    print('Save as file ${file.path} ...');
    await file.writeAsBytes(pdfData);
    await OpenFile.open(file.path);
  }
}
