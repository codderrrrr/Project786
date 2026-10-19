import 'package:decimal/decimal.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/services/domain/models/service.dart';

abstract class ServicesRepository {
  Future<CursorPage<Service>> listServices({String? cursor, int limit = 20});

  Future<Service?> getService(String id);

  Future<Service> createService({
    required String name,
    required String description,
    required Decimal price,
    required String billingPeriod,
  });

  Future<Service> setServiceActive(String id, bool active);
}
