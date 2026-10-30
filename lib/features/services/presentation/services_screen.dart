import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';
import 'package:subscription_saas_flutter/core/widgets/filter_bar.dart';
import 'package:subscription_saas_flutter/core/widgets/search_field.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';
import 'package:subscription_saas_flutter/core/components/surface_card.dart';
import 'package:subscription_saas_flutter/features/services/data/providers/services_providers.dart';
import 'package:subscription_saas_flutter/features/services/domain/models/service.dart';

/// Services screen showing all services with search and filter options.
/// - Search bar at top to search services by name
/// - Services listed in alphabetical order by name
/// - Filters on top: Activated, Deactivated, and ALL
/// - Floating action button in bottom right to add new service
/// - Clicking a service opens detailed screen where users can edit the service
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _query = '';
  String _filter = 'all'; // 'all', 'active', 'inactive'

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicesListProvider);

    return AppScaffold(
      title: 'Services',
      subtitle: 'What you sell and what it costs',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddServiceScreen(context, ref),
        tooltip: 'Add service',
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
      bodyPadding: EdgeInsets.zero,
      body: services.when(
        data: (page) {
          final items = page.items;

          // Apply search filter
          final filtered = _query.isNotEmpty
              ? items
                    .where(
                      (s) =>
                          s.name.toLowerCase().contains(_query.toLowerCase()),
                    )
                    .toList()
              : items;

          // Apply filter selection
          final filteredByStatus = _filter == 'all'
              ? filtered
              : filtered
                    .where((s) => s.active == (_filter == 'active'))
                    .toList();

          // Sort alphabetically by name
          final sorted = List.of(filteredByStatus)
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );

          if (sorted.isEmpty) {
            return EmptyView(
              title: _query.isNotEmpty ? 'No matches' : 'No services yet',
              message: _query.isNotEmpty
                  ? 'Nothing matched “$_query”. Check the spelling or clear the search.'
                  : 'Add the services you sell, then attach them to subscribers as subscriptions.',
              icon: Icons.inventory_2_rounded,
              actionLabel: _query.isNotEmpty ? 'Clear search' : 'Add service',
              onAction: _query.isNotEmpty
                  ? () => setState(() => _query = '')
                  : () => _openAddServiceScreen(context, ref),
            );
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Gap.gutter,
                  Gap.gutter,
                  Gap.gutter,
                  8,
                ),
                child: SurfaceCard(
                  padding: const EdgeInsets.all(8),

                  child: AppSearchField(
                    hintText: 'Search services by name',
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),

              // Filter bar with Activated, Deactivated, ALL
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Gap.gutter,
                  0,
                  Gap.gutter,
                  4,
                ),
                child: SurfaceCard(
                  padding: const EdgeInsets.all(8),

                  child: FilterBar(
                    selectedId: _filter,
                    semanticLabel: 'Filter services by status',
                    onSelected: (id) => setState(() => _filter = id),
                    onReset: () => setState(() => _filter = 'all'),
                    summary: Text(
                      '${sorted.length} ${sorted.length == 1 ? 'service' : 'services'}',
                    ),
                    options: [
                      FilterOption(
                        id: 'all',
                        label: 'All',
                        count: items.length,
                      ),
                      FilterOption(
                        id: 'active',
                        label: 'Activated',
                        count: items.where((s) => s.active).length,
                      ),
                      FilterOption(
                        id: 'inactive',
                        label: 'Deactivated',
                        count: items.where((s) => !s.active).length,
                      ),
                    ],
                  ),
                ),
              ),

              // Services list
              Expanded(
                child: ListView(
                  padding: Gap.pageInset,
                  children: [
                    for (var i = 0; i < sorted.length; i++)
                      _ServiceRow(service: sorted[i]),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingView(rows: 4),
        error: (e, _) => ErrorView(
          message: 'We could not load your services. Check your connection and try again.',
          onRetry: () => ref.invalidate(servicesListProvider),
        ),
      ),
    );
  }
}

