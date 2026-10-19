import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/subscriptions/domain/models/subscription.dart';

abstract class SubscriptionsRepository {
  Future<CursorPage<Subscription>> listSubscriptions({
    String? cursor,
    int limit = 20,
    String? subscriberId,
  });

  Future<Subscription?> getSubscription(String id);

  Future<Subscription> changeNextPaymentDate(String id, String nextPaymentDate);

  Future<Subscription> cancelSubscription(String id, {required String endedOn});
}
