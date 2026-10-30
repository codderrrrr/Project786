import 'package:decimal/decimal.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/services/data/datasource/dummy_services_datasource.dart';
import 'package:subscription_saas_flutter/features/services/data/repository/services_repository.dart';
import 'package:subscription_saas_flutter/features/services/domain/models/service.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final DummyServicesDatasource datasource;

  ServicesRepositoryImpl(this.datasource);

  @override
  Future<CursorPage<Service>> listServices({String? cursor, int limit = 20}) =>
      datasource.listServices(cursor: cursor, limit: limit);

  @override
  Future<Service?> getService(String id) => datasource.getService(id);

  @override
  Future<Service> createService({
    required String name,
    required String description,
    required Decimal price,
    required String billingPeriod,
  }) => datasource.createService(
    name: name,
    description: description,
    price: price,
    billingPeriod: billingPeriod,
  );

  @override
  Future<Service> setServiceActive(String id, bool active) =>
      datasource.setServiceActive(id, active);
}
