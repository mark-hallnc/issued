import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/models.dart';

enum LabelTemplate { small, medium, avery5160, fullPageList }

class LabelTemplateSpec {
  const LabelTemplateSpec({
    required this.template,
    required this.name,
    required this.pageFormat,
    required this.margin,
    required this.columns,
    required this.rows,
    required this.labelWidth,
    required this.labelHeight,
    required this.titleFontSize,
    required this.detailFontSize,
    required this.qrSize,
    this.gap = 6,
    this.isList = false,
  });

  final LabelTemplate template;
  final String name;
  final PdfPageFormat pageFormat;
  final pw.EdgeInsets margin;
  final int columns;
  final int rows;
  final double labelWidth;
  final double labelHeight;
  final double titleFontSize;
  final double detailFontSize;
  final double qrSize;
  final double gap;
  final bool isList;

  int get labelsPerPage => columns * rows;
}

class LabelRecord {
  const LabelRecord({
    required this.title,
    required this.payload,
    required this.kind,
    this.subtitle,
    this.detail,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final String? detail;
  final String? footer;
  final String payload;
  final String kind;
}

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

  LabelRecord toRecord() {
    final secondary = <String>[
      if ((item.sku ?? '').trim().isNotEmpty) 'SKU: ${item.sku!.trim()}',
      if ((item.barcode ?? '').trim().isNotEmpty)
        'Barcode: ${item.barcode!.trim()}',
    ].join('  ');

    return LabelRecord(
      title: item.name,
      subtitle: itemType,
      detail: locationName,
      footer: secondary.isEmpty ? quantityText : secondary,
      payload: codeValue,
      kind: 'Item',
    );
  }
}

List<LabelTemplateSpec> get labelTemplates => const [
  LabelTemplateSpec(
    template: LabelTemplate.small,
    name: 'Small labels (2 x 1 in)',
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.all(24),
    columns: 3,
    rows: 7,
    labelWidth: 144,
    labelHeight: 72,
    titleFontSize: 7.5,
    detailFontSize: 5.5,
    qrSize: 42,
  ),
  LabelTemplateSpec(
    template: LabelTemplate.medium,
    name: 'Medium labels (3 x 2 in)',
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.all(24),
    columns: 2,
    rows: 5,
    labelWidth: 216,
    labelHeight: 144,
    titleFontSize: 11,
    detailFontSize: 7,
    qrSize: 72,
  ),
  LabelTemplateSpec(
    template: LabelTemplate.avery5160,
    name: 'Avery 5160-style (30/page)',
    pageFormat: PdfPageFormat.letter,
    margin: pw.EdgeInsets.symmetric(horizontal: 18, vertical: 36),
    columns: 3,
    rows: 10,
    labelWidth: 189,
    labelHeight: 72,
    titleFontSize: 7,
    detailFontSize: 5,
    qrSize: 38,
    gap: 0,
  ),
  LabelTemplateSpec(
    template: LabelTemplate.fullPageList,
    name: 'Full-page list with QR codes',
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.all(28),
    columns: 1,
    rows: 8,
    labelWidth: 520,
    labelHeight: 86,
    titleFontSize: 11,
    detailFontSize: 7,
    qrSize: 58,
    isList: true,
  ),
];

LabelTemplateSpec labelTemplateSpec(LabelTemplate template) {
  return labelTemplates.firstWhere((spec) => spec.template == template);
}

String itemQrValue(Item item) => 'ISSUED:ITEM:${item.id}';

String legacyItemQrValue(Item item) {
  final barcode = item.barcode?.trim();
  if (barcode != null && barcode.isNotEmpty) {
    return barcode;
  }
  return 'issued:item:${item.id}';
}

String locationQrValue(Location location) => 'ISSUED:LOCATION:${location.id}';

String assignmentTargetQrValue(AssignmentTarget target) =>
    'ISSUED:TARGET:${target.id}';

int estimateLabelPages({
  required int recordCount,
  required int copies,
  required LabelTemplate template,
}) {
  if (recordCount <= 0 || copies <= 0) {
    return 0;
  }
  final spec = labelTemplateSpec(template);
  return (recordCount * copies / spec.labelsPerPage).ceil();
}

String safeLabelFileName(Item item) {
  final safeName = _slug(item.name);
  return 'issued_label_${safeName.isEmpty ? item.id : safeName}.pdf';
}

String labelBatchFileName(String typeName) {
  final now = DateTime.now();
  final stamp =
      '${now.year.toString().padLeft(4, '0')}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}_'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}';
  return 'issued_${_slug(typeName)}_labels_$stamp.pdf';
}

