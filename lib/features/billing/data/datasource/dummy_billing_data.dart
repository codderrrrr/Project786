import 'package:decimal/decimal.dart';
import 'package:subscription_saas_flutter/features/billing/domain/models/obligation.dart';
import 'package:subscription_saas_flutter/features/subscriptions/data/datasource/dummy_subscriptions_store.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/datasource/dummy_subscribers_store.dart';
import 'package:subscription_saas_flutter/features/services/data/datasource/dummy_services_store.dart';
import 'package:subscription_saas_flutter/features/subscriptions/domain/models/subscription.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';

class DummyBillingData {
  static List<Obligation> all() {
    final today = BizDate.todayYMD();
    final subs = DummySubscriptionsStore.all();
    final subscribers = DummySubscribersStore.all();
    final services = DummyServicesStore.all();

    // Group by subscriber for demo
    final Map<String, List<Subscription>> groups = {};
    for (var s in subs) {
      groups.putIfAbsent(s.subscriberId, () => []).add(s);
    }

    final List<Obligation> obs = [];
    int idx = 0;
    for (var entry in groups.entries) {
      final sid = entry.key;
      final list = entry.value;
      final subName = subscribers.firstWhere((x) => x.id == sid).name;
      final total = list.fold<Decimal>(Decimal.zero, (p, e) => p + e.price);
      final dueDate = list.isNotEmpty ? list.first.nextPaymentDate : today;
      final t = DateTime.parse(today);
      final d = DateTime.parse(dueDate);
      final todayDate = DateTime(t.year, t.month, t.day);
      int daysOverdue = 0, daysDue = 0;
      if (d.isBefore(todayDate)) {
        daysOverdue = todayDate.difference(d).inDays;
      } else {
        daysDue = d.difference(todayDate).inDays;
      }
      final serviceNames = list.map<String>((e) {
        final sv = services.where((x) => x.id == e.serviceId).firstOrNull;
        return sv?.name ?? e.serviceId;
      }).toList();
      obs.add(
        Obligation(
          id: 'obl_${idx + 1}',
          subscriberId: sid,
          subscriberName: subName,
          subscriptionIds: list.map<String>((e) => e.id).toList(),
          serviceNames: serviceNames,
          amountDue: total,
          dueDate: dueDate,
          status: daysOverdue > 0 ? 'overdue' : 'due',
          daysOverdue: daysOverdue,
          daysDue: daysDue,
        ),
      );
      idx++;
    }
    return obs;
  }
}
