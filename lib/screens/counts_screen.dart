import 'package:flutter/material.dart';

class CountsScreen extends StatelessWidget {
  const CountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fact_check_outlined,
                  size: 44,
                  color: Color(0xFF1E3A5F),
                ),
                const SizedBox(height: 12),
                Text(
                  'No cycle counts yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_task),
                  label: const Text('New Cycle Count'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
