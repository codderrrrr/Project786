import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor_utils.dart';
import 'package:subscription_saas_flutter/features/billing/data/datasource/dummy_billing_data.dart';
import 'package:subscription_saas_flutter/features/billing/domain/models/obligation.dart';

class DummyBillingDatasource {
  Future<CursorPage<Obligation>> listObligations({String? cursor, int limit = 20, String? status}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final all = DummyBillingData.all();
    var filtered = all;
    if (status != null && status.isNotEmpty) {
      filtered = all.where((e) => e.status == status).toList();
    }
    final offset = CursorUtils.decode(cursor);
    final end = (offset + limit) > filtered.length ? filtered.length : (offset + limit);
    final items = offset >= filtered.length ? <Obligation>[] : filtered.sublist(offset, end);
    final next = end < filtered.length ? CursorUtils.encode(end) : null;
    return CursorPage(items: items, nextCursor: next, hasMore: next != null);
  }
}
