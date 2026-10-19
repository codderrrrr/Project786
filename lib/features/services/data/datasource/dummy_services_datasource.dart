import 'package:decimal/decimal.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor_utils.dart';
import 'package:subscription_saas_flutter/features/services/data/datasource/dummy_services_store.dart';
import 'package:subscription_saas_flutter/features/services/domain/models/service.dart';

class DummyServicesDatasource {
  Future<CursorPage<Service>> listServices({String? cursor, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final all = DummyServicesStore.all();
    final offset = CursorUtils.decode(cursor);
    final end = (offset + limit) > all.length ? all.length : (offset + limit);
    final items = offset >= all.length ? <Service>[] : all.sublist(offset, end);
    final next = end < all.length ? CursorUtils.encode(end) : null;
    return CursorPage(items: items, nextCursor: next, hasMore: next != null);
  }

  Future<Service?> getService(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return DummyServicesStore.byId(id);
  }

  Future<Service> createService({
    required String name,
    required String description,
    required Decimal price,
    required String billingPeriod,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return DummyServicesStore.create(
      name: name,
      description: description,
      price: price,
      billingPeriod: billingPeriod,
    );
  }

  Future<Service> setServiceActive(String id, bool active) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final current = DummyServicesStore.byId(id);
    if (current == null) throw StateError('Service $id no longer exists');
    return DummyServicesStore.update(
      Service(
        id: current.id,
        name: current.name,
        description: current.description,
        price: current.price,
        billingPeriod: current.billingPeriod,
        active: active,
      ),
    );
  }
}
