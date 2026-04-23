import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SaleInvoicePdfBuilder {
  static Future<Uint8List> build({required Map<String, dynamic> sale}) async {
    // Stamp/sign rendering is intentionally disabled for now.

    final saleId = sale['id']?.toString() ?? '';
    final customerName = sale['customerName']?.toString().trim().isEmpty == true
        ? 'Walk-in Customer'
        : sale['customerName']?.toString() ?? 'Walk-in Customer';
    final createdAt = _formatDateTime(sale['createdAt']?.toString());
    final subtotal = _toDouble(sale['subtotal']);
    final total = _toDouble(sale['total']);
    final details = (sale['details'] as List<dynamic>? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>();

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 28, 36, 28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildHeader(saleId, createdAt, customerName),
              pw.SizedBox(height: 24),
              pw.Container(height: 1.4, color: PdfColor.fromHex('#334155')),
              pw.SizedBox(height: 24),
              _buildTableHeader(),
              pw.Column(
                children: details.isEmpty
                    ? [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text(
                            'No line items found for this sale.',
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColor.fromHex('#64748B'),
                            ),
                          ),
                        ),
                      ]
                    : details.map((detail) => _buildItemRow(detail)).toList(),
              ),
              pw.SizedBox(height: 22),
              _buildTotals(subtotal, total),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(
    String saleId,
    String createdAt,
    String customerName,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'M&M Group',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#243041'),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'INVENTORY MANAGEMENT',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColor.fromHex('#94A3B8'),
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#243041'),
              ),
            ),
            pw.SizedBox(height: 18),
            _metaRow('Invoice #', _displaySaleId(saleId)),
            pw.SizedBox(height: 4),
            _metaRow('Date', createdAt),
            pw.SizedBox(height: 4),
            _metaRow('Customer', customerName),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: PdfColor.fromHex('#F3F4F6'),
      child: pw.Row(
        children: [
          _tableHeaderCell('Description', flex: 5),
          _tableHeaderCell('Qty', flex: 1, textAlign: pw.TextAlign.center),
          _tableHeaderCell(
            'Unit Price',
            flex: 2,
            textAlign: pw.TextAlign.right,
          ),
          _tableHeaderCell('Amount', flex: 2, textAlign: pw.TextAlign.right),
        ],
      ),
    );
  }

  static pw.Widget _buildItemRow(Map<String, dynamic> detail) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromHex('#D7DEE8'), width: 0.8),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  detail['productName']?.toString() ?? 'Unnamed Product',
                  style: pw.TextStyle(
                    fontSize: 11.5,
                    color: PdfColor.fromHex('#374151'),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'SKU: ${detail['sku']?.toString() ?? '-'}',
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    color: PdfColor.fromHex('#94A3B8'),
                  ),
                ),
              ],
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              '${detail['quantity'] ?? 0}',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColor.fromHex('#374151'),
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              _money(_toDouble(detail['unitPrice'])),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColor.fromHex('#374151'),
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              _money(_toDouble(detail['lineTotal'])),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColor.fromHex('#374151'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotals(double subtotal, double total) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 240,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Subtotal:',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColor.fromHex('#334155'),
                  ),
                ),
                pw.Text(
                  'RS ${_money(subtotal)}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColor.fromHex('#334155'),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Container(height: 1.2, color: PdfColor.fromHex('#334155')),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL:',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#243041'),
                  ),
                ),
                pw.Text(
                  'RS ${_money(total)}',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#243041'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _metaRow(String label, String value) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColor.fromHex('#64748B'),
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#334155')),
        ),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(
    String text, {
    required int flex,
    pw.TextAlign textAlign = pw.TextAlign.left,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        text,
        textAlign: textAlign,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#1E293B'),
        ),
      ),
    );
  }

  static String _displaySaleId(String saleId) {
    if (saleId.isEmpty) {
      return '-';
    }
    return saleId.length > 8 ? saleId.substring(0, 8) : saleId;
  }

  static String _money(double value) {
    return value.toStringAsFixed(2);
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _formatDateTime(String? isoValue) {
    if (isoValue == null || isoValue.isEmpty) {
      return 'Unknown time';
    }

    final parsed = DateTime.tryParse(isoValue)?.toLocal();
    if (parsed == null) {
      return isoValue;
    }

    final y = parsed.year.toString().padLeft(4, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    final hh = parsed.hour.toString().padLeft(2, '0');
    final mm = parsed.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}
