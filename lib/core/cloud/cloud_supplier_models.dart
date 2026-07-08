import '../models/supplier_models.dart';

class CloudSupplier {
  const CloudSupplier({
    required this.id,
    required this.workspaceId,
    required this.localSupplierId,
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
    required this.deletedAt,
  });

  final String id;
  final String workspaceId;
  final String localSupplierId;
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
  final DateTime? deletedAt;

  factory CloudSupplier.fromJson(Map<String, dynamic> json) {
    return CloudSupplier(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspace_id']?.toString() ?? '',
      localSupplierId: json['local_supplier_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      contactName: json['contact_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      website: json['website']?.toString(),
      address: json['address']?.toString(),
      accountNumber: json['account_number']?.toString(),
      notes: json['notes']?.toString(),
      defaultLeadTimeDays: _int(json['default_lead_time_days']),
      minimumOrderAmount: _double(json['minimum_order_amount']),
      isActive: json['is_active'] == true,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      deletedAt: _nullableDate(json['deleted_at']),
    );
  }

  factory CloudSupplier.fromLocalSupplier({
    required String workspaceId,
    required Supplier supplier,
    required bool includeCosts,
  }) {
    return CloudSupplier(
      id: '',
      workspaceId: workspaceId,
      localSupplierId: supplier.id,
      name: supplier.name,
      contactName: _emptyToNull(supplier.contactName),
      email: _emptyToNull(supplier.email),
      phone: _emptyToNull(supplier.phone),
      website: _emptyToNull(supplier.website),
      address: _emptyToNull(supplier.address),
      accountNumber: _emptyToNull(supplier.accountNumber),
      notes: _emptyToNull(supplier.notes),
      defaultLeadTimeDays: supplier.defaultLeadTimeDays,
      minimumOrderAmount: includeCosts ? supplier.minimumOrderAmount : null,
      isActive: supplier.isActive,
      createdAt: supplier.createdAt,
      updatedAt: supplier.updatedAt,
      deletedAt: supplier.isActive ? null : supplier.updatedAt,
    );
  }

  Map<String, Object?> toUpsertJson() {
    return {
      'workspace_id': workspaceId,
      'local_supplier_id': localSupplierId,
      'name': name,
      'contact_name': contactName,
      'email': email,
      'phone': phone,
      'website': website,
      'address': address,
      'account_number': accountNumber,
      'notes': notes,
      'default_lead_time_days': defaultLeadTimeDays,
      'minimum_order_amount': minimumOrderAmount,
      'is_active': isActive,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
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

double? _double(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

int? _int(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

String? _emptyToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
