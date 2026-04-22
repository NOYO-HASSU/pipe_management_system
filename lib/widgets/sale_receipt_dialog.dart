import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/colors.dart';
import '../repositories/sales_repository.dart';

class SaleReceiptDialog extends StatefulWidget {
  final Map<String, dynamic> sale;

  const SaleReceiptDialog({super.key, required this.sale});

  static Future<bool?> show(
    BuildContext context, {
    required Map<String, dynamic> sale,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SaleReceiptDialog(sale: sale),
    );
  }

  @override
  State<SaleReceiptDialog> createState() => _SaleReceiptDialogState();
}

class _SaleReceiptDialogState extends State<SaleReceiptDialog> {
  final SalesRepository _salesRepository = SalesRepository();
  bool _isPrinting = false;
  bool _isVoiding = false;

  Map<String, dynamic> get sale => widget.sale;

  List<Map<String, dynamic>> get details =>
      (sale['details'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();

  @override
  Widget build(BuildContext context) {
    final createdAt = _formatDateTime(sale['createdAt']?.toString());
    final total = _toDouble(sale['total']);
    final subtotal = _toDouble(sale['subtotal']);
    final tax = _toDouble(sale['tax']);
    final surcharge = _toDouble(sale['surcharge']);
    final content = SizedBox(
      width: 860,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'TRANSACTION DETAIL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Color(0xFF1E2A4A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        createdAt,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  splashRadius: 18,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 760;
                final itemColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ITEMIZED BREAKDOWN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (details.isEmpty)
                      const Text(
                        'No sold product details found for this sale.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      Column(
                        children: details
                            .map(
                              (detail) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF0FF),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD8E3FF),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          _initials(
                                            detail['productName']?.toString(),
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              detail['productName']
                                                      ?.toString() ??
                                                  'Unnamed Product',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              detail['sku']
                                                          ?.toString()
                                                          .isNotEmpty ==
                                                      true
                                                  ? 'SKU: ${detail['sku']}'
                                                  : 'SKU: -',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            Text(
                                              'Qty: ${detail['quantity']} x RS ${_formatMoney(_toDouble(detail['unitPrice']))}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'RS ${_formatMoney(_toDouble(detail['lineTotal']))}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'Qty ${detail['quantity']}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                );

                final summaryColumn = Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL SUMMARY',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _summaryRow('Subtotal', 'RS ${_formatMoney(subtotal)}'),
                      const SizedBox(height: 10),
                      _summaryRow('Tax (0%)', 'RS ${_formatMoney(tax)}'),
                      const SizedBox(height: 10),
                      _summaryRow('Surcharge', 'RS ${_formatMoney(surcharge)}'),
                      const Divider(height: 28, color: Colors.white12),
                      _summaryRow(
                        'Total',
                        'RS ${_formatMoney(total)}',
                        emphasize: true,
                      ),
                    ],
                  ),
                );

                final actionColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isPrinting ? null : _printReceipt,
                      icon: _isPrinting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.print, size: 18),
                      label: Text(
                        _isPrinting ? 'Preparing...' : 'Print Receipt',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD9E5FF),
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      itemColumn,
                      const SizedBox(height: 16),
                      summaryColumn,
                      const SizedBox(height: 14),
                      actionColumn,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: itemColumn),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 220,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          summaryColumn,
                          const SizedBox(height: 12),
                          actionColumn,
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Close Details'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isVoiding ? null : _confirmVoid,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(_isVoiding ? 'Voiding...' : 'Void Transaction'),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: content,
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: emphasize ? Colors.white : Colors.white70,
            fontSize: emphasize ? 22 : 12,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: emphasize ? 20 : 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Future<void> _printReceipt() async {
    setState(() {
      _isPrinting = true;
    });

    try {
      final pdf = await _buildPdf();
      await Printing.layoutPdf(onLayout: (_) async => pdf.save());
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  Future<void> _confirmVoid() async {
    final saleId = sale['id']?.toString() ?? '';
    if (saleId.isEmpty) {
      return;
    }

    final shouldVoid = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Void Transaction'),
          content: const Text(
            'This will restore product stock and remove the sale from revenue history. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Void'),
            ),
          ],
        );
      },
    );

    if (shouldVoid != true) {
      return;
    }

    setState(() {
      _isVoiding = true;
    });

    try {
      await _salesRepository.voidSale(saleId);
      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not void sale: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isVoiding = false;
        });
      }
    }
  }

  Future<pw.Document> _buildPdf() async {
    final doc = pw.Document();
    final createdAt = _formatDateTime(sale['createdAt']?.toString());
    final saleId = sale['id']?.toString() ?? '';
    final customerName = sale['customerName']?.toString() ?? 'Walk-in Customer';
    final subtotal = _toDouble(sale['subtotal']);
    final tax = _toDouble(sale['tax']);
    final surcharge = _toDouble(sale['surcharge']);
    final total = _toDouble(sale['total']);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'M&M Group',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Sales Receipt / Invoice'),
                pw.SizedBox(height: 18),
                pw.Text('Transaction ID: $saleId'),
                pw.Text('Customer: $customerName'),
                pw.Text('Date: $createdAt'),
                pw.SizedBox(height: 18),
                pw.TableHelper.fromTextArray(
                  headers: const ['Item', 'SKU', 'Qty', 'Unit', 'Total'],
                  data: details
                      .map(
                        (detail) => [
                          detail['productName']?.toString() ??
                              'Unnamed Product',
                          detail['sku']?.toString() ?? '-',
                          detail['quantity']?.toString() ?? '0',
                          'RS ${_formatMoney(_toDouble(detail['unitPrice']))}',
                          'RS ${_formatMoney(_toDouble(detail['lineTotal']))}',
                        ],
                      )
                      .toList(),
                ),
                pw.SizedBox(height: 18),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: RS ${_formatMoney(subtotal)}'),
                      pw.Text('Tax: RS ${_formatMoney(tax)}'),
                      pw.Text('Surcharge: RS ${_formatMoney(surcharge)}'),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Total: RS ${_formatMoney(total)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc;
  }

  String _initials(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return '?';
    }

    final words = text.split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }

    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
        .toUpperCase();
  }

  String _formatDateTime(String? isoValue) {
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

  String _formatMoney(double value) {
    return value.toStringAsFixed(2);
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
