import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/widgets/animated_reveal.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';
import 'package:subscription_saas_flutter/core/widgets/filter_bar.dart';
import 'package:subscription_saas_flutter/core/widgets/initials_avatar.dart';
import 'package:subscription_saas_flutter/core/widgets/search_field.dart';
import 'package:subscription_saas_flutter/core/widgets/creative/section_header_artistic.dart';
import 'package:subscription_saas_flutter/core/widgets/creative/aurora_card.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/widgets/status_pill.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/providers/subscribers_providers.dart';
import 'package:subscription_saas_flutter/features/subscribers/domain/models/subscriber.dart';
import 'package:subscription_saas_flutter/features/services/data/providers/services_providers.dart';

/// Slim alphabetical fast-scroll index overlaying the right edge of the
/// subscriber list, like the contacts app: drag or tap a letter to jump to
/// subscribers whose names start with it.
///
/// The letters share the available height evenly (Expanded per letter), so the
/// bar can never overflow regardless of screen height or text scale.
class _AlphabetIndex extends StatelessWidget {
  const _AlphabetIndex({required this.onSelect, this.onDragEnd});

  static const String _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  final ValueChanged<String> onSelect;

  /// Called when the user lifts their finger so the caller can hide the
  /// letter bubble.
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final letterHeight = constraints.maxHeight / _letters.length;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) {
            final index = (details.localPosition.dy / letterHeight)
                .floor()
                .clamp(0, _letters.length - 1)
                .toInt();
            onSelect(_letters[index]);
          },
          onVerticalDragEnd: (_) => onDragEnd?.call(),
          child: Container(
            width: 24,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.92),
              borderRadius: AppRadii.rSm,
              border: Border.all(color: AppColors.outlineSoft),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _letters.length; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        _letters[i],
                        style: AppType.caption.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A row displaying a subscriber with swipe actions removed per review guidelines.
/// Uses InitialsAvatar and StatusPill, no caller buttons.
class _SubscriberRow extends ConsumerWidget {
  const _SubscriberRow({required this.subscriber, this.rowKey});

  final Subscriber subscriber;

  /// Anchor key used by the alphabet index to scroll this row into view.
  final Key? rowKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = subscriber;
    return SurfaceRow(
      key: rowKey,
      title: s.name,
      subtitle: s.phone,
      showChevron: false,
      onTap: () => context.push('/subscribers/${s.id}'),
      onLongPress: () => _showQuickActions(context, ref, s),
      semanticLabel:
          '${s.name}, ${s.active ? 'active' : 'inactive'}, ${s.phone}',
      semanticHint: 'Double tap for details, long press for quick actions',
      leading: Hero(
        tag: 'subscriber-avatar-${s.id}',
        child: InitialsAvatar(name: s.name, dimmed: !s.active),
      ),
      trailing: StatusPill.fromStatus(
        s.active ? 'active' : 'inactive',
        compact: true,
      ),
    );
  }
}

/// Shows quick actions sheet for a subscriber (long press).
void _showQuickActions(BuildContext context, WidgetRef ref, Subscriber subscriber) {
  showAppSheet<void>(
    context,
    title: subscriber.name,
    subtitle: 'Quick actions',
    maxHeightFactor: 0.5,
    builder: (context) => ListView(
      padding: const EdgeInsets.fromLTRB(Gap.gutter, 4, Gap.gutter, 24),
      shrinkWrap: true,
      children: [
        SurfaceSection(
          children: [
            SurfaceRow(
              title: 'Collect a payment',
              subtitle: 'Settle what this subscriber owes',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/payments/review?subscriberId=${subscriber.id}');
              },
            ),
            SurfaceRow(
              title: 'View subscriptions',
              subtitle: 'Their services, amounts and dates',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/subscribers/${subscriber.id}');
              },
            ),
            SurfaceRow(
              title: subscriber.active
                  ? 'Deactivate subscriber'
                  : 'Reactivate subscriber',
              subtitle: subscriber.active
                  ? 'Keeps their history, stops new billing'
                  : 'Resumes billing from the next due date',
              onTap: () async {
                Navigator.of(context).pop();
                if (subscriber.active) {
                  final ok = await showConfirmDialog(
                    context,
                    title: 'Deactivate ${subscriber.name}?',
                    message:
                        'They stay in your records and their history is kept.',
                    consequence:
                        'Existing subscriptions keep running — deactivating does not cancel them or delete payments.',
                    confirmLabel: 'Deactivate',
                    destructive: true,
                  );
                  if (!ok) return;
                }
                await ref
                    .read(subscribersRepositoryProvider)
                    .setSubscriberActive(subscriber.id, !subscriber.active);
                ref.invalidate(subscribersListProvider);
                ref.invalidate(subscriberDetailProvider(subscriber.id));
                if (context.mounted) {
                  showAppSnack(
                    context,
                    message: subscriber.active
                        ? '${subscriber.name} deactivated.'
                        : '${subscriber.name} reactivated.',
                  );
                }
              },
            ),
          ],
        ),
      ],
    ),
  );
}

