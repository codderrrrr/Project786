import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/billing/data/datasource/dummy_billing_datasource.dart';
import 'package:subscription_saas_flutter/features/billing/data/repository/billing_repository.dart';
import 'package:subscription_saas_flutter/features/billing/domain/models/obligation.dart';

class BillingRepositoryImpl implements BillingRepository {
  final DummyBillingDatasource datasource;
  BillingRepositoryImpl(this.datasource);

  @override
  Future<CursorPage<Obligation>> listObligations({String? cursor, int limit = 20, String? status}) {
    return datasource.listObligations(cursor: cursor, limit: limit, status: status);
  }
}
