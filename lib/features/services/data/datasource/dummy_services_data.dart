import 'package:decimal/decimal.dart';
import 'package:subscription_saas_flutter/features/services/domain/models/service.dart';

class DummyServicesData {
  static List<Service> all() {
    return [
      Service(
        id: 'svc_001',
        name: 'Basic Plan',
        description: 'Basic recurring service',
        price: Decimal.parse('1000.00'),
        billingPeriod: 'monthly',
        active: true,
      ),
      Service(
        id: 'svc_002',
        name: 'Premium Plan',
        description: 'Premium recurring service',
        price: Decimal.parse('2500.00'),
        billingPeriod: 'monthly',
        active: true,
      ),
      Service(
        id: 'svc_003',
        name: 'On-Demand Session',
        description: 'One-time service',
        price: Decimal.parse('500.00'),
        billingPeriod: 'one_time',
        active: true,
      ),
      Service(
        id: 'svc_004',
        name: 'Inactive Service',
        description: 'Inactive test service',
        price: Decimal.parse('800.00'),
        billingPeriod: 'monthly',
        active: false,
      ),
    ];
  }
}
