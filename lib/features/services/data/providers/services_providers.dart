import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/features/services/data/datasource/dummy_services_datasource.dart';
import 'package:subscription_saas_flutter/features/services/data/repository/services_repository_impl.dart';
import 'package:subscription_saas_flutter/features/services/domain/models/service.dart';

final dummyServicesDatasourceProvider = Provider((ref) => DummyServicesDatasource());
final servicesRepositoryProvider = Provider((ref) => ServicesRepositoryImpl(ref.watch(dummyServicesDatasourceProvider)));
final servicesListProvider = FutureProvider.autoDispose<CursorPage<Service>>((ref) {
  return ref.watch(servicesRepositoryProvider).listServices();
});
final serviceDetailProvider = FutureProvider.autoDispose.family<Service?, String>((ref, id) {
  return ref.watch(servicesRepositoryProvider).getService(id);
});
