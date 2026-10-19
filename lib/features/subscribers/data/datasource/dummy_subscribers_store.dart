import 'package:subscription_saas_flutter/core/date/biz_date.dart';
import 'package:subscription_saas_flutter/features/subscribers/domain/models/subscriber.dart';

/// In-memory store for the demo build.
///
/// It exists so create/edit/activate flows can be demonstrated end to end
/// without a backend. Swap this for the API-backed datasource later; the
/// repository contract above it does not change.
class DummySubscribersStore {
  DummySubscribersStore._();

  static final List<Subscriber> _items = List.of(_seed());

  static List<Subscriber> _seed() {
    final today = BizDate.todayYMD();
    return [
       Subscriber(id: 'sub_001', name: 'Alice Khan', phone: '+923001111111', active: true, createdAt: today),
       Subscriber(id: 'sub_002', name: 'Bilal Ahmed', phone: '+923002222222', active: true, createdAt: today),
       Subscriber(id: 'sub_003', name: 'Chaudhry Saad', phone: '+923003333333', active: true, createdAt: today),
       Subscriber(id: 'sub_004', name: 'Dina Farooq', phone: '+923004444444', active: false, createdAt: today),
    ];
  }

  static List<Subscriber> all() => List.unmodifiable(_items);

  static Subscriber? byId(String id) {
    for (final s in _items) {
      if (s.id == id) return s;
    }
    return null;
  }

  static Subscriber create({
    required String name,
    required String phone,
    String cnic = '',
  }) {
    final created = Subscriber(
      id: 'sub_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      phone: phone,
      cnic: cnic,
      active: true,
      createdAt: BizDate.todayYMD(),
    );
    _items.insert(0, created);
    return created;
  }

  static Subscriber setActive(String id, bool active) {
    final current = byId(id);
    if (current == null) {
      throw StateError('Subscriber $id no longer exists');
    }
    final updated = Subscriber(
      id: current.id,
      name: current.name,
      phone: current.phone,
       cnic: current.cnic,
      active: active,
      createdAt: current.createdAt,
    );
    _items[_items.indexWhere((e) => e.id == id)] = updated;
    return updated;
  }
}
