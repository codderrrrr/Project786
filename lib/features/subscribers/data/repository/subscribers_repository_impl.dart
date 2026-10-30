import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/datasource/dummy_subscribers_datasource.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/repository/subscribers_repository.dart';
import 'package:subscription_saas_flutter/features/subscribers/domain/models/subscriber.dart';

class SubscribersRepositoryImpl implements SubscribersRepository {
  final DummySubscribersDatasource datasource;

  SubscribersRepositoryImpl(this.datasource);

  @override
  Future<CursorPage<Subscriber>> listSubscribers({
    String? cursor,
    int limit = 20,
    String? query,
  }) => datasource.listSubscribers(cursor: cursor, limit: limit, query: query);

  @override
  Future<Subscriber?> getSubscriber(String id) => datasource.getSubscriber(id);

  @override
  Future<Subscriber> createSubscriber({
    required String name,
    required String phone,
    String cnic = '',
  }) => datasource.createSubscriber(name: name, phone: phone, cnic: cnic);

  @override
  Future<Subscriber> setSubscriberActive(String id, bool active) =>
      datasource.setSubscriberActive(id, active);
}
