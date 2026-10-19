import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/core/widgets/app_shell.dart';
import 'package:subscription_saas_flutter/features/analytics/presentation/analytics_screen.dart';
import 'package:subscription_saas_flutter/features/payments/presentation/history_screen.dart';
import 'package:subscription_saas_flutter/features/auth/presentation/login_screen.dart';
import 'package:subscription_saas_flutter/features/auth/presentation/splash_screen.dart';
import 'package:subscription_saas_flutter/features/billing/presentation/billing_screen.dart';
import 'package:subscription_saas_flutter/features/business/presentation/business_screen.dart';
import 'package:subscription_saas_flutter/features/dashboard/presentation/dashboard_screen.dart';
import 'package:subscription_saas_flutter/features/devices/presentation/devices_screen.dart';
import 'package:subscription_saas_flutter/features/payments/presentation/payment_detail_screen.dart';
import 'package:subscription_saas_flutter/features/payments/presentation/payment_review_screen.dart';
import 'package:subscription_saas_flutter/features/payments/presentation/payments_screen.dart';
import 'package:subscription_saas_flutter/features/profile/presentation/profile_screen.dart';
import 'package:subscription_saas_flutter/features/saas/presentation/saas_screen.dart';
import 'package:subscription_saas_flutter/features/settings/presentation/appearance_screen.dart';
import 'package:subscription_saas_flutter/features/settings/presentation/change_password_screen.dart';
import 'package:subscription_saas_flutter/features/services/presentation/service_detail_screen.dart';
import 'package:subscription_saas_flutter/features/services/presentation/services_screen.dart';
import 'package:subscription_saas_flutter/features/subscribers/presentation/subscriber_detail_screen.dart';
import 'package:subscription_saas_flutter/features/subscribers/presentation/subscribers_screen.dart';
import 'package:subscription_saas_flutter/features/subscriptions/presentation/subscription_detail_screen.dart';
import 'package:subscription_saas_flutter/features/subscriptions/presentation/subscriptions_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // Top-level destinations keep their own navigation stack.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/subscribers',
                builder: (context, state) => const SubscribersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/services',
                builder: (context, state) => const ServicesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/billing',
                builder: (context, state) => const BillingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
        ],
      ),

      // Detail and commitment flows open full-screen with an explicit back path.
      // The read-only payments ledger keeps its own stack so a row can open
      // `/payments/:id` with the shared-amount Hero paired against it.
      GoRoute(
        path: '/payments',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/payments/review',
        builder: (context, state) => PaymentReviewScreen(
          subscriberId: state.uri.queryParameters['subscriberId'],
        ),
      ),
      GoRoute(
        path: '/payments/:id',
        builder: (context, state) =>
            PaymentDetailScreen(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/subscribers/:id',
        builder: (context, state) =>
            SubscriberDetailScreen(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/services/:id',
        builder: (context, state) =>
            ServiceDetailScreen(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/subscriptions',
        builder: (context, state) => const SubscriptionsScreen(),
      ),
      GoRoute(
        path: '/subscriptions/:id',
        builder: (context, state) =>
            SubscriptionDetailScreen(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/business',
        builder: (context, state) => const BusinessScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/devices',
        builder: (context, state) => const DevicesScreen(),
      ),
      GoRoute(path: '/saas', builder: (context, state) => const SaasScreen()),
      GoRoute(
        path: '/appearance',
        builder: (context, state) => const AppearanceScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
  );
});
