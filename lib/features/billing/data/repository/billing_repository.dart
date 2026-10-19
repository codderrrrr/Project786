import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/billing/domain/models/obligation.dart';

abstract class BillingRepository {
  Future<CursorPage<Obligation>> listObligations({String? cursor, int limit = 20, String? status});
}
