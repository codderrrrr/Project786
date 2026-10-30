import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';
import 'package:subscription_saas_flutter/core/widgets/glass_card.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';

/// Business profile screen showing business details.
/// Features per review guidelines:
/// - Business username
/// - Business name
/// - Owner name
/// - Location select from a dropdown of Pakistan cities
/// - Email (optional)
class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  // Controllers
  final _usernameController = TextEditingController(text: 'demo_business');
  final _nameController = TextEditingController(text: 'Demo Business');
  final _ownerController = TextEditingController(text: 'Business Owner');
  final _emailController = TextEditingController(text: '');

  // Form state
  bool _isSaving = false;

  // Pakistan cities dropdown options
  final List<String> _pakistanCities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Peshawar',
    'Quetta',
    'Faisalabad',
    'Multan',
    'Sukkur',
    'Sialkot',
    'Gujranwala',
    'Bahawalpur',
    'Hyderabad',
    'Larkana',
    'Mardan',
    'Abbottabad',
  ];

  // Selected city from dropdown
  String? _selectedCity;

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _ownerController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
    showAppSnack(context, message: 'Business profile saved.');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Business profile',
      subtitle: 'Shown on receipts and reminders',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SectionHeader(title: 'Identity'),

          // Identity fields live in one panel: they are one subject, and four
          // floating boxes for four lines of a form read as clutter.
          GlassCard(
            child: Column(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.account_circle_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Business name',
                    prefixIcon: Icon(Icons.storefront_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _ownerController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Owner name',
                    prefixIcon: Icon(Icons.person_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Contact'),

          // Location + email: pickers stay tappable rows; optional email
          // labelled once (the ListTile header duplicated the field label).
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Location'),
                  subtitle: Text(
                    _selectedCity ?? 'Select a city from the list',
                  ),
                  trailing: const Icon(Icons.arrow_drop_down, size: 28),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Select location'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: _pakistanCities
                                .map(
                                  (city) => ListTile(
                                    title: Text(city),
                                    selected: _selectedCity == city,
                                    onTap: () {
                                      setState(() => _selectedCity = city);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'email@business.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 4),
                Text(
                  'Used on receipts and reminders when provided.',
                  style: AppType.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Save button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 24),
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save changes'),
            ),
          ),
        ],
      ),
    );
  }
}
