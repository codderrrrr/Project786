import 'package:decimal/decimal.dart';
import 'package:subscription_saas_flutter/features/services/data/datasource/dummy_services_data.dart';
import 'package:subscription_saas_flutter/features/services/domain/models/service.dart';

/// In-memory service store for the demo build.
class DummyServicesStore {
  DummyServicesStore._();

  static final List<Service> _items = List.of(DummyServicesData.all());

  static List<Service> all() => List.unmodifiable(_items);

  static Service? byId(String id) {
    for (final s in _items) {
      if (s.id == id) return s;
    }
    return null;
  }

  static Service create({
    required String name,
    required String description,
    required Decimal price,
    required String billingPeriod,
  }) {
    final created = Service(
      id: 'svc_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      description: description,
      price: price,
      billingPeriod: billingPeriod,
      active: true,
    );
    _items.insert(0, created);
    return created;
  }

  static Service update(Service service) {
    final index = _items.indexWhere((e) => e.id == service.id);
    if (index < 0) throw StateError('Service ${service.id} no longer exists');
    _items[index] = service;
    return service;
  }
}
