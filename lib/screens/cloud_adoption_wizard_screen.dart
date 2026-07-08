import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/cloud/cloud_adoption_models.dart';

class CloudAdoptionWizardScreen extends StatefulWidget {
  const CloudAdoptionWizardScreen({super.key});

  @override
  State<CloudAdoptionWizardScreen> createState() =>
      _CloudAdoptionWizardScreenState();
}

class _CloudAdoptionWizardScreenState extends State<CloudAdoptionWizardScreen> {
  bool _isBusy = false;
  bool _understandsMergeRisk = false;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final summary = store.cloudAdoptionSummary;
    return Scaffold(
      appBar: AppBar(title: const Text('Set up cloud sync')),
      body: summary == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _IntroCard(summary: summary),
                const SizedBox(height: 12),
                _DataSummaryCard(summary: summary),
                const SizedBox(height: 12),
                if (summary.state == CloudAdoptionState.blocked)
                  const _WarningCard(
                    message:
                        'Ask an admin or manager to set up this workspace first.',
                  )
                else ...[
                  if (summary.hasLocalBusinessData)
                    const _WarningCard(
                      message:
                          'This device has local inventory data. Choose carefully before uploading it to a shared workspace.',
                    ),
                  if (summary.hasCloudBusinessData)
                    const _WarningCard(
                      message:
                          'This workspace already has cloud data. Uploading this device may create duplicates if it came from a different source.',
                    ),
                  if (summary.hasLocalBusinessData &&
                      summary.hasCloudBusinessData)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _understandsMergeRisk,
                      onChanged: _isBusy
                          ? null
                          : (value) {
                              setState(() {
                                _understandsMergeRisk = value ?? false;
                              });
                            },
                      title: const Text(
                        'I understand this may merge local and cloud data.',
                      ),
                    ),
                  const SizedBox(height: 8),
                  _ChoiceCard(
                    icon: Icons.cloud_upload_outlined,
                    title: 'Upload this device\'s data',
                    description:
                        'Use the inventory currently on this device as the starting data for this workspace.',
                    enabled:
                        !_isBusy &&
                        (store.permissions.isAdmin ||
                            store.permissions.isManager) &&
                        (!summary.hasLocalBusinessData ||
                            !summary.hasCloudBusinessData ||
                            _understandsMergeRisk),
                    onTap: () =>
                        _complete(context, CloudAdoptionChoice.uploadLocalData),
                  ),
                  _ChoiceCard(
                    icon: Icons.add_business_outlined,
                    title: 'Start fresh in this workspace',
                    description:
                        'Do not upload this device\'s local inventory. Keep the workspace empty until you add or sync new data.',
                    enabled: !_isBusy,
                    onTap: () =>
                        _complete(context, CloudAdoptionChoice.startFreshCloud),
                  ),
                  _ChoiceCard(
                    icon: Icons.cloud_off_outlined,
                    title: 'Keep this device local-only for now',
                    description:
                        'Do not sync this device with the workspace yet. You can enable it later.',
                    enabled: !_isBusy,
                    onTap: () =>
                        _complete(context, CloudAdoptionChoice.keepLocalOnly),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isBusy
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text('Decide later'),
                ),
              ],
            ),
    );
  }

  Future<void> _complete(
    BuildContext context,
    CloudAdoptionChoice choice,
  ) async {
    final confirmed = await _confirmChoice(context, choice);
    if (confirmed != true || !context.mounted) {
      return;
    }
    setState(() => _isBusy = true);
    final store = AppStoreScope.of(context);
    final result = await store.completeCloudAdoption(choice);
    if (!context.mounted) {
      return;
    }
    setState(() => _isBusy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Cloud setup updated.')),
    );
    if (result.success) {
      Navigator.of(context).pop();
    }
  }
}

Future<bool?> _confirmChoice(BuildContext context, CloudAdoptionChoice choice) {
  final title = switch (choice) {
    CloudAdoptionChoice.uploadLocalData => 'Upload this device?',
    CloudAdoptionChoice.startFreshCloud => 'Start fresh?',
    CloudAdoptionChoice.keepLocalOnly => 'Keep local-only?',
    CloudAdoptionChoice.cancel => 'Cancel setup?',
  };
  final message = switch (choice) {
    CloudAdoptionChoice.uploadLocalData =>
      'This will upload local inventory from this device into the selected workspace. Continue only if this device should seed or merge workspace data.',
    CloudAdoptionChoice.startFreshCloud =>
      'Existing local inventory will stay on this device and will not be uploaded automatically. New changes after this setup decision can sync.',
    CloudAdoptionChoice.keepLocalOnly =>
      'This device will not sync inventory with the selected workspace until you enable cloud setup later.',
    CloudAdoptionChoice.cancel =>
      'You can return to cloud setup from Settings later.',
  };
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.summary});

  final CloudAdoptionSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.workspaceName ?? 'Selected workspace',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(summary.message),
          ],
        ),
      ),
    );
  }
}

class _DataSummaryCard extends StatelessWidget {
  const _DataSummaryCard({required this.summary});

  final CloudAdoptionSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data summary',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _CountLine(
              label: 'Local items',
              value: summary.localItemCount,
              cloudValue: summary.cloudItemCount,
            ),
            _CountLine(
              label: 'Balances',
              value: summary.localBalanceCount,
              cloudValue: summary.cloudBalanceCount,
            ),
            _CountLine(
              label: 'Transactions',
              value: summary.localTransactionCount,
              cloudValue: summary.cloudTransactionCount,
            ),
            _CountLine(
              label: 'Checkouts',
              value: summary.localCheckoutCount,
              cloudValue: summary.cloudCheckoutCount,
            ),
            _CountLine(
              label: 'Suppliers',
              value: summary.localSupplierCount,
              cloudValue: summary.cloudSupplierCount,
            ),
            _CountLine(
              label: 'Purchasing',
              value: summary.localPurchasingCount,
              cloudValue: summary.cloudPurchasingCount,
            ),
            _CountLine(
              label: 'Cycle counts',
              value: summary.localCycleCountCount,
              cloudValue: summary.cloudCycleCountCount,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountLine extends StatelessWidget {
  const _CountLine({
    required this.label,
    required this.value,
    required this.cloudValue,
  });

  final String label;
  final int value;
  final int cloudValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            'Local $value  Cloud $cloudValue',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF7E6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_outlined),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        enabled: enabled,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
