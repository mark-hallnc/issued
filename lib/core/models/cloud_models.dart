enum CloudWorkspaceRole { owner, admin, manager, worker, viewOnly }

enum CloudWorkspaceMemberStatus { active, invited, disabled }

class CloudWorkspace {
  const CloudWorkspace({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? slug;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CloudWorkspace.fromJson(Map<String, dynamic> json) {
    return CloudWorkspace(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Workspace',
      slug: json['slug']?.toString(),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );
  }
}

class CloudWorkspaceMember {
  const CloudWorkspaceMember({
    required this.id,
    required this.workspaceId,
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workspaceId;
  final String userId;
  final String email;
  final String? displayName;
  final CloudWorkspaceRole role;
  final CloudWorkspaceMemberStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CloudWorkspaceMember.fromJson(Map<String, dynamic> json) {
    return CloudWorkspaceMember(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspace_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['display_name']?.toString(),
      role: cloudWorkspaceRoleFromString(json['role']?.toString()),
      status: cloudWorkspaceMemberStatusFromString(json['status']?.toString()),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );
  }
}

CloudWorkspaceRole cloudWorkspaceRoleFromString(String? value) {
  return CloudWorkspaceRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => CloudWorkspaceRole.worker,
  );
}

CloudWorkspaceMemberStatus cloudWorkspaceMemberStatusFromString(String? value) {
  return CloudWorkspaceMemberStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => CloudWorkspaceMemberStatus.disabled,
  );
}

String cloudWorkspaceRoleLabel(CloudWorkspaceRole role) {
  return switch (role) {
    CloudWorkspaceRole.owner => 'Owner',
    CloudWorkspaceRole.admin => 'Admin',
    CloudWorkspaceRole.manager => 'Manager',
    CloudWorkspaceRole.worker => 'Worker',
    CloudWorkspaceRole.viewOnly => 'View-only',
  };
}

DateTime _date(Object? value) {
  if (value is DateTime) {
    return value;
  }
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}