/// Subscriber form sheet for adding a new subscriber.
/// Opens a new screen (not a sheet), asking for name, phone, optional CNIC, and service.
Future<Subscriber?> _openAddSubscriberScreen(
  BuildContext context,
  WidgetRef ref,
) async {
  // Navigate to a new screen instead of using a bottom sheet
  final result = await Navigator.of(context).push<Subscriber>(
    MaterialPageRoute(
      builder: (context) => const _AddSubscriberForm(),
    ),
  );
  return result;
}

/// Add subscriber screen with name, phone, optional CNIC, and service dropdown.
class _AddSubscriberForm extends ConsumerStatefulWidget {
  const _AddSubscriberForm();

  @override
  ConsumerState<_AddSubscriberForm> createState() => _AddSubscriberFormState();
}

class _AddSubscriberFormState extends ConsumerState<_AddSubscriberForm> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  String? _selectedService;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subscriber'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newSubscriber = Subscriber(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text.trim(),
                  phone: _phoneController.text.trim(),
                  cnic: _cnicController.text.trim(),
                  active: true,
                  createdAt: DateTime.now().toIso8601String().split('T').first,
                );
                Navigator.of(context).pop(newSubscriber);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Gap.gutter,
            Gap.gutter,
            Gap.gutter,
            MediaQuery.viewInsetsOf(context).bottom + 32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              Text(
                'Name*',
                style: AppType.label.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              AuroraCard(
                padding: const EdgeInsets.all(8),
                glow: true,
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter subscriber name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Phone field
              Text(
                'Phone*',
                style: AppType.label.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              AuroraCard(
                padding: const EdgeInsets.all(8),
                glow: true,
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    hintText: '+923001234567',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone is required';
                    }
                    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
                    if (!RegExp(r'^\+92\d{10}$').hasMatch(cleaned)) {
                      return 'Use Pakistan format: +921234567890';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // CNIC (optional)
              Text(
                'CNIC (optional)',
                style: AppType.label.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              AuroraCard(
                padding: const EdgeInsets.all(8),
                glow: true,
                child: TextFormField(
                  controller: _cnicController,
                  decoration: const InputDecoration(
                    hintText: 'Enter CNIC (optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    final cnic = value?.replaceAll(RegExp(r'[-\s]'), '') ?? '';
                    if (cnic.isNotEmpty && !RegExp(r'^\d{13}$').hasMatch(cnic)) {
                      return 'Enter 13 digits or leave CNIC empty';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Service dropdown
              Text(
                'Service*',
                style: AppType.label.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              AuroraCard(
                padding: const EdgeInsets.all(8),
                glow: true,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedService,
                  hint: const Text('Select a service'),
                  items: services.when(
                    data: (list) => list.items
                        .map(
                          (service) => DropdownMenuItem<String>(
                            value: service.id,
                            child: Text(service.name),
                          ),
                        )
                        .toList(),
                    loading: () => const [],
                    error: (_, _) => const [],
                  ),
                  onChanged: (String? newValue) {
                    setState(() => _selectedService = newValue);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Service is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Main Subscribers Screen widget.
/// Features per review guidelines:
/// - Search bar for name/phone
/// - Alphabet index on right side for fast navigation
/// - FAB to add new subscriber
/// - Subscribers arranged alphabetically
/// - No email displayed in detail screen
/// - No caller buttons in detail screen/swipe actions
class SubscribersScreen extends ConsumerStatefulWidget {
  const SubscribersScreen({super.key});

  @override
  ConsumerState<SubscribersScreen> createState() => _SubscribersScreenState();
}

class _SubscribersScreenState extends ConsumerState<SubscribersScreen> {
  String _query = '';
  String _filter = 'all';

  final ScrollController _listController = ScrollController();

  /// Row keys so the alphabet index can scroll a letter's first row into view.
  final Map<String, GlobalKey> _rowKeys = {};

  /// Letter currently shown in the overlay bubble while the index is used.
  String? _visibleLetter;

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  void _jumpToLetter(String letter) {
    setState(() => _visibleLetter = letter);
    // Find the first visible row whose name starts with this letter and
    // scroll it into view.
    final subs = ref.read(subscribersListProvider(_query.isEmpty ? null : _query));
    subs.whenData((page) {
      final match = page.items.where((s) {
        final passesFilter = switch (_filter) {
          'active' => s.active,
          'inactive' => !s.active,
          _ => true,
        };
        return passesFilter &&
            s.name.trimLeft().toUpperCase().startsWith(letter);
      }).firstOrNull;
      final rowContext =
          match == null ? null : _rowKeys[match.id]?.currentContext;
      if (rowContext != null) {
        Scrollable.ensureVisible(
          rowContext,
          duration: const Duration(milliseconds: 220),
          curve: AppMotion.emphasized,
          alignment: 0.1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subs = ref.watch(
      subscribersListProvider(_query.isEmpty ? null : _query),
    );

    return AppScaffold(
      title: 'Subscribers',
      subtitle: 'People you bill',
      showBack: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSubscriberScreen(context, ref),
        tooltip: 'Add subscriber',
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Add'),
      ),
      bodyPadding: EdgeInsets.zero,
      pinnedHeader: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.gutter, 0, Gap.gutter, 12),
            child: AuroraCard(
              padding: const EdgeInsets.all(8),
              glow: true,
              child: AppSearchField(
                hintText: 'Search name or phone number',
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          subs.maybeWhen(
            data: (page) {
              final active = page.items.where((s) => s.active).length;
              final inactive = page.items.length - active;
              return Padding(
                padding: const EdgeInsets.fromLTRB(Gap.gutter, 0, Gap.gutter, 12),
                child: AuroraCard(
                  padding: const EdgeInsets.all(8),
                  glow: true,
                  child: FilterBar(
                    selectedId: _filter,
                    semanticLabel: 'Filter subscribers by status',
                    onSelected: (id) => setState(() => _filter = id),
                    onReset: () => setState(() => _filter = 'all'),
                    summary: Text(
                      '${page.items.length} ${page.items.length == 1 ? 'person' : 'people'}',
                    ),
                    options: [
                      FilterOption(id: 'all', label: 'All', count: page.items.length),
                      FilterOption(id: 'active', label: 'Active', count: active),
                      FilterOption(id: 'inactive', label: 'Inactive', count: inactive),
                    ],
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: subs.when(
        data: (page) {
          final items = page.items.where((s) {
            switch (_filter) {
              case 'active':
                return s.active;
              case 'inactive':
                return !s.active;
              default:
                return true;
            }
          }).toList();

          if (items.isEmpty) {
            return EmptyView(
              title: _query.isNotEmpty ? 'No matches' : 'No subscribers yet',
              message: _query.isNotEmpty
                  ? 'Nothing matched “$_query”. Check the spelling or clear the search.'
                  : 'Add your first subscriber to start billing.',
              icon: Icons.people_alt_rounded,
              actionLabel: _query.isNotEmpty
                  ? 'Clear search'
                  : 'Add subscriber',
              onAction: _query.isNotEmpty
                  ? () => setState(() => _query = '')
                  : () => _openAddSubscriberScreen(context, ref),
            );
          }

          return Stack(
            children: [
              ListView(
                controller: _listController,
                padding: EdgeInsets.fromLTRB(
                  Gap.gutter,
                  8,
                  Gap.gutter + 44,
                  Gap.pageInset.bottom,
                ),
                children: [
                  SectionHeaderArtistic(
                    title: 'Subscribers',
                    subtitle: 'Long-press a row for quick actions',
                  ),
                  SurfaceSection(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        AnimatedReveal(
                          index: i,
                          child: _SubscriberRow(
                            subscriber: items[i],
                            rowKey: _rowKeys.putIfAbsent(
                              items[i].id,
                              () => GlobalKey(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // Slim fast-scroll index down the right edge, contacts-style.
              Positioned(
                right: 8,
                top: 12,
                bottom: Gap.pageInset.bottom + 20,
                child: _AlphabetIndex(
                  onSelect: _jumpToLetter,
                  onDragEnd: () {
                    if (mounted) setState(() => _visibleLetter = null);
                  },
                ),
              ),
              // Letter bubble shown while scrubbing the index.
              if (_visibleLetter != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          _visibleLetter!,
                          style: AppType.title.copyWith(
                            color: AppColors.onAccent,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => LoadingView(rows: 6),
        error: (e, _) => ErrorView(
          message: 'We could not load your subscribers. Check your connection and try again.',
          onRetry: () => ref.invalidate(subscribersListProvider),
        ),
      ),
    );
  }
}
