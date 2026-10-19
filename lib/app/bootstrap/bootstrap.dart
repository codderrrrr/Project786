import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_saas_flutter/core/auth/demo_auth.dart';

final demoSessionProvider = StateProvider<DemoSession>((ref) {
  return DemoSession(
    businessId: 'b_demo',
    ownerId: 'o_demo',
    businessName: 'Demo Business',
    ownerName: 'Demo Owner',
    token: 'demo_token',
  );
});
