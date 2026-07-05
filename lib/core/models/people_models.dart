enum UserRole { admin, manager, worker, viewOnly }

class Person {
  const Person({
    required this.id,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.isLoginUser,
  });

  final String id;
  final String displayName;
  final String? email;
  final String? phone;
  final bool isActive;
  final bool isLoginUser;

  Person copyWith({
    String? id,
    String? displayName,
    String? email,
    String? phone,
    bool? isActive,
    bool? isLoginUser,
  }) {
    return Person(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      isLoginUser: isLoginUser ?? this.isLoginUser,
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.personId,
    required this.email,
    required this.role,
    required this.isActive,
    required this.pinHash,
    required this.pinSalt,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
  });

  final String id;
  final String personId;
  final String email;
  final UserRole role;
  final bool isActive;
  final String? pinHash;
  final String? pinSalt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  AppUser copyWith({
    String? id,
    String? personId,
    String? email,
    UserRole? role,
    bool? isActive,
    String? pinHash,
    String? pinSalt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      pinHash: pinHash ?? this.pinHash,
      pinSalt: pinSalt ?? this.pinSalt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
