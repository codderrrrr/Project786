import 'package:decimal/decimal.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment_item.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';

class DummyPaymentsData {
  static List<Payment> all() {
    final today = BizDate.todayYMD();
    final t = DateTime.parse(today);
    final lastMonth = DateTime(
      t.year,
      t.month - 1,
      t.day,
    ).toIso8601String().split('T')[0];
    return [
      Payment(
        id: 'pay_001',
        subscriberId: 'sub_002',
        subscriberName: 'Bilal Ahmed',
        items: [
          PaymentItem(
            subscriptionId: 'subscr_003',
            serviceName: 'Basic Plan',
            amount: Decimal.parse('1000.00'),
            dueDate: lastMonth,
          ),
        ],
        calculatedAmount: Decimal.parse('1000.00'),
        billedAmount: Decimal.parse('1000.00'),
        finalAmount: Decimal.parse('1000.00'),
        paymentDate: lastMonth,
        status: 'success',
        receiptId: 'rcpt_001',
      ),
    ];
  }
}
