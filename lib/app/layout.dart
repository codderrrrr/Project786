import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_radii.dart';

/// Viewport decisions, kept in one place so every screen breaks at the same
/// points instead of each choosing its own.
///
/// * **compact** (< 600) — phones. One column, docked bottom bar.
/// * **medium** (600–899) — large phones and small tablets. One column, but
///   lists may show an extra column of data.
/// * **wide** (≥ 900) — tablets and desktop. Navigation rail, and screens that
///   benefit from it split into a primary column and a supporting column.
class Breakpoints {
  Breakpoints._();

  static const double medium = 600;
  static const double wide = 900;

  static bool isMedium(double width) => width >= medium;
  static bool isWide(double width) => width >= wide;
}

/// Resolves the current breakpoint once per build.
class Layout {
  const Layout._(this.size, this.medium, this.wide);

  factory Layout.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Layout._(size, Breakpoints.isMedium(size.width), Breakpoints.isWide(size.width));
  }

  final Size size;
  final bool medium;
  final bool wide;

  /// Column width that keeps prose and forms readable on a wide display.
  double get readableWidth => wide ? 640 : size.width;

  /// Width available to a list once the navigation rail is showing.
  double get contentWidth => wide ? size.width - 116 : size.width;
}

/// Centres content in a readable column on wide displays and stays full-bleed
/// on phones. Padding is the same 16dp gutter used everywhere else.
class ContentColumn extends StatelessWidget {
  const ContentColumn({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final layout = Layout.of(context);
    final resolved = padding ?? Gap.pageInset;
    if (!layout.wide) return Padding(padding: resolved, child: child);
    return Padding(
      padding: resolved,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Two columns on wide displays, stacked on phones.
///
/// [primary] is the thing the screen is about and keeps its natural width;
/// [supporting] holds quieter material beside it.
class SplitColumns extends StatelessWidget {
  const SplitColumns({
    super.key,
    required this.primary,
    required this.supporting,
    this.primaryFlex = 3,
    this.supportingFlex = 2,
    this.gap = 24,
  });

  final Widget primary;
  final Widget supporting;
  final int primaryFlex;
  final int supportingFlex;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final layout = Layout.of(context);
    if (!layout.wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          SizedBox(height: gap),
          supporting,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: primaryFlex, child: primary),
        SizedBox(width: gap),
        Expanded(flex: supportingFlex, child: supporting),
      ],
    );
  }
}
