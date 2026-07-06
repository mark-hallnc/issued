enum CloudWorkspaceRole { owner, admin, manager, worker, viewOnly }

enum CloudWorkspaceMemberStatus { active, invited, disabled }

enum CloudWorkspaceInviteStatus { pending, accepted, revoked, expired }

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

class CloudWorkspaceInvite {
  const CloudWorkspaceInvite({
    required this.id,
    required this.workspaceId,
    required this.email,
    required this.role,
    required this.status,
    required this.invitedBy,
    required this.invitedUserId,
    required this.createdAt,
    required this.acceptedAt,
    required this.expiresAt,
    required this.workspaceName,
  });

  final String id;
  final String workspaceId;
  final String email;
  final CloudWorkspaceRole role;
  final CloudWorkspaceInviteStatus status;
  final String? invitedBy;
  final String? invitedUserId;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? expiresAt;
  final String? workspaceName;

  factory CloudWorkspaceInvite.fromJson(Map<String, dynamic> json) {
    final workspace = json['workspaces'];
    return CloudWorkspaceInvite(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspace_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: cloudWorkspaceRoleFromString(json['role']?.toString()),
      status: cloudWorkspaceInviteStatusFromString(json['status']?.toString()),
      invitedBy: json['invited_by']?.toString(),
      invitedUserId: json['invited_user_id']?.toString(),
      createdAt: _date(json['created_at']),
      acceptedAt: _nullableDate(json['accepted_at']),
      expiresAt: _nullableDate(json['expires_at']),
      workspaceName: workspace is Map<String, dynamic>
          ? workspace['name']?.toString()
          : null,
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

CloudWorkspaceInviteStatus cloudWorkspaceInviteStatusFromString(String? value) {
  return CloudWorkspaceInviteStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => CloudWorkspaceInviteStatus.expired,
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

String cloudWorkspaceInviteStatusLabel(CloudWorkspaceInviteStatus status) {
  return switch (status) {
    CloudWorkspaceInviteStatus.pending => 'Pending',
    CloudWorkspaceInviteStatus.accepted => 'Accepted',
    CloudWorkspaceInviteStatus.revoked => 'Revoked',
    CloudWorkspaceInviteStatus.expired => 'Expired',
  };
}

DateTime _date(Object? value) {
  if (value is DateTime) {
    return value;
  }
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}

DateTime? _nullableDate(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.tryParse(value.toString());
}
