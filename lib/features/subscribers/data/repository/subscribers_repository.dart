import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/subscribers/domain/models/subscriber.dart';

abstract class SubscribersRepository {
  Future<CursorPage<Subscriber>> listSubscribers({
    String? cursor,
    int limit = 20,
    String? query,
  });

  Future<Subscriber?> getSubscriber(String id);

  Future<Subscriber> createSubscriber({
    required String name,
    required String phone,
    String cnic,
  });

  Future<Subscriber> setSubscriberActive(String id, bool active);
}
