import 'package:flutter/material.dart';

import '../core/permissions/role_permission_descriptions.dart';

class RolesPermissionsScreen extends StatelessWidget {
  const RolesPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = buildRolePermissionDescriptions();

    return Scaffold(
      appBar: AppBar(title: const Text('Roles & Permissions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Roles control what each person can see and do in this organization.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          for (final role in roles) ...[
            _RoleCard(role: role),
            const SizedBox(height: 12),
          ],
          const _PlanNote(),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role});

  final RolePermissionDescription role;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role.roleLabel,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(role.summary),
            const SizedBox(height: 14),
            for (final category in RolePermissionCategory.ordered)
              _CategorySection(
                category: category,
                actions: role.actions
                    .where((action) => action.category == category)
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.actions});

  final String category;
  final List<RolePermissionActionDescription> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 6),
          for (final action in actions) _PermissionRow(action: action),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.action});

  final RolePermissionActionDescription action;

  @override
  Widget build(BuildContext context) {
    final color = action.allowed
        ? const Color(0xFF1F7A4D)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final icon = action.allowed ? Icons.check_circle : Icons.lock_outline;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: action.allowed ? null : color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  action.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: action.allowed ? null : color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanNote extends StatelessWidget {
  const _PlanNote();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Some actions may also depend on the current plan or app setup.',
        ),
      ),
    );
  }
}
