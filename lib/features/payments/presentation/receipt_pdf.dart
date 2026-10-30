import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';
import 'package:subscription_saas_flutter/core/money/money.dart';

Future<Uint8List> generateReceiptPdf(Payment payment) async {
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Receipt',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Receipt ID: ${payment.receiptId ?? payment.id}'),
            pw.Text('Payment ID: ${payment.id}'),
            pw.Text(
              'Subscriber: ${payment.subscriberName} (${payment.subscriberId})',
            ),
            pw.Text('Date: ${payment.paymentDate}'),
            pw.Text('Status: ${payment.status}'),
            pw.SizedBox(height: 20),
            pw.Text(
              'Items',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ...payment.items.map(
              (i) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${i.serviceName} (${i.subscriptionId}) - Due ${i.dueDate}',
                  ),
                  pw.Text(MoneyUtils.formatPKR(i.amount)),
                ],
              ),
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Calculated'),
                pw.Text(MoneyUtils.formatPKR(payment.calculatedAmount)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Billed'),
                pw.Text(MoneyUtils.formatPKR(payment.billedAmount)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Final Total'),
                pw.Text(
                  MoneyUtils.formatPKR(payment.finalAmount),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Spacer(),
            pw.Text(
              'Generated locally (immutable snapshot)',
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        );
      },
    ),
  );
  return await doc.save();
}

Future<void> shareReceipt(Payment payment) async {
  final bytes = await generateReceiptPdf(payment);
  await Printing.sharePdf(
    bytes: bytes,
    filename: 'receipt_${payment.receiptId ?? payment.id}.pdf',
  );
}
