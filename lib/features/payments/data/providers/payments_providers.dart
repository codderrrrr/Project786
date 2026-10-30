import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/payments/data/datasource/dummy_payments_datasource.dart';
import 'package:subscription_saas_flutter/features/payments/data/repository/payments_repository_impl.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';

final dummyPaymentsDatasourceProvider = Provider(
  (ref) => DummyPaymentsDatasource(),
);
final paymentsRepositoryProvider = Provider(
  (ref) => PaymentsRepositoryImpl(ref.watch(dummyPaymentsDatasourceProvider)),
);
final paymentsListProvider = FutureProvider.autoDispose
    .family<CursorPage<Payment>, String?>((ref, subscriberId) {
      return ref
          .watch(paymentsRepositoryProvider)
          .listPayments(subscriberId: subscriberId);
    });
final paymentDetailProvider = FutureProvider.autoDispose
    .family<Payment?, String>((ref, id) {
      return ref.watch(paymentsRepositoryProvider).getPayment(id);
    });
