import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/billing/data/datasource/dummy_billing_datasource.dart';
import 'package:subscription_saas_flutter/features/billing/data/repository/billing_repository_impl.dart';
import 'package:subscription_saas_flutter/features/billing/domain/models/obligation.dart';

final dummyBillingDatasourceProvider = Provider((ref) => DummyBillingDatasource());
final billingRepositoryProvider = Provider((ref) => BillingRepositoryImpl(ref.watch(dummyBillingDatasourceProvider)));
final billingObligationsProvider = FutureProvider.autoDispose<CursorPage<Obligation>>((ref) {
  return ref.watch(billingRepositoryProvider).listObligations();
});
