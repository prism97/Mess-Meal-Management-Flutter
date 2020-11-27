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
    List<List<dynamic>> data = List();
    data.add(['Teacher ID', 'Name', 'Total Cost']);
    for (var entry in rawData) {
      List list = List();
      for (var field in entry.values) {
        list.add(field);
      }
      data.add(list);
    }
    return data;
  }

  static Future<Uint8List> generate(List<Map<String, dynamic>> rawData) async {
    var myTheme = pw.ThemeData.withFont(
      base: pw.Font.ttf(await rootBundle.load("assets/OpenSans-Regular.ttf")),
      bold: pw.Font.ttf(await rootBundle.load("assets/OpenSans-Bold.ttf")),
      italic: pw.Font.ttf(await rootBundle.load("assets/OpenSans-Italic.ttf")),
      boldItalic:
          pw.Font.ttf(await rootBundle.load("assets/OpenSans-BoldItalic.ttf")),
    );

    final pw.Document doc = pw.Document(theme: myTheme);

    doc.addPage(
      pw.MultiPage(
        pageFormat:
            PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        build: (pw.Context context) => <pw.Widget>[
          // TODO : add more stuff
          // TODO : make cost precision 2
          pw.Table.fromTextArray(
            context: context,
            data: transformData(rawData),
          )
        ],
      ),
    );
    return doc.save();
  }

  static Future<void> saveAsFile(
      BuildContext context, Uint8List pdfData) async {
    final appDocDir = await getExternalStorageDirectory();
    final appDocPath = appDocDir.path;
    final file = File(appDocPath + '/' + 'document.pdf');
    print('Save as file ${file.path} ...');
    await file.writeAsBytes(pdfData);
    await OpenFile.open(file.path);
  }
}