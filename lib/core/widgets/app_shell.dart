import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:subscription_saas_flutter/app/layout.dart';
import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_palette.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/app/theme/theme_controller.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';
import 'package:subscription_saas_flutter/core/widgets/more_menu.dart';
import 'package:subscription_saas_flutter/features/dashboard/presentation/hide_amounts_provider.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  /// Key for the phone-layout scaffold so screens inside the shell (e.g. the
  /// dashboard header) can open the drawer without a context walk that would
  /// stop at their own inner scaffold.
  static final GlobalKey<ScaffoldState> _phoneScaffoldKey = GlobalKey<ScaffoldState>();

  static void openDrawer() => _phoneScaffoldKey.currentState?.openDrawer();

  static final List<_NavItem> _items = [
    _NavItem('Subscribers', Icons.people_alt_rounded, Icons.people_alt_outlined),
    _NavItem('Services', Icons.inventory_2_rounded, Icons.inventory_2_outlined),
    _NavItem('Home', Icons.home_rounded, Icons.home_outlined),
    _NavItem('Billing', Icons.receipt_long_rounded, Icons.receipt_long_outlined),
    _NavItem('History', Icons.history_rounded, Icons.history_outlined),
  ];

  void _go(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  /// Builds the side drawer with the review-specified items.
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.16),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: AppColors.outlineSoft)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadii.rMd,
                  ),
                  child: Icon(Icons.storefront_rounded, color: AppColors.onAccent, size: 24),
                ),
                const Spacer(),
                Text('Demo Business', style: AppType.title),
                const SizedBox(height: 2),
                Text('Workspace menu', style: AppType.caption),
              ],
            ),
          ),
          // Analytics
          ListTile(
            leading: Icon(Icons.insights_rounded, color: AppColors.primary),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/analytics');
            },
          ),
          // Business profile
          ListTile(
            leading: Icon(Icons.business_rounded, color: AppColors.primary),
            title: const Text('Business profile'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/business');
            },
          ),
          // Owner profile
          ListTile(
            leading: Icon(Icons.person_rounded, color: AppColors.primary),
            title: const Text('Owner profile'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/profile');
            },
          ),
          // Plan status (Business Plan/Licence)
          ListTile(
            leading: Icon(Icons.workspace_premium_rounded, color: AppColors.primary),
            title: const Text('Plan status'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/saas');
            },
          ),
          // Change password
          ListTile(
            leading: Icon(Icons.lock_outlined, color: AppColors.primary),
            title: const Text('Change password'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/change-password');
            },
          ),
          // Light/dark toggle (theme picker eliminated per review)
          Consumer(builder: (context, ref, _) {
            final palette = ref.watch(themeControllerProvider);
            return SwitchListTile(
              secondary: Icon(
                palette.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Dark mode'),
              value: palette.isDark,
              onChanged: (dark) {
                final target = dark
                    ? AppPalettes.nocturneBloom
                    : AppPalettes.pixelLight;
                ref.read(themeControllerProvider.notifier).select(target);
              },
            );
          }),
          // Hide amounts toggle (home screen only)
          Consumer(builder: (context, ref, _) {
            final hidden = ref.watch(hideAmountsProvider);
            return SwitchListTile(
              secondary: Icon(
                hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Hide amounts'),
              subtitle: const Text('Home screen only'),
              value: hidden,
              onChanged: (v) => ref.read(hideAmountsProvider.notifier).state = v,
            );
          }),
          const Divider(height: 1),
          // Contact service provider
          ListTile(
            leading: Icon(Icons.support_agent_rounded, color: AppColors.primary),
            title: const Text('Contact support'),
            onTap: () {
              Navigator.of(context).pop();
              showAppSnack(context, message: 'Support: +92 300 0000000');
            },
          ),
          // Privacy policy
          ListTile(
            leading: Icon(Icons.privacy_tip_rounded, color: AppColors.primary),
            title: const Text('Privacy policy'),
            onTap: () {
              Navigator.of(context).pop();
              showAppSnack(context, message: 'Privacy policy coming soon');
            },
          ),
          // Logout
          ListTile(
            leading: Icon(Icons.logout_rounded, color: AppColors.danger),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              showConfirmDialog(
                context,
                title: 'Log out?',
                message: 'Are you sure you want to log out?',
                confirmLabel: 'Log out',
                destructive: true,
              ).then((value) {
                if (value == true) {
                  // TODO: Implement logout
                  if (context.mounted) {
                    showAppSnack(context, message: 'Logged out successfully');
                  }
                }
              });
            },
          ),
          // App version centered and unclickable at the bottom
          Padding(
            padding: EdgeInsets.only(top: 24, bottom: 16),
            child: Center(
              child: Text(
                '1.0.0',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = Layout.of(context);

    if (layout.wide) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            _NavRail(
              currentIndex: navigationShell.currentIndex,
              onSelect: _go,
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      key: _phoneScaffoldKey,
      backgroundColor: Colors.transparent,
      extendBody: true,
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x0A3B82F6),
                  Color(0x051E293B),
                ],
              ),
            ),
          ),
          navigationShell,
        ],
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: navigationShell.currentIndex,
        onSelect: _go,
      ),
    );
  }
}

/// Labeled destinations down the left edge on wide displays.
/// The rail keeps its labels — an icon-only rail costs every user a guessing game.
class _NavRail extends StatelessWidget {
  const _NavRail({
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.outlineSoft)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            for (var i = 0; i < AppShell._items.length; i++)
              _RailItem(
                item: AppShell._items[i],
                selected: currentIndex == i,
                onTap: () => onSelect(i),
              ),
            const Spacer(),
            _RailItem(
              item: const _NavItem('More', Icons.more_horiz_rounded, Icons.more_horiz_rounded),
              selected: false,
              onTap: () => showMoreMenu(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({required this.item, required this.selected, required this.onTap});

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? AppColors.primary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
             Icon(
               item.icon,
               color: iconColor,
               size: 24,
             ),
             const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.label,
                style: AppType.label.copyWith(
                  color: iconColor,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating bottom navigation bar: an inset, rounded surface that hovers above
/// the bottom edge instead of spanning it edge-to-edge. Each destination keeps
/// a visible label — an icon-only bar makes users guess.
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: AppRadii.rXl,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: AppColors.isDark ? 0.84 : 0.94),
              borderRadius: AppRadii.rXl,
              border: Border.all(color: AppColors.outlineSoft),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              child: Row(
                children: [
                  for (var i = 0; i < AppShell._items.length; i++)
                    Expanded(
                      child: _NavBarItem(
                        item: AppShell._items[i],
                        selected: currentIndex == i,
                        onTap: () => onSelect(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? AppColors.primary : AppColors.textSecondary;
    final labelColor = selected ? AppColors.primary : AppColors.textTertiary;
    final isHome = item.label == 'Home';

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.scale(context, AppMotion.fast),
          curve: AppMotion.emphasized,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.10) : Colors.transparent,
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.primary.withValues(alpha: 0.06),
                    ],
                  )
                : null,
            borderRadius: AppRadii.rLg,
            border: selected
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.22))
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.20),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.icon : item.outlineIcon,
                size: selected && isHome ? 24 : 22,
                color: iconColor,
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 16,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    style: AppType.label.copyWith(
                      color: labelColor,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.outlineIcon);

  final String label;
  final IconData icon;
  final IconData outlineIcon;
}
