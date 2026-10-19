import 'package:subscription_saas_flutter/features/payments/data/datasource/dummy_payments_data.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';

class DummyPaymentsStore {
  static final List<Payment> _payments = List.from(DummyPaymentsData.all());
  
  static List<Payment> all() => List.unmodifiable(_payments);
  static void add(Payment p) => _payments.insert(0, p);
}
