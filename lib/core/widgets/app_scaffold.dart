import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

import 'app_background.dart';
import 'pressable.dart';

/// Screen frame used by every page: flat canvas, a compact title row, and an
/// optional pinned header (filters, search) directly beneath it.
///
/// The title is small and align-stable: every screen keeps the same 16dp text
/// gutter so titles, body text and row labels share one left edge.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
    this.bottomBar,
    this.floatingActionButton,
    this.showBack = true,
    this.onMenu,
    this.pinnedHeader,
    this.bodyPadding = const EdgeInsets.fromLTRB(Gap.gutter, 4, Gap.gutter, 24),
    this.backgroundIntensity = 1.0,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final bool showBack;

  /// Opens the shell's side drawer. When provided (and there is no back
  /// button) a menu icon sits in the leading slot, left of the title, per the
  /// review: "Left to the business name there should be icon to open a side
  /// drawer".
  final VoidCallback? onMenu;
  final Widget? pinnedHeader;
  final EdgeInsets bodyPadding;
  final double backgroundIntensity;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AuroraBackground(
        intensity: backgroundIntensity,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                title: title,
                subtitle: subtitle,
                leading: showBack && canPop
                    ? _BackButton(onTap: () => context.pop())
                    : (onMenu != null ? _MenuButton(onTap: onMenu!) : null),
                actions: actions,
              ),
              ?pinnedHeader,
              Expanded(child: Padding(padding: bodyPadding, child: body)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(leading == null ? Gap.gutter : 6, 10, 8, 8),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 2)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppType.screenTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      subtitle!,
                      style: AppType.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Go back',
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outlineSoft),
            ),
            child: const _BackIcon(),
          ),
        ),
      ),
    );
  }
}

class _BackIcon extends StatelessWidget {
  const _BackIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary);
  }
}

/// Opens the shell drawer; sits in the leading slot, left of the title.
class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
       semanticLabel: 'Open menu',
       child: SizedBox(
         width: 48,
         height: 48,
         child: Center(
           child: Container(
             width: 36,
             height: 36,
             decoration: BoxDecoration(
               color: AppColors.primary.withValues(alpha: 0.10),
               shape: BoxShape.circle,
               border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
             ),
             child: Icon(Icons.menu_rounded, size: 21, color: AppColors.primary),
           ),
         ),
       ),
    );
  }
}

/// Pinned bottom action area with the required safe-area padding, used for the
/// single dominant action of commitment screens.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child, this.note});

  final Widget child;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, 14, 18, MediaQuery.of(context).padding.bottom + 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outlineSoft)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note != null) ...[
            Text(note!, style: AppType.overline, textAlign: TextAlign.center),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }
}