/// A row displaying a service with tap to edit and long press to toggle status.
class _ServiceRow extends ConsumerWidget {
  const _ServiceRow({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SurfaceRow(
      title: service.name,
      subtitle:
          '${service.billingPeriod}${service.description.isEmpty ? '' : ' · ${service.description}'}',
      showChevron: true,
      onTap: () => context.push('/services/${service.id}'),
      onLongPress: () => _toggleActive(context, ref),
      semanticLabel:
          '${service.name}, ${service.billingPeriod}, ${service.active ? 'active' : 'inactive'}',
      semanticHint:
          '${service.active ? 'deactivate' : 'activate'} this service',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              service.active ? 'Active' : 'Inactive',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.label.copyWith(
                color: service.active
                    ? AppColors.success
                    : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref) async {
    final newActive = !service.active;
    await ref
        .read(servicesRepositoryProvider)
        .setServiceActive(service.id, newActive);
    ref.invalidate(servicesListProvider);
    if (context.mounted) {
      showAppSnack(
        context,
        message: service.active
            ? '${service.name} deactivated.'
            : '${service.name} reactivated.',
      );
    }
  }
}

/// Opens a new screen for adding/editing a service.
/// Merges the add new service and services details screen per review guidelines.
Future<Service?> _openAddServiceScreen(
  BuildContext context,
  WidgetRef ref,
) async {
  // Navigate to a new screen for adding/editing a service
  final result = await Navigator.of(context).push<Service>(
    MaterialPageRoute(builder: (context) => const _ServiceForm()),
  );
  return result;
}

/// Service form screen for adding or editing a service.
/// Combines add new service and edit service details into one screen.
class _ServiceForm extends ConsumerStatefulWidget {
  const _ServiceForm();

  @override
  ConsumerState<_ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends ConsumerState<_ServiceForm> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _billingPeriodController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Available billing periods per review: Daily, Weekly, 15 days, Monthly, 3 months, 6 months, 12 months
  static const _billingPeriods = [
    'daily',
    'weekly',
    'fifteen_days',
    'monthly',
    'three_months',
    'six_months',
    'yearly',
  ];

  String? _selectedBillingPeriod;
  final bool _isEditing = false;
  String? _existingServiceId;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _billingPeriodController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Check if we are navigating from a service detail screen (editing mode)
    // This would be set by the router if needed, but for now we default to add mode
    _selectedBillingPeriod = _billingPeriods.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isEditing
            ? const Text('Edit Service')
            : const Text('Add Service'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newService = Service(
                  id:
                      _existingServiceId ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text.trim(),
                  price:
                      Decimal.tryParse(_priceController.text.trim()) ??
                      Decimal.zero,
                  billingPeriod: _selectedBillingPeriod ?? 'monthly',
                  description: _descriptionController.text.trim(),
                  active: true,
                );
                Navigator.of(context).pop(newService);
              }
            },
            child: Text(_isEditing ? 'Update' : 'Add'),
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
                SurfaceCard(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter service name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Service name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Price field
                Text(
                  'Price*',
                  style: AppType.label.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                SurfaceCard(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Price is required';
                      }
                      final price = Decimal.tryParse(value.trim());
                      if (price == null || price <= Decimal.zero) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Billing period dropdown
                Text(
                  'Billing period*',
                  style: AppType.label.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                SurfaceCard(
                  padding: const EdgeInsets.all(8),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedBillingPeriod,
                    hint: const Text('Select billing period'),
                    items: _billingPeriods
                        .map(
                          (period) => DropdownMenuItem<String>(
                            value: period,
                            child: Text(period.replaceAll('_', ' ')),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() => _selectedBillingPeriod = newValue);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Billing period is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Description (optional)
                Text(
                  'Description',
                  style: AppType.label.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                SurfaceCard(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Optional description of the service',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
