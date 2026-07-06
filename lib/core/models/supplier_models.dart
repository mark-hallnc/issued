class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.accountNumber,
    required this.notes,
    required this.defaultLeadTimeDays,
    required this.minimumOrderAmount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? contactName;
  final String? email;
  final String? phone;
  final String? website;
  final String? address;
  final String? accountNumber;
  final String? notes;
  final int? defaultLeadTimeDays;
  final double? minimumOrderAmount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Supplier copyWith({
    String? id,
    String? name,
    String? contactName,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? accountNumber,
    String? notes,
    int? defaultLeadTimeDays,
    double? minimumOrderAmount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearContactName = false,
    bool clearEmail = false,
    bool clearPhone = false,
    bool clearWebsite = false,
    bool clearAddress = false,
    bool clearAccountNumber = false,
    bool clearNotes = false,
    bool clearDefaultLeadTimeDays = false,
    bool clearMinimumOrderAmount = false,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactName: clearContactName ? null : contactName ?? this.contactName,
      email: clearEmail ? null : email ?? this.email,
      phone: clearPhone ? null : phone ?? this.phone,
      website: clearWebsite ? null : website ?? this.website,
      address: clearAddress ? null : address ?? this.address,
      accountNumber: clearAccountNumber
          ? null
          : accountNumber ?? this.accountNumber,
      notes: clearNotes ? null : notes ?? this.notes,
      defaultLeadTimeDays: clearDefaultLeadTimeDays
          ? null
          : defaultLeadTimeDays ?? this.defaultLeadTimeDays,
      minimumOrderAmount: clearMinimumOrderAmount
          ? null
          : minimumOrderAmount ?? this.minimumOrderAmount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
