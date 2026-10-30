import 'package:decimal/decimal.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';
import 'package:subscription_saas_flutter/features/subscriptions/domain/models/subscription.dart';

/// In-memory subscription store for the demo build.
///
/// Only the fields the TRD marks as mutable are changed here (next payment
/// date and cancellation state); identity and schedule-origin stay untouched.
class DummySubscriptionsStore {
  DummySubscriptionsStore._();

  static final List<Subscription> _items = List.of(_seed());

  static List<Subscription> _seed() {
    final today = BizDate.todayYMD();
    final t = DateTime.parse(today);
    String shift(int days) =>
        DateTime(t.year, t.month, t.day + days).toIso8601String().split('T')[0];
    return [
      Subscription(
        id: 'subscr_001',
        subscriberId: 'sub_001',
        serviceId: 'svc_001',
        status: 'active',
        price: Decimal.parse('1000.00'),
        billingPeriod: 'monthly',
        startDate: today,
        nextPaymentDate: shift(-5),
      ),
      Subscription(
        id: 'subscr_002',
        subscriberId: 'sub_001',
        serviceId: 'svc_002',
        status: 'active',
        price: Decimal.parse('2500.00'),
        billingPeriod: 'monthly',
        startDate: today,
        nextPaymentDate: shift(-5),
      ),
      Subscription(
        id: 'subscr_003',
        subscriberId: 'sub_002',
        serviceId: 'svc_001',
        status: 'active',
        price: Decimal.parse('1000.00'),
        billingPeriod: 'monthly',
        startDate: today,
        nextPaymentDate: shift(2),
      ),
      Subscription(
        id: 'subscr_004',
        subscriberId: 'sub_003',
        serviceId: 'svc_003',
        status: 'active',
        price: Decimal.parse('500.00'),
        billingPeriod: 'one_time',
        startDate: today,
        nextPaymentDate: today,
      ),
    ];
  }

  static List<Subscription> all() => List.unmodifiable(_items);

  static Subscription? byId(String id) {
    for (final s in _items) {
      if (s.id == id) return s;
    }
    return null;
  }

  static Subscription changeNextPaymentDate(String id, String nextPaymentDate) {
    final current = _require(id);
    final updated = Subscription(
      id: current.id,
      subscriberId: current.subscriberId,
      serviceId: current.serviceId,
      status: current.status,
      price: current.price,
      billingPeriod: current.billingPeriod,
      startDate: current.startDate,
      nextPaymentDate: nextPaymentDate,
      endDate: current.endDate,
      cancelled: current.cancelled,
    );
    _replace(updated);
    return updated;
  }

  static Subscription cancel(String id, {required String endedOn}) {
    final current = _require(id);
    final updated = Subscription(
      id: current.id,
      subscriberId: current.subscriberId,
      serviceId: current.serviceId,
      status: 'cancelled',
      price: current.price,
      billingPeriod: current.billingPeriod,
      startDate: current.startDate,
      nextPaymentDate: current.nextPaymentDate,
      endDate: endedOn,
      cancelled: true,
    );
    _replace(updated);
    return updated;
  }

  static Subscription _require(String id) {
    final current = byId(id);
    if (current == null) throw StateError('Subscription $id no longer exists');
    return current;
  }

  static void _replace(Subscription s) {
    _items[_items.indexWhere((e) => e.id == s.id)] = s;
  }
}
