import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

import 'dialogs.dart';
import 'pressable.dart';
import 'surface_rows.dart';

/// Secondary destinations live here rather than in the primary bar, keeping the
/// main navigation to four items while leaving everything reachable in two taps.
Future<void> showMoreMenu(BuildContext context, {String? businessName}) {
  return showAppSheet<void>(
    context,
    title: 'More',
    subtitle: businessName ?? 'Destinations and settings',
    builder: (context) => const _MoreList(),
  );
}

class _MoreList extends StatelessWidget {
  const _MoreList();

  @override
  Widget build(BuildContext context) {
    final groups = <(String, List<(String, String, String)>)>[
      (
        'Manage',
        [
          ('Services', 'What you sell and the price', '/services'),
          ('Subscriptions', 'Recurring arrangements', '/subscriptions'),
          ('Analytics', 'Revenue and utilisation', '/analytics'),
        ],
      ),
      (
        'Account',
        [
          ('Business profile', 'Name, contact, address', '/business'),
          ('Your profile', 'Your details and password', '/profile'),
          ('Active devices', 'Signed-in sessions', '/devices'),
          ('Plan status', 'Your subscription state', '/saas'),
        ],
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.gutter, 4, Gap.gutter, 24),
      shrinkWrap: true,
      children: [
        for (final g in groups) ...[
          SectionLabel(g.$1),
          SurfaceSection(
            children: [
              for (final item in g.$2)
                SurfaceRow(
                  title: item.$1,
                  subtitle: item.$2,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(item.$3);
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

/// Small group label used above grouped rows, matching section headers.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
      child: Text(text, style: AppType.title),
    );
  }
}

/// Avatar/initials button that opens [showMoreMenu]. A plain outlined circle —
/// no gradient, no glow — so the only filled circle on a screen is the one that
/// creates something.
class MoreButton extends StatelessWidget {
  const MoreButton({super.key, this.initials = 'DB', this.onTap});

  final String initials;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap ?? () => showMoreMenu(context),
      semanticLabel: 'More destinations and settings',
      excludeChildSemantics: true,
      // 48dp hit area around a 38dp circle: the visual stays restrained while
      // the target stays inside the platform guideline.
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline),
            ),
            child: Center(
              child: Text(
                initials,
                style: AppType.label.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
