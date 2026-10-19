import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

import 'pressable.dart';

/// A grouped list surface: one border, one background, and hairline-separated
/// rows inside it.
///
/// This is the alternative to "one floating card per record". Rows share a
/// single surface so the eye reads them as a table of records, columns align
/// across rows, and the screen stops looking like a grid of identical boxes.
class SurfaceSection extends StatelessWidget {
  const SurfaceSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.padding = EdgeInsets.zero,
  });

  final List<Widget> children;

  /// Optional label rendered above the panel, outside the border.
  final Widget? header;
  final Widget? footer;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: Gap.gutter,
            endIndent: Gap.gutter,
            color: AppColors.outlineSoft,
          ),
        );
      }
      rows.add(children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[header!, const SizedBox(height: 8)],
        ClipRRect(
          borderRadius: AppRadii.rMd,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.outlineSoft),
              borderRadius: AppRadii.rMd,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: AppColors.isDark ? 0.12 : 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows,
              ),
            ),
          ),
        ),
        if (footer != null) ...[const SizedBox(height: 8), footer!],
      ],
    );
  }
}

/// A flat, tappable record row.
///
/// [title] and [subtitle] form the left column; [trailing] holds the value and
/// status and is aligned right so amounts line up down the whole list.
class SurfaceRow extends StatelessWidget {
  const SurfaceRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.dense = false,
    this.semanticLabel,
    this.semanticHint,
    this.showChevron = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Highlighted as part of the current multi-selection.
  final bool selected;
  final bool dense;
  final String? semanticLabel;
  final String? semanticHint;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    // The trailing column holds values and status notes; on a 320dp screen at
    // large text it must be capped or the row overflows instead of ellipsing.
    return LayoutBuilder(
      builder: (context, constraints) => _buildRow(
        context,
        maxTrailingWidth: constraints.maxWidth * 0.5,
      ),
    );
  }

  Widget _buildRow(BuildContext context, {required double maxTrailingWidth}) {
    final row = Container(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        Gap.gutter,
        dense ? 10 : 12,
        Gap.gutter,
        dense ? 10 : 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selected) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: AppColors.primary,
                semanticLabel: 'Selected',
              ),
            ),
            const SizedBox(width: 10),
          ],
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.subtitle,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.caption,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxTrailingWidth),
              child: trailing!,
            ),
          ],
          if (onTap != null && showChevron)
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 1),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );

    if (onTap == null && onLongPress == null) return row;
    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel ?? title,
      semanticHint: semanticHint,
      excludeChildSemantics: true,
      child: row,
    );
  }
}

/// A [SurfaceRow] that can open to reveal its own detail, so a user can
/// inspect a record without leaving the list they were reading.
///
/// The disclosure control is the row itself: one tap expands, and the row
/// stays exactly where it was. Height animates; nothing else on the list moves
/// position, and reduced-motion preferences get an instant change.
class ExpandableSurfaceRow extends StatefulWidget {
  const ExpandableSurfaceRow({
    super.key,
    required this.title,
    required this.detail,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onToggle,
    this.onLongPress,
    this.selected = false,
    this.semanticLabel,
    this.expandLabel = 'Show details',
    this.collapseLabel = 'Hide details',
    this.initiallyExpanded = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget detail;

  /// Notified after the row opens or closes.
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onLongPress;
  final bool selected;
  final String? semanticLabel;
  final String expandLabel;
  final String collapseLabel;
  final bool initiallyExpanded;

  @override
  State<ExpandableSurfaceRow> createState() => _ExpandableSurfaceRowState();
}

class _ExpandableSurfaceRowState extends State<ExpandableSurfaceRow> {
  late bool _open = widget.initiallyExpanded;

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _open = !_open);
    widget.onToggle?.call(_open);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final duration = reduced ? Duration.zero : AppMotion.scale(context, AppMotion.fast);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          expanded: _open,
          hint: _open ? widget.collapseLabel : widget.expandLabel,
          child: SurfaceRow(
            title: widget.title,
            subtitle: widget.subtitle,
            leading: widget.leading,
            selected: widget.selected,
            showChevron: false,
            onTap: _toggle,
            onLongPress: widget.onLongPress,
            semanticLabel: widget.semanticLabel,
            // Flexible, not loose: the value column must be able to shrink and
            // ellipsise inside the row's trailing budget, beside the chevron.
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.trailing != null) ...[
                  Flexible(child: widget.trailing!),
                  const SizedBox(width: 10),
                ],
                AnimatedRotation(
                  turns: _open ? 0.25 : 0,
                  duration: duration,
                  curve: AppMotion.emphasized,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: _open ? AppColors.primary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: duration,
          curve: AppMotion.emphasized,
          alignment: Alignment.topCenter,
          child: _open
              ? Container(
                  color: AppColors.surfaceAlt.withValues(alpha: 0.5),
                  padding: const EdgeInsets.fromLTRB(Gap.gutter, 12, Gap.gutter, 14),
                  child: widget.detail,
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Small right-aligned value + status column used by record rows, so money and
/// dates form a clean column down the list.
class RowValue extends StatelessWidget {
  const RowValue({super.key, required this.value, this.note, this.noteTone});

  /// Usually a `MoneyText` or a short date.
  final Widget value;
  final String? note;
  final Color? noteTone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        value,
        if (note != null) ...[
          const SizedBox(height: 2),
          Text(
            note!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.caption.copyWith(color: noteTone ?? AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
