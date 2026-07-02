enum CustomFieldEntityType { item, location, person, transaction }

enum CustomFieldType { text, number, date, boolean, select }

class CustomFieldDefinition {
  const CustomFieldDefinition({
    required this.id,
    required this.entityType,
    required this.name,
    required this.fieldType,
    required this.isRequired,
    required this.options,
    required this.isActive,
  });

  final String id;
  final CustomFieldEntityType entityType;
  final String name;
  final CustomFieldType fieldType;
  final bool isRequired;
  final List<String> options;
  final bool isActive;

  CustomFieldDefinition copyWith({
    String? id,
    CustomFieldEntityType? entityType,
    String? name,
    CustomFieldType? fieldType,
    bool? isRequired,
    List<String>? options,
    bool? isActive,
  }) {
    return CustomFieldDefinition(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      isRequired: isRequired ?? this.isRequired,
      options: options ?? this.options,
      isActive: isActive ?? this.isActive,
    );
  }
}

class CustomFieldValue {
  const CustomFieldValue({
    required this.id,
    required this.definitionId,
    required this.entityId,
    required this.textValue,
    required this.numberValue,
    required this.dateValue,
    required this.booleanValue,
    required this.selectedOption,
  });

  final String id;
  final String definitionId;
  final String entityId;
  final String? textValue;
  final double? numberValue;
  final DateTime? dateValue;
  final bool? booleanValue;
  final String? selectedOption;

  CustomFieldValue copyWith({
    String? id,
    String? definitionId,
    String? entityId,
    String? textValue,
    double? numberValue,
    DateTime? dateValue,
    bool? booleanValue,
    String? selectedOption,
  }) {
    return CustomFieldValue(
      id: id ?? this.id,
      definitionId: definitionId ?? this.definitionId,
      entityId: entityId ?? this.entityId,
      textValue: textValue ?? this.textValue,
      numberValue: numberValue ?? this.numberValue,
      dateValue: dateValue ?? this.dateValue,
      booleanValue: booleanValue ?? this.booleanValue,
      selectedOption: selectedOption ?? this.selectedOption,
    );
  }
}
