import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/models.dart';

class LabelItem {
  const LabelItem({
    required this.item,
    required this.codeValue,
    required this.itemType,
    required this.quantityText,
    required this.locationName,
  });

  final Item item;
  final String codeValue;
  final String itemType;
  final String quantityText;
  final String? locationName;
}

String itemQrValue(Item item) {
  final barcode = item.barcode?.trim();
  if (barcode != null && barcode.isNotEmpty) {
    return barcode;
  }

  return 'issued:item:${item.id}';
}

String safeLabelFileName(Item item) {
  final safeName = item.name
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  return 'issued_label_${safeName.isEmpty ? item.id : safeName}.pdf';
}

Future<Uint8List> buildSingleItemLabelPdf(LabelItem labelItem) async {
  final document = pw.Document();

  document.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (context) =>
          pw.Center(child: _fullLabel(labelItem, width: 252, height: 144)),
    ),
  );

  return document.save();
}

Future<Uint8List> buildBatchLabelsPdf(List<LabelItem> labelItems) async {
  final document = pw.Document();
  const labelsPerPage = 21;

  for (var start = 0; start < labelItems.length; start += labelsPerPage) {
    final pageItems = labelItems.skip(start).take(labelsPerPage).toList();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => _labelGrid(pageItems),
      ),
    );
  }

  return document.save();
}

pw.Widget _labelGrid(List<LabelItem> labelItems) {
  final rows = <pw.Widget>[];

  for (var start = 0; start < labelItems.length; start += 3) {
    final rowItems = labelItems.skip(start).take(3).toList();
    rows.add(
      pw.Expanded(
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            for (final labelItem in rowItems) ...[
              pw.Expanded(child: _compactLabel(labelItem)),
              if (labelItem != rowItems.last) pw.SizedBox(width: 8),
            ],
            for (var index = rowItems.length; index < 3; index++) ...[
              if (rowItems.isNotEmpty || index > 0) pw.SizedBox(width: 8),
              pw.Expanded(child: pw.SizedBox()),
            ],
          ],
        ),
      ),
    );

    if (start + 3 < labelItems.length) {
      rows.add(pw.SizedBox(height: 8));
    }
  }

  return pw.Column(children: rows);
}

pw.Widget _fullLabel(
  LabelItem labelItem, {
  required double width,
  required double height,
}) {
  return pw.Container(
    width: width,
    height: height,
    padding: const pw.EdgeInsets.all(10),
    decoration: _labelDecoration(),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Issued',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                labelItem.item.name,
                maxLines: 2,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                labelItem.itemType,
                style: const pw.TextStyle(fontSize: 8),
              ),
              if (labelItem.locationName != null)
                pw.Text(
                  labelItem.locationName!,
                  maxLines: 1,
                  style: const pw.TextStyle(fontSize: 8),
                ),
              if (labelItem.quantityText.isNotEmpty)
                pw.Text(
                  labelItem.quantityText,
                  style: const pw.TextStyle(fontSize: 8),
                ),
              pw.Spacer(),
              pw.Text(
                labelItem.codeValue,
                maxLines: 2,
                style: const pw.TextStyle(fontSize: 7),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Center(
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: labelItem.codeValue,
            width: 88,
            height: 88,
            drawText: false,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _compactLabel(LabelItem labelItem) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(7),
    decoration: _labelDecoration(),
    child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'Issued',
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          labelItem.item.name,
          maxLines: 2,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: labelItem.codeValue,
          width: 54,
          height: 54,
          drawText: false,
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          labelItem.codeValue,
          maxLines: 1,
          textAlign: pw.TextAlign.center,
          style: const pw.TextStyle(fontSize: 5),
        ),
      ],
    ),
  );
}

pw.BoxDecoration _labelDecoration() {
  return pw.BoxDecoration(
    border: pw.Border.all(color: PdfColors.grey700, width: 0.7),
    color: PdfColors.white,
  );
}
