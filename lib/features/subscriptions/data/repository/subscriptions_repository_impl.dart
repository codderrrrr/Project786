import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/subscriptions/data/datasource/dummy_subscriptions_datasource.dart';
import 'package:subscription_saas_flutter/features/subscriptions/data/repository/subscriptions_repository.dart';
import 'package:subscription_saas_flutter/features/subscriptions/domain/models/subscription.dart';

class SubscriptionsRepositoryImpl implements SubscriptionsRepository {
  final DummySubscriptionsDatasource datasource;

  SubscriptionsRepositoryImpl(this.datasource);

  @override
  Future<CursorPage<Subscription>> listSubscriptions({
    String? cursor,
    int limit = 20,
    String? subscriberId,
  }) =>
      datasource.listSubscriptions(
        cursor: cursor,
        limit: limit,
        subscriberId: subscriberId,
      );

  @override
  Future<Subscription?> getSubscription(String id) => datasource.getSubscription(id);

  @override
  Future<Subscription> changeNextPaymentDate(String id, String nextPaymentDate) =>
      datasource.changeNextPaymentDate(id, nextPaymentDate);

  @override
  Future<Subscription> cancelSubscription(String id, {required String endedOn}) =>
      datasource.cancelSubscription(id, endedOn: endedOn);
}