Future<Uint8List> buildSingleItemLabelPdf(LabelItem labelItem) {
  return buildLabelBatchPdf(
    records: [labelItem.toRecord()],
    template: LabelTemplate.medium,
  );
}

Future<Uint8List> buildBatchLabelsPdf(List<LabelItem> labelItems) {
  return buildLabelBatchPdf(
    records: labelItems.map((label) => label.toRecord()).toList(),
    template: LabelTemplate.small,
  );
}

Future<Uint8List> buildLabelBatchPdf({
  required List<LabelRecord> records,
  required LabelTemplate template,
  int copies = 1,
}) async {
  final spec = labelTemplateSpec(template);
  final expandedRecords = <LabelRecord>[
    for (final record in records)
      for (var copy = 0; copy < copies; copy++) record,
  ];
  final document = pw.Document();

  for (
    var start = 0;
    start < expandedRecords.length;
    start += spec.labelsPerPage
  ) {
    final pageRecords = expandedRecords
        .skip(start)
        .take(spec.labelsPerPage)
        .toList();
    document.addPage(
      pw.Page(
        pageFormat: spec.pageFormat,
        margin: spec.margin,
        build: (context) => spec.isList
            ? _listLabels(pageRecords, spec)
            : _sheetLabels(pageRecords, spec),
      ),
    );
  }

  if (expandedRecords.isEmpty) {
    document.addPage(
      pw.Page(
        pageFormat: spec.pageFormat,
        margin: spec.margin,
        build: (context) => pw.Center(child: pw.Text('No labels selected.')),
      ),
    );
  }

  return document.save();
}

pw.Widget _sheetLabels(List<LabelRecord> records, LabelTemplateSpec spec) {
  return pw.Column(
    children: [
      for (var rowIndex = 0; rowIndex < spec.rows; rowIndex++) ...[
        pw.Row(
          children: [
            for (
              var columnIndex = 0;
              columnIndex < spec.columns;
              columnIndex++
            ) ...[
              _labelAt(records, rowIndex * spec.columns + columnIndex, spec),
              if (columnIndex < spec.columns - 1) pw.SizedBox(width: spec.gap),
            ],
          ],
        ),
        if (rowIndex < spec.rows - 1) pw.SizedBox(height: spec.gap),
      ],
    ],
  );
}

pw.Widget _listLabels(List<LabelRecord> records, LabelTemplateSpec spec) {
  return pw.Column(
    children: [
      for (var index = 0; index < spec.labelsPerPage; index++) ...[
        _labelAt(records, index, spec),
        if (index < spec.labelsPerPage - 1) pw.SizedBox(height: spec.gap),
      ],
    ],
  );
}

pw.Widget _labelAt(
  List<LabelRecord> records,
  int index,
  LabelTemplateSpec spec,
) {
  if (index >= records.length) {
    return pw.Container(width: spec.labelWidth, height: spec.labelHeight);
  }
  return _label(records[index], spec);
}

pw.Widget _label(LabelRecord record, LabelTemplateSpec spec) {
  final titleLines = spec.labelHeight <= 80 ? 2 : 3;
  return pw.Container(
    width: spec.labelWidth,
    height: spec.labelHeight,
    padding: const pw.EdgeInsets.all(6),
    decoration: _labelDecoration(),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Issued ${record.kind}',
                maxLines: 1,
                style: pw.TextStyle(
                  fontSize: math.max(5, spec.detailFontSize),
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                record.title,
                maxLines: titleLines,
                style: pw.TextStyle(
                  fontSize: spec.titleFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if ((record.subtitle ?? '').isNotEmpty)
                pw.Text(
                  record.subtitle!,
                  maxLines: 1,
                  style: pw.TextStyle(fontSize: spec.detailFontSize),
                ),
              if ((record.detail ?? '').isNotEmpty)
                pw.Text(
                  record.detail!,
                  maxLines: 1,
                  style: pw.TextStyle(fontSize: spec.detailFontSize),
                ),
              if ((record.footer ?? '').isNotEmpty)
                pw.Text(
                  record.footer!,
                  maxLines: 1,
                  style: pw.TextStyle(fontSize: spec.detailFontSize),
                ),
              pw.Spacer(),
              pw.Text(
                record.payload,
                maxLines: 1,
                style: pw.TextStyle(
                  fontSize: math.max(4, spec.detailFontSize - 1),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Center(
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: record.payload,
            width: spec.qrSize,
            height: spec.qrSize,
            drawText: false,
          ),
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

String _slug(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}
