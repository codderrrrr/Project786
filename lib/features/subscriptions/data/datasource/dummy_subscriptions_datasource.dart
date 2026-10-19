import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor_utils.dart';
import 'package:subscription_saas_flutter/features/subscriptions/data/datasource/dummy_subscriptions_store.dart';
import 'package:subscription_saas_flutter/features/subscriptions/domain/models/subscription.dart';

class DummySubscriptionsDatasource {
  Future<CursorPage<Subscription>> listSubscriptions({
    String? cursor,
    int limit = 20,
    String? subscriberId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = DummySubscriptionsStore.all();
    var filtered = all;
    if (subscriberId != null && subscriberId.isNotEmpty) {
      filtered = all.where((e) => e.subscriberId == subscriberId).toList();
    }
    final offset = CursorUtils.decode(cursor);
    final end = (offset + limit) > filtered.length ? filtered.length : (offset + limit);
    final items = offset >= filtered.length ? <Subscription>[] : filtered.sublist(offset, end);
    final next = end < filtered.length ? CursorUtils.encode(end) : null;
    return CursorPage(items: items, nextCursor: next, hasMore: next != null);
  }

  Future<Subscription?> getSubscription(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return DummySubscriptionsStore.byId(id);
  }

  Future<Subscription> changeNextPaymentDate(String id, String nextPaymentDate) async {
    await Future.delayed(const Duration(milliseconds: 220));
    return DummySubscriptionsStore.changeNextPaymentDate(id, nextPaymentDate);
  }

  Future<Subscription> cancelSubscription(String id, {required String endedOn}) async {
    await Future.delayed(const Duration(milliseconds: 260));
    return DummySubscriptionsStore.cancel(id, endedOn: endedOn);
  }
}
