import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor_utils.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/datasource/dummy_subscribers_store.dart';
import 'package:subscription_saas_flutter/features/subscribers/domain/models/subscriber.dart';

class DummySubscribersDatasource {
  Future<CursorPage<Subscriber>> listSubscribers({
    String? cursor,
    int limit = 20,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = DummySubscribersStore.all();
    var filtered = all;
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = all
          .where(
            (e) =>
                e.name.toLowerCase().contains(q) ||
                e.phone.contains(q) ||
                e.cnic.toLowerCase().contains(q),
          )
          .toList();
    }
    final offset = CursorUtils.decode(cursor);
    final end = (offset + limit) > filtered.length
        ? filtered.length
        : (offset + limit);
    final items = offset >= filtered.length
        ? <Subscriber>[]
        : filtered.sublist(offset, end);
    final next = end < filtered.length ? CursorUtils.encode(end) : null;
    return CursorPage(items: items, nextCursor: next, hasMore: next != null);
  }

  Future<Subscriber?> getSubscriber(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return DummySubscribersStore.byId(id);
  }

  Future<Subscriber> createSubscriber({
    required String name,
    required String phone,
    String cnic = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return DummySubscribersStore.create(name: name, phone: phone, cnic: cnic);
  }

  Future<Subscriber> setSubscriberActive(String id, bool active) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return DummySubscribersStore.setActive(id, active);
  }
}
