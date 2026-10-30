import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/subscriptions/data/datasource/dummy_subscriptions_datasource.dart';
import 'package:subscription_saas_flutter/features/subscriptions/data/repository/subscriptions_repository_impl.dart';
import 'package:subscription_saas_flutter/features/subscriptions/domain/models/subscription.dart';

final dummySubscriptionsDatasourceProvider = Provider(
  (ref) => DummySubscriptionsDatasource(),
);
final subscriptionsRepositoryProvider = Provider(
  (ref) => SubscriptionsRepositoryImpl(
    ref.watch(dummySubscriptionsDatasourceProvider),
  ),
);
final subscriptionsListProvider = FutureProvider.autoDispose
    .family<CursorPage<Subscription>, String?>((ref, subscriberId) {
      return ref
          .watch(subscriptionsRepositoryProvider)
          .listSubscriptions(subscriberId: subscriberId);
    });
final subscriptionDetailProvider = FutureProvider.autoDispose
    .family<Subscription?, String>((ref, id) {
      return ref.watch(subscriptionsRepositoryProvider).getSubscription(id);
    });
