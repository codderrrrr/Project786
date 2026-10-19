import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/datasource/dummy_subscribers_datasource.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/repository/subscribers_repository_impl.dart';
import 'package:subscription_saas_flutter/features/subscribers/domain/models/subscriber.dart';

final dummySubscribersDatasourceProvider = Provider((ref) => DummySubscribersDatasource());
final subscribersRepositoryProvider = Provider((ref) => SubscribersRepositoryImpl(ref.watch(dummySubscribersDatasourceProvider)));
final subscribersListProvider = FutureProvider.autoDispose.family<CursorPage<Subscriber>, String?>((ref, query) {
  return ref.watch(subscribersRepositoryProvider).listSubscribers(query: query);
});
final subscriberDetailProvider = FutureProvider.autoDispose.family<Subscriber?, String>((ref, id) {
  return ref.watch(subscribersRepositoryProvider).getSubscriber(id);
});
