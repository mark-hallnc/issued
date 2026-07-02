import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Scan Item'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Barcode and QR scanning will be added later. For now, use these actions as placeholders for item movement workflows.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5C6672),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _ScanAction(label: 'Issue', icon: Icons.call_made),
            _ScanAction(label: 'Return', icon: Icons.call_received),
            _ScanAction(label: 'Receive', icon: Icons.add_box_outlined),
            _ScanAction(label: 'Transfer', icon: Icons.swap_horiz),
          ],
        ),
      ],
    );
  }
}

class _ScanAction extends StatelessWidget {
  const _ScanAction({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
