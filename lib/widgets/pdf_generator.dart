import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
    final pw.Document doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat:
            PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        build: (pw.Context context) => <pw.Widget>[
          pw.Table.fromTextArray(
            context: context,
            data: transformData(rawData),
          )
        ],
      ),
    );
    return doc.save();
  }
}
