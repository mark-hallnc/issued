// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityOnHandMeta = const VerificationMeta(
    'quantityOnHand',
  );
  @override
  late final GeneratedColumn<double> quantityOnHand = GeneratedColumn<double>(
    'quantity_on_hand',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minimumQuantityMeta = const VerificationMeta(
    'minimumQuantity',
  );
  @override
  late final GeneratedColumn<double> minimumQuantity = GeneratedColumn<double>(
    'minimum_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitOfMeasureIdMeta = const VerificationMeta(
    'unitOfMeasureId',
  );
  @override
  late final GeneratedColumn<String> unitOfMeasureId = GeneratedColumn<String>(
    'unit_of_measure_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseUnitOfMeasureIdMeta =
      const VerificationMeta('purchaseUnitOfMeasureId');
  @override
  late final GeneratedColumn<String> purchaseUnitOfMeasureId =
      GeneratedColumn<String>(
        'purchase_unit_of_measure_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _purchaseToStockConversionFactorMeta =
      const VerificationMeta('purchaseToStockConversionFactor');
  @override
  late final GeneratedColumn<double> purchaseToStockConversionFactor =
      GeneratedColumn<double>(
        'purchase_to_stock_conversion_factor',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _purchaseUnitLabelMeta = const VerificationMeta(
    'purchaseUnitLabel',
  );
  @override
  late final GeneratedColumn<String> purchaseUnitLabel =
      GeneratedColumn<String>(
        'purchase_unit_label',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierMeta = const VerificationMeta(
    'supplier',
  );
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
    'supplier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
    'unit_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _allowFractionalQuantityMeta =
      const VerificationMeta('allowFractionalQuantity');
  @override
  late final GeneratedColumn<bool> allowFractionalQuantity =
      GeneratedColumn<bool>(
        'allow_fractional_quantity',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allow_fractional_quantity" IN (0, 1))',
        ),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    itemType,
    category,
    locationId,
    quantityOnHand,
    minimumQuantity,
    unitOfMeasureId,
    purchaseUnitOfMeasureId,
    purchaseToStockConversionFactor,
    purchaseUnitLabel,
    barcode,
    sku,
    supplierId,
    supplier,
    unitCost,
    photoPath,
    isActive,
    allowFractionalQuantity,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    if (data.containsKey('quantity_on_hand')) {
      context.handle(
        _quantityOnHandMeta,
        quantityOnHand.isAcceptableOrUnknown(
          data['quantity_on_hand']!,
          _quantityOnHandMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityOnHandMeta);
    }
    if (data.containsKey('minimum_quantity')) {
      context.handle(
        _minimumQuantityMeta,
        minimumQuantity.isAcceptableOrUnknown(
          data['minimum_quantity']!,
          _minimumQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minimumQuantityMeta);
    }
    if (data.containsKey('unit_of_measure_id')) {
      context.handle(
        _unitOfMeasureIdMeta,
        unitOfMeasureId.isAcceptableOrUnknown(
          data['unit_of_measure_id']!,
          _unitOfMeasureIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitOfMeasureIdMeta);
    }
    if (data.containsKey('purchase_unit_of_measure_id')) {
      context.handle(
        _purchaseUnitOfMeasureIdMeta,
        purchaseUnitOfMeasureId.isAcceptableOrUnknown(
          data['purchase_unit_of_measure_id']!,
          _purchaseUnitOfMeasureIdMeta,
        ),
      );
    }
    if (data.containsKey('purchase_to_stock_conversion_factor')) {
      context.handle(
        _purchaseToStockConversionFactorMeta,
        purchaseToStockConversionFactor.isAcceptableOrUnknown(
          data['purchase_to_stock_conversion_factor']!,
          _purchaseToStockConversionFactorMeta,
        ),
      );
    }
    if (data.containsKey('purchase_unit_label')) {
      context.handle(
        _purchaseUnitLabelMeta,
        purchaseUnitLabel.isAcceptableOrUnknown(
          data['purchase_unit_label']!,
          _purchaseUnitLabelMeta,
        ),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('supplier')) {
      context.handle(
        _supplierMeta,
        supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta),
      );
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('allow_fractional_quantity')) {
      context.handle(
        _allowFractionalQuantityMeta,
        allowFractionalQuantity.isAcceptableOrUnknown(
          data['allow_fractional_quantity']!,
          _allowFractionalQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowFractionalQuantityMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      )!,
      quantityOnHand: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_on_hand'],
      )!,
      minimumQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}minimum_quantity'],
      )!,
      unitOfMeasureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_of_measure_id'],
      )!,
      purchaseUnitOfMeasureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_unit_of_measure_id'],
      ),
      purchaseToStockConversionFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_to_stock_conversion_factor'],
      ),
      purchaseUnitLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_unit_label'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      supplier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier'],
      ),
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_cost'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      allowFractionalQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_fractional_quantity'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class ItemRecord extends DataClass implements Insertable<ItemRecord> {
  final String id;
  final String name;
  final String description;
  final String itemType;
  final String category;
  final String locationId;
  final double quantityOnHand;
  final double minimumQuantity;
  final String unitOfMeasureId;
  final String? purchaseUnitOfMeasureId;
  final double? purchaseToStockConversionFactor;
  final String? purchaseUnitLabel;
  final String? barcode;
  final String? sku;
  final String? supplierId;
  final String? supplier;
  final double? unitCost;
  final String? photoPath;
  final bool isActive;
  final bool allowFractionalQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ItemRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.itemType,
    required this.category,
    required this.locationId,
    required this.quantityOnHand,
    required this.minimumQuantity,
    required this.unitOfMeasureId,
    this.purchaseUnitOfMeasureId,
    this.purchaseToStockConversionFactor,
    this.purchaseUnitLabel,
    this.barcode,
    this.sku,
    this.supplierId,
    this.supplier,
    this.unitCost,
    this.photoPath,
    required this.isActive,
    required this.allowFractionalQuantity,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['item_type'] = Variable<String>(itemType);
    map['category'] = Variable<String>(category);
    map['location_id'] = Variable<String>(locationId);
    map['quantity_on_hand'] = Variable<double>(quantityOnHand);
    map['minimum_quantity'] = Variable<double>(minimumQuantity);
    map['unit_of_measure_id'] = Variable<String>(unitOfMeasureId);
    if (!nullToAbsent || purchaseUnitOfMeasureId != null) {
      map['purchase_unit_of_measure_id'] = Variable<String>(
        purchaseUnitOfMeasureId,
      );
    }
    if (!nullToAbsent || purchaseToStockConversionFactor != null) {
      map['purchase_to_stock_conversion_factor'] = Variable<double>(
        purchaseToStockConversionFactor,
      );
    }
    if (!nullToAbsent || purchaseUnitLabel != null) {
      map['purchase_unit_label'] = Variable<String>(purchaseUnitLabel);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    if (!nullToAbsent || unitCost != null) {
      map['unit_cost'] = Variable<double>(unitCost);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['allow_fractional_quantity'] = Variable<bool>(allowFractionalQuantity);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      itemType: Value(itemType),
      category: Value(category),
      locationId: Value(locationId),
      quantityOnHand: Value(quantityOnHand),
      minimumQuantity: Value(minimumQuantity),
      unitOfMeasureId: Value(unitOfMeasureId),
      purchaseUnitOfMeasureId: purchaseUnitOfMeasureId == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseUnitOfMeasureId),
      purchaseToStockConversionFactor:
          purchaseToStockConversionFactor == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseToStockConversionFactor),
      purchaseUnitLabel: purchaseUnitLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseUnitLabel),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      unitCost: unitCost == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCost),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      isActive: Value(isActive),
      allowFractionalQuantity: Value(allowFractionalQuantity),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ItemRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      itemType: serializer.fromJson<String>(json['itemType']),
      category: serializer.fromJson<String>(json['category']),
      locationId: serializer.fromJson<String>(json['locationId']),
      quantityOnHand: serializer.fromJson<double>(json['quantityOnHand']),
      minimumQuantity: serializer.fromJson<double>(json['minimumQuantity']),
      unitOfMeasureId: serializer.fromJson<String>(json['unitOfMeasureId']),
      purchaseUnitOfMeasureId: serializer.fromJson<String?>(
        json['purchaseUnitOfMeasureId'],
      ),
      purchaseToStockConversionFactor: serializer.fromJson<double?>(
        json['purchaseToStockConversionFactor'],
      ),
      purchaseUnitLabel: serializer.fromJson<String?>(
        json['purchaseUnitLabel'],
      ),
      barcode: serializer.fromJson<String?>(json['barcode']),
      sku: serializer.fromJson<String?>(json['sku']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      unitCost: serializer.fromJson<double?>(json['unitCost']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      allowFractionalQuantity: serializer.fromJson<bool>(
        json['allowFractionalQuantity'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'itemType': serializer.toJson<String>(itemType),
      'category': serializer.toJson<String>(category),
      'locationId': serializer.toJson<String>(locationId),
      'quantityOnHand': serializer.toJson<double>(quantityOnHand),
      'minimumQuantity': serializer.toJson<double>(minimumQuantity),
      'unitOfMeasureId': serializer.toJson<String>(unitOfMeasureId),
      'purchaseUnitOfMeasureId': serializer.toJson<String?>(
        purchaseUnitOfMeasureId,
      ),
      'purchaseToStockConversionFactor': serializer.toJson<double?>(
        purchaseToStockConversionFactor,
      ),
      'purchaseUnitLabel': serializer.toJson<String?>(purchaseUnitLabel),
      'barcode': serializer.toJson<String?>(barcode),
      'sku': serializer.toJson<String?>(sku),
      'supplierId': serializer.toJson<String?>(supplierId),
      'supplier': serializer.toJson<String?>(supplier),
      'unitCost': serializer.toJson<double?>(unitCost),
      'photoPath': serializer.toJson<String?>(photoPath),
      'isActive': serializer.toJson<bool>(isActive),
      'allowFractionalQuantity': serializer.toJson<bool>(
        allowFractionalQuantity,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ItemRecord copyWith({
    String? id,
    String? name,
    String? description,
    String? itemType,
    String? category,
    String? locationId,
    double? quantityOnHand,
    double? minimumQuantity,
    String? unitOfMeasureId,
    Value<String?> purchaseUnitOfMeasureId = const Value.absent(),
    Value<double?> purchaseToStockConversionFactor = const Value.absent(),
    Value<String?> purchaseUnitLabel = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    Value<String?> sku = const Value.absent(),
    Value<String?> supplierId = const Value.absent(),
    Value<String?> supplier = const Value.absent(),
    Value<double?> unitCost = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    bool? isActive,
    bool? allowFractionalQuantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ItemRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    itemType: itemType ?? this.itemType,
    category: category ?? this.category,
    locationId: locationId ?? this.locationId,
    quantityOnHand: quantityOnHand ?? this.quantityOnHand,
    minimumQuantity: minimumQuantity ?? this.minimumQuantity,
    unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
    purchaseUnitOfMeasureId: purchaseUnitOfMeasureId.present
        ? purchaseUnitOfMeasureId.value
        : this.purchaseUnitOfMeasureId,
    purchaseToStockConversionFactor: purchaseToStockConversionFactor.present
        ? purchaseToStockConversionFactor.value
        : this.purchaseToStockConversionFactor,
    purchaseUnitLabel: purchaseUnitLabel.present
        ? purchaseUnitLabel.value
        : this.purchaseUnitLabel,
    barcode: barcode.present ? barcode.value : this.barcode,
    sku: sku.present ? sku.value : this.sku,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    supplier: supplier.present ? supplier.value : this.supplier,
    unitCost: unitCost.present ? unitCost.value : this.unitCost,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    isActive: isActive ?? this.isActive,
    allowFractionalQuantity:
        allowFractionalQuantity ?? this.allowFractionalQuantity,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ItemRecord copyWithCompanion(ItemsCompanion data) {
    return ItemRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      category: data.category.present ? data.category.value : this.category,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      quantityOnHand: data.quantityOnHand.present
          ? data.quantityOnHand.value
          : this.quantityOnHand,
      minimumQuantity: data.minimumQuantity.present
          ? data.minimumQuantity.value
          : this.minimumQuantity,
      unitOfMeasureId: data.unitOfMeasureId.present
          ? data.unitOfMeasureId.value
          : this.unitOfMeasureId,
      purchaseUnitOfMeasureId: data.purchaseUnitOfMeasureId.present
          ? data.purchaseUnitOfMeasureId.value
          : this.purchaseUnitOfMeasureId,
      purchaseToStockConversionFactor:
          data.purchaseToStockConversionFactor.present
          ? data.purchaseToStockConversionFactor.value
          : this.purchaseToStockConversionFactor,
      purchaseUnitLabel: data.purchaseUnitLabel.present
          ? data.purchaseUnitLabel.value
          : this.purchaseUnitLabel,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      sku: data.sku.present ? data.sku.value : this.sku,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      allowFractionalQuantity: data.allowFractionalQuantity.present
          ? data.allowFractionalQuantity.value
          : this.allowFractionalQuantity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('itemType: $itemType, ')
          ..write('category: $category, ')
          ..write('locationId: $locationId, ')
          ..write('quantityOnHand: $quantityOnHand, ')
          ..write('minimumQuantity: $minimumQuantity, ')
          ..write('unitOfMeasureId: $unitOfMeasureId, ')
          ..write('purchaseUnitOfMeasureId: $purchaseUnitOfMeasureId, ')
          ..write(
            'purchaseToStockConversionFactor: $purchaseToStockConversionFactor, ',
          )
          ..write('purchaseUnitLabel: $purchaseUnitLabel, ')
          ..write('barcode: $barcode, ')
          ..write('sku: $sku, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplier: $supplier, ')
          ..write('unitCost: $unitCost, ')
          ..write('photoPath: $photoPath, ')
          ..write('isActive: $isActive, ')
          ..write('allowFractionalQuantity: $allowFractionalQuantity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    description,
    itemType,
    category,
    locationId,
    quantityOnHand,
    minimumQuantity,
    unitOfMeasureId,
    purchaseUnitOfMeasureId,
    purchaseToStockConversionFactor,
    purchaseUnitLabel,
    barcode,
    sku,
    supplierId,
    supplier,
    unitCost,
    photoPath,
    isActive,
    allowFractionalQuantity,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.itemType == this.itemType &&
          other.category == this.category &&
          other.locationId == this.locationId &&
          other.quantityOnHand == this.quantityOnHand &&
          other.minimumQuantity == this.minimumQuantity &&
          other.unitOfMeasureId == this.unitOfMeasureId &&
          other.purchaseUnitOfMeasureId == this.purchaseUnitOfMeasureId &&
          other.purchaseToStockConversionFactor ==
              this.purchaseToStockConversionFactor &&
          other.purchaseUnitLabel == this.purchaseUnitLabel &&
          other.barcode == this.barcode &&
          other.sku == this.sku &&
          other.supplierId == this.supplierId &&
          other.supplier == this.supplier &&
          other.unitCost == this.unitCost &&
          other.photoPath == this.photoPath &&
          other.isActive == this.isActive &&
          other.allowFractionalQuantity == this.allowFractionalQuantity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ItemsCompanion extends UpdateCompanion<ItemRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> itemType;
  final Value<String> category;
  final Value<String> locationId;
  final Value<double> quantityOnHand;
  final Value<double> minimumQuantity;
  final Value<String> unitOfMeasureId;
  final Value<String?> purchaseUnitOfMeasureId;
  final Value<double?> purchaseToStockConversionFactor;
  final Value<String?> purchaseUnitLabel;
  final Value<String?> barcode;
  final Value<String?> sku;
  final Value<String?> supplierId;
  final Value<String?> supplier;
  final Value<double?> unitCost;
  final Value<String?> photoPath;
  final Value<bool> isActive;
  final Value<bool> allowFractionalQuantity;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.itemType = const Value.absent(),
    this.category = const Value.absent(),
    this.locationId = const Value.absent(),
    this.quantityOnHand = const Value.absent(),
    this.minimumQuantity = const Value.absent(),
    this.unitOfMeasureId = const Value.absent(),
    this.purchaseUnitOfMeasureId = const Value.absent(),
    this.purchaseToStockConversionFactor = const Value.absent(),
    this.purchaseUnitLabel = const Value.absent(),
    this.barcode = const Value.absent(),
    this.sku = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.supplier = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.isActive = const Value.absent(),
    this.allowFractionalQuantity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String name,
    required String description,
    required String itemType,
    required String category,
    required String locationId,
    required double quantityOnHand,
    required double minimumQuantity,
    required String unitOfMeasureId,
    this.purchaseUnitOfMeasureId = const Value.absent(),
    this.purchaseToStockConversionFactor = const Value.absent(),
    this.purchaseUnitLabel = const Value.absent(),
    this.barcode = const Value.absent(),
    this.sku = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.supplier = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.photoPath = const Value.absent(),
    required bool isActive,
    required bool allowFractionalQuantity,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       description = Value(description),
       itemType = Value(itemType),
       category = Value(category),
       locationId = Value(locationId),
       quantityOnHand = Value(quantityOnHand),
       minimumQuantity = Value(minimumQuantity),
       unitOfMeasureId = Value(unitOfMeasureId),
       isActive = Value(isActive),
       allowFractionalQuantity = Value(allowFractionalQuantity),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ItemRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? itemType,
    Expression<String>? category,
    Expression<String>? locationId,
    Expression<double>? quantityOnHand,
    Expression<double>? minimumQuantity,
    Expression<String>? unitOfMeasureId,
    Expression<String>? purchaseUnitOfMeasureId,
    Expression<double>? purchaseToStockConversionFactor,
    Expression<String>? purchaseUnitLabel,
    Expression<String>? barcode,
    Expression<String>? sku,
    Expression<String>? supplierId,
    Expression<String>? supplier,
    Expression<double>? unitCost,
    Expression<String>? photoPath,
    Expression<bool>? isActive,
    Expression<bool>? allowFractionalQuantity,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (itemType != null) 'item_type': itemType,
      if (category != null) 'category': category,
      if (locationId != null) 'location_id': locationId,
      if (quantityOnHand != null) 'quantity_on_hand': quantityOnHand,
      if (minimumQuantity != null) 'minimum_quantity': minimumQuantity,
      if (unitOfMeasureId != null) 'unit_of_measure_id': unitOfMeasureId,
      if (purchaseUnitOfMeasureId != null)
        'purchase_unit_of_measure_id': purchaseUnitOfMeasureId,
      if (purchaseToStockConversionFactor != null)
        'purchase_to_stock_conversion_factor': purchaseToStockConversionFactor,
      if (purchaseUnitLabel != null) 'purchase_unit_label': purchaseUnitLabel,
      if (barcode != null) 'barcode': barcode,
      if (sku != null) 'sku': sku,
      if (supplierId != null) 'supplier_id': supplierId,
      if (supplier != null) 'supplier': supplier,
      if (unitCost != null) 'unit_cost': unitCost,
      if (photoPath != null) 'photo_path': photoPath,
      if (isActive != null) 'is_active': isActive,
      if (allowFractionalQuantity != null)
        'allow_fractional_quantity': allowFractionalQuantity,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? itemType,
    Value<String>? category,
    Value<String>? locationId,
    Value<double>? quantityOnHand,
    Value<double>? minimumQuantity,
    Value<String>? unitOfMeasureId,
    Value<String?>? purchaseUnitOfMeasureId,
    Value<double?>? purchaseToStockConversionFactor,
    Value<String?>? purchaseUnitLabel,
    Value<String?>? barcode,
    Value<String?>? sku,
    Value<String?>? supplierId,
    Value<String?>? supplier,
    Value<double?>? unitCost,
    Value<String?>? photoPath,
    Value<bool>? isActive,
    Value<bool>? allowFractionalQuantity,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      itemType: itemType ?? this.itemType,
      category: category ?? this.category,
      locationId: locationId ?? this.locationId,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      purchaseUnitOfMeasureId:
          purchaseUnitOfMeasureId ?? this.purchaseUnitOfMeasureId,
      purchaseToStockConversionFactor:
          purchaseToStockConversionFactor ??
          this.purchaseToStockConversionFactor,
      purchaseUnitLabel: purchaseUnitLabel ?? this.purchaseUnitLabel,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      supplierId: supplierId ?? this.supplierId,
      supplier: supplier ?? this.supplier,
      unitCost: unitCost ?? this.unitCost,
      photoPath: photoPath ?? this.photoPath,
      isActive: isActive ?? this.isActive,
      allowFractionalQuantity:
          allowFractionalQuantity ?? this.allowFractionalQuantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (quantityOnHand.present) {
      map['quantity_on_hand'] = Variable<double>(quantityOnHand.value);
    }
    if (minimumQuantity.present) {
      map['minimum_quantity'] = Variable<double>(minimumQuantity.value);
    }
    if (unitOfMeasureId.present) {
      map['unit_of_measure_id'] = Variable<String>(unitOfMeasureId.value);
    }
    if (purchaseUnitOfMeasureId.present) {
      map['purchase_unit_of_measure_id'] = Variable<String>(
        purchaseUnitOfMeasureId.value,
      );
    }
    if (purchaseToStockConversionFactor.present) {
      map['purchase_to_stock_conversion_factor'] = Variable<double>(
        purchaseToStockConversionFactor.value,
      );
    }
    if (purchaseUnitLabel.present) {
      map['purchase_unit_label'] = Variable<String>(purchaseUnitLabel.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (allowFractionalQuantity.present) {
      map['allow_fractional_quantity'] = Variable<bool>(
        allowFractionalQuantity.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('itemType: $itemType, ')
          ..write('category: $category, ')
          ..write('locationId: $locationId, ')
          ..write('quantityOnHand: $quantityOnHand, ')
          ..write('minimumQuantity: $minimumQuantity, ')
          ..write('unitOfMeasureId: $unitOfMeasureId, ')
          ..write('purchaseUnitOfMeasureId: $purchaseUnitOfMeasureId, ')
          ..write(
            'purchaseToStockConversionFactor: $purchaseToStockConversionFactor, ',
          )
          ..write('purchaseUnitLabel: $purchaseUnitLabel, ')
          ..write('barcode: $barcode, ')
          ..write('sku: $sku, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplier: $supplier, ')
          ..write('unitCost: $unitCost, ')
          ..write('photoPath: $photoPath, ')
          ..write('isActive: $isActive, ')
          ..write('allowFractionalQuantity: $allowFractionalQuantity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitsOfMeasureTable extends UnitsOfMeasure
    with TableInfo<$UnitsOfMeasureTable, UnitOfMeasureRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsOfMeasureTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _abbreviationMeta = const VerificationMeta(
    'abbreviation',
  );
  @override
  late final GeneratedColumn<String> abbreviation = GeneratedColumn<String>(
    'abbreviation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allowsDecimalMeta = const VerificationMeta(
    'allowsDecimal',
  );
  @override
  late final GeneratedColumn<bool> allowsDecimal = GeneratedColumn<bool>(
    'allows_decimal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allows_decimal" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    abbreviation,
    allowsDecimal,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units_of_measure';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnitOfMeasureRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('abbreviation')) {
      context.handle(
        _abbreviationMeta,
        abbreviation.isAcceptableOrUnknown(
          data['abbreviation']!,
          _abbreviationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_abbreviationMeta);
    }
    if (data.containsKey('allows_decimal')) {
      context.handle(
        _allowsDecimalMeta,
        allowsDecimal.isAcceptableOrUnknown(
          data['allows_decimal']!,
          _allowsDecimalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowsDecimalMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnitOfMeasureRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitOfMeasureRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      abbreviation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abbreviation'],
      )!,
      allowsDecimal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allows_decimal'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $UnitsOfMeasureTable createAlias(String alias) {
    return $UnitsOfMeasureTable(attachedDatabase, alias);
  }
}

class UnitOfMeasureRecord extends DataClass
    implements Insertable<UnitOfMeasureRecord> {
  final String id;
  final String name;
  final String abbreviation;
  final bool allowsDecimal;
  final bool isActive;
  const UnitOfMeasureRecord({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.allowsDecimal,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['abbreviation'] = Variable<String>(abbreviation);
    map['allows_decimal'] = Variable<bool>(allowsDecimal);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  UnitsOfMeasureCompanion toCompanion(bool nullToAbsent) {
    return UnitsOfMeasureCompanion(
      id: Value(id),
      name: Value(name),
      abbreviation: Value(abbreviation),
      allowsDecimal: Value(allowsDecimal),
      isActive: Value(isActive),
    );
  }

  factory UnitOfMeasureRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitOfMeasureRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      abbreviation: serializer.fromJson<String>(json['abbreviation']),
      allowsDecimal: serializer.fromJson<bool>(json['allowsDecimal']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'abbreviation': serializer.toJson<String>(abbreviation),
      'allowsDecimal': serializer.toJson<bool>(allowsDecimal),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  UnitOfMeasureRecord copyWith({
    String? id,
    String? name,
    String? abbreviation,
    bool? allowsDecimal,
    bool? isActive,
  }) => UnitOfMeasureRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    abbreviation: abbreviation ?? this.abbreviation,
    allowsDecimal: allowsDecimal ?? this.allowsDecimal,
    isActive: isActive ?? this.isActive,
  );
  UnitOfMeasureRecord copyWithCompanion(UnitsOfMeasureCompanion data) {
    return UnitOfMeasureRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      abbreviation: data.abbreviation.present
          ? data.abbreviation.value
          : this.abbreviation,
      allowsDecimal: data.allowsDecimal.present
          ? data.allowsDecimal.value
          : this.allowsDecimal,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitOfMeasureRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('abbreviation: $abbreviation, ')
          ..write('allowsDecimal: $allowsDecimal, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, abbreviation, allowsDecimal, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitOfMeasureRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.abbreviation == this.abbreviation &&
          other.allowsDecimal == this.allowsDecimal &&
          other.isActive == this.isActive);
}

class UnitsOfMeasureCompanion extends UpdateCompanion<UnitOfMeasureRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> abbreviation;
  final Value<bool> allowsDecimal;
  final Value<bool> isActive;
  final Value<int> rowid;
  const UnitsOfMeasureCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.abbreviation = const Value.absent(),
    this.allowsDecimal = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitsOfMeasureCompanion.insert({
    required String id,
    required String name,
    required String abbreviation,
    required bool allowsDecimal,
    required bool isActive,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       abbreviation = Value(abbreviation),
       allowsDecimal = Value(allowsDecimal),
       isActive = Value(isActive);
  static Insertable<UnitOfMeasureRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? abbreviation,
    Expression<bool>? allowsDecimal,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (abbreviation != null) 'abbreviation': abbreviation,
      if (allowsDecimal != null) 'allows_decimal': allowsDecimal,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitsOfMeasureCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? abbreviation,
    Value<bool>? allowsDecimal,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return UnitsOfMeasureCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      allowsDecimal: allowsDecimal ?? this.allowsDecimal,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (abbreviation.present) {
      map['abbreviation'] = Variable<String>(abbreviation.value);
    }
    if (allowsDecimal.present) {
      map['allows_decimal'] = Variable<bool>(allowsDecimal.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitsOfMeasureCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('abbreviation: $abbreviation, ')
          ..write('allowsDecimal: $allowsDecimal, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, LocationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentLocationIdMeta = const VerificationMeta(
    'parentLocationId',
  );
  @override
  late final GeneratedColumn<String> parentLocationId = GeneratedColumn<String>(
    'parent_location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    code,
    type,
    parentLocationId,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('parent_location_id')) {
      context.handle(
        _parentLocationIdMeta,
        parentLocationId.isAcceptableOrUnknown(
          data['parent_location_id']!,
          _parentLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      parentLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_location_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(attachedDatabase, alias);
  }
}

class LocationRecord extends DataClass implements Insertable<LocationRecord> {
  final String id;
  final String name;
  final String? description;
  final String? code;
  final String type;
  final String? parentLocationId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocationRecord({
    required this.id,
    required this.name,
    this.description,
    this.code,
    required this.type,
    this.parentLocationId,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || parentLocationId != null) {
      map['parent_location_id'] = Variable<String>(parentLocationId);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocationsCompanion toCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      type: Value(type),
      parentLocationId: parentLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentLocationId),
      isActive: Value(isActive),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocationRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      code: serializer.fromJson<String?>(json['code']),
      type: serializer.fromJson<String>(json['type']),
      parentLocationId: serializer.fromJson<String?>(json['parentLocationId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'code': serializer.toJson<String?>(code),
      'type': serializer.toJson<String>(type),
      'parentLocationId': serializer.toJson<String?>(parentLocationId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocationRecord copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> code = const Value.absent(),
    String? type,
    Value<String?> parentLocationId = const Value.absent(),
    bool? isActive,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => LocationRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    code: code.present ? code.value : this.code,
    type: type ?? this.type,
    parentLocationId: parentLocationId.present
        ? parentLocationId.value
        : this.parentLocationId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  LocationRecord copyWithCompanion(LocationsCompanion data) {
    return LocationRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      code: data.code.present ? data.code.value : this.code,
      type: data.type.present ? data.type.value : this.type,
      parentLocationId: data.parentLocationId.present
          ? data.parentLocationId.value
          : this.parentLocationId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('code: $code, ')
          ..write('type: $type, ')
          ..write('parentLocationId: $parentLocationId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    code,
    type,
    parentLocationId,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.code == this.code &&
          other.type == this.type &&
          other.parentLocationId == this.parentLocationId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocationsCompanion extends UpdateCompanion<LocationRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> code;
  final Value<String> type;
  final Value<String?> parentLocationId;
  final Value<bool> isActive;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.code = const Value.absent(),
    this.type = const Value.absent(),
    this.parentLocationId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.code = const Value.absent(),
    required String type,
    this.parentLocationId = const Value.absent(),
    required bool isActive,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       isActive = Value(isActive);
  static Insertable<LocationRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? code,
    Expression<String>? type,
    Expression<String>? parentLocationId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (code != null) 'code': code,
      if (type != null) 'type': type,
      if (parentLocationId != null) 'parent_location_id': parentLocationId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? code,
    Value<String>? type,
    Value<String?>? parentLocationId,
    Value<bool>? isActive,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      code: code ?? this.code,
      type: type ?? this.type,
      parentLocationId: parentLocationId ?? this.parentLocationId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parentLocationId.present) {
      map['parent_location_id'] = Variable<String>(parentLocationId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('code: $code, ')
          ..write('type: $type, ')
          ..write('parentLocationId: $parentLocationId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeopleTable extends People with TableInfo<$PeopleTable, PersonRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isLoginUserMeta = const VerificationMeta(
    'isLoginUser',
  );
  @override
  late final GeneratedColumn<bool> isLoginUser = GeneratedColumn<bool>(
    'is_login_user',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_login_user" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    email,
    phone,
    isActive,
    isLoginUser,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'people';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('is_login_user')) {
      context.handle(
        _isLoginUserMeta,
        isLoginUser.isAcceptableOrUnknown(
          data['is_login_user']!,
          _isLoginUserMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isLoginUserMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isLoginUser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_login_user'],
      )!,
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }
}

class PersonRecord extends DataClass implements Insertable<PersonRecord> {
  final String id;
  final String displayName;
  final String? email;
  final String? phone;
  final bool isActive;
  final bool isLoginUser;
  const PersonRecord({
    required this.id,
    required this.displayName,
    this.email,
    this.phone,
    required this.isActive,
    required this.isLoginUser,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['is_login_user'] = Variable<bool>(isLoginUser);
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      displayName: Value(displayName),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      isActive: Value(isActive),
      isLoginUser: Value(isLoginUser),
    );
  }

  factory PersonRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonRecord(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isLoginUser: serializer.fromJson<bool>(json['isLoginUser']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'isActive': serializer.toJson<bool>(isActive),
      'isLoginUser': serializer.toJson<bool>(isLoginUser),
    };
  }

  PersonRecord copyWith({
    String? id,
    String? displayName,
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    bool? isActive,
    bool? isLoginUser,
  }) => PersonRecord(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    isActive: isActive ?? this.isActive,
    isLoginUser: isLoginUser ?? this.isLoginUser,
  );
  PersonRecord copyWithCompanion(PeopleCompanion data) {
    return PersonRecord(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isLoginUser: data.isLoginUser.present
          ? data.isLoginUser.value
          : this.isLoginUser,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonRecord(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('isActive: $isActive, ')
          ..write('isLoginUser: $isLoginUser')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, displayName, email, phone, isActive, isLoginUser);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonRecord &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.isActive == this.isActive &&
          other.isLoginUser == this.isLoginUser);
}

class PeopleCompanion extends UpdateCompanion<PersonRecord> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<bool> isActive;
  final Value<bool> isLoginUser;
  final Value<int> rowid;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isLoginUser = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeopleCompanion.insert({
    required String id,
    required String displayName,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    required bool isActive,
    required bool isLoginUser,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       isActive = Value(isActive),
       isLoginUser = Value(isLoginUser);
  static Insertable<PersonRecord> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<bool>? isActive,
    Expression<bool>? isLoginUser,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (isActive != null) 'is_active': isActive,
      if (isLoginUser != null) 'is_login_user': isLoginUser,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeopleCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String?>? email,
    Value<String?>? phone,
    Value<bool>? isActive,
    Value<bool>? isLoginUser,
    Value<int>? rowid,
  }) {
    return PeopleCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      isLoginUser: isLoginUser ?? this.isLoginUser,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isLoginUser.present) {
      map['is_login_user'] = Variable<bool>(isLoginUser.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('isActive: $isActive, ')
          ..write('isLoginUser: $isLoginUser, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppUsersTable extends AppUsers
    with TableInfo<$AppUsersTable, AppUserRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinSaltMeta = const VerificationMeta(
    'pinSalt',
  );
  @override
  late final GeneratedColumn<String> pinSalt = GeneratedColumn<String>(
    'pin_salt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    email,
    role,
    isActive,
    pinHash,
    pinSalt,
    createdAt,
    updatedAt,
    lastLoginAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUserRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    }
    if (data.containsKey('pin_salt')) {
      context.handle(
        _pinSaltMeta,
        pinSalt.isAcceptableOrUnknown(data['pin_salt']!, _pinSaltMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUserRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUserRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
      pinSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_salt'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      ),
    );
  }

  @override
  $AppUsersTable createAlias(String alias) {
    return $AppUsersTable(attachedDatabase, alias);
  }
}

class AppUserRecord extends DataClass implements Insertable<AppUserRecord> {
  final String id;
  final String personId;
  final String email;
  final String role;
  final bool isActive;
  final String? pinHash;
  final String? pinSalt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  const AppUserRecord({
    required this.id,
    required this.personId,
    required this.email,
    required this.role,
    required this.isActive,
    this.pinHash,
    this.pinSalt,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    if (!nullToAbsent || pinSalt != null) {
      map['pin_salt'] = Variable<String>(pinSalt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      id: Value(id),
      personId: Value(personId),
      email: Value(email),
      role: Value(role),
      isActive: Value(isActive),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      pinSalt: pinSalt == null && nullToAbsent
          ? const Value.absent()
          : Value(pinSalt),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
    );
  }

  factory AppUserRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUserRecord(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      pinSalt: serializer.fromJson<String?>(json['pinSalt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'pinHash': serializer.toJson<String?>(pinHash),
      'pinSalt': serializer.toJson<String?>(pinSalt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
    };
  }

  AppUserRecord copyWith({
    String? id,
    String? personId,
    String? email,
    String? role,
    bool? isActive,
    Value<String?> pinHash = const Value.absent(),
    Value<String?> pinSalt = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> lastLoginAt = const Value.absent(),
  }) => AppUserRecord(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    email: email ?? this.email,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    pinSalt: pinSalt.present ? pinSalt.value : this.pinSalt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
  );
  AppUserRecord copyWithCompanion(AppUsersCompanion data) {
    return AppUserRecord(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      pinSalt: data.pinSalt.present ? data.pinSalt.value : this.pinSalt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUserRecord(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastLoginAt: $lastLoginAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    email,
    role,
    isActive,
    pinHash,
    pinSalt,
    createdAt,
    updatedAt,
    lastLoginAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUserRecord &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.email == this.email &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.pinHash == this.pinHash &&
          other.pinSalt == this.pinSalt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastLoginAt == this.lastLoginAt);
}

class AppUsersCompanion extends UpdateCompanion<AppUserRecord> {
  final Value<String> id;
  final Value<String> personId;
  final Value<String> email;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<String?> pinHash;
  final Value<String?> pinSalt;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> lastLoginAt;
  final Value<int> rowid;
  const AppUsersCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppUsersCompanion.insert({
    required String id,
    required String personId,
    required String email,
    required String role,
    required bool isActive,
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personId = Value(personId),
       email = Value(email),
       role = Value(role),
       isActive = Value(isActive),
       createdAt = Value(createdAt);
  static Insertable<AppUserRecord> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? email,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<String>? pinHash,
    Expression<String>? pinSalt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastLoginAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (pinHash != null) 'pin_hash': pinHash,
      if (pinSalt != null) 'pin_salt': pinSalt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppUsersCompanion copyWith({
    Value<String>? id,
    Value<String>? personId,
    Value<String>? email,
    Value<String>? role,
    Value<bool>? isActive,
    Value<String?>? pinHash,
    Value<String?>? pinSalt,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? lastLoginAt,
    Value<int>? rowid,
  }) {
    return AppUsersCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (pinSalt.present) {
      map['pin_salt'] = Variable<String>(pinSalt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsersCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryTransactionsTable extends InventoryTransactions
    with TableInfo<$InventoryTransactionsTable, InventoryTransactionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityDeltaMeta = const VerificationMeta(
    'quantityDelta',
  );
  @override
  late final GeneratedColumn<double> quantityDelta = GeneratedColumn<double>(
    'quantity_delta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitOfMeasureIdMeta = const VerificationMeta(
    'unitOfMeasureId',
  );
  @override
  late final GeneratedColumn<String> unitOfMeasureId = GeneratedColumn<String>(
    'unit_of_measure_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromLocationIdMeta = const VerificationMeta(
    'fromLocationId',
  );
  @override
  late final GeneratedColumn<String> fromLocationId = GeneratedColumn<String>(
    'from_location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toLocationIdMeta = const VerificationMeta(
    'toLocationId',
  );
  @override
  late final GeneratedColumn<String> toLocationId = GeneratedColumn<String>(
    'to_location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedToPersonIdMeta =
      const VerificationMeta('assignedToPersonId');
  @override
  late final GeneratedColumn<String> assignedToPersonId =
      GeneratedColumn<String>(
        'assigned_to_person_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _assignedToLocationIdMeta =
      const VerificationMeta('assignedToLocationId');
  @override
  late final GeneratedColumn<String> assignedToLocationId =
      GeneratedColumn<String>(
        'assigned_to_location_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _assignedToTargetIdMeta =
      const VerificationMeta('assignedToTargetId');
  @override
  late final GeneratedColumn<String> assignedToTargetId =
      GeneratedColumn<String>(
        'assigned_to_target_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _assignedToTextMeta = const VerificationMeta(
    'assignedToText',
  );
  @override
  late final GeneratedColumn<String> assignedToText = GeneratedColumn<String>(
    'assigned_to_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _performedByUserIdMeta = const VerificationMeta(
    'performedByUserId',
  );
  @override
  late final GeneratedColumn<String> performedByUserId =
      GeneratedColumn<String>(
        'performed_by_user_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reversedByTransactionIdMeta =
      const VerificationMeta('reversedByTransactionId');
  @override
  late final GeneratedColumn<String> reversedByTransactionId =
      GeneratedColumn<String>(
        'reversed_by_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reversesTransactionIdMeta =
      const VerificationMeta('reversesTransactionId');
  @override
  late final GeneratedColumn<String> reversesTransactionId =
      GeneratedColumn<String>(
        'reverses_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _correctionReasonMeta = const VerificationMeta(
    'correctionReason',
  );
  @override
  late final GeneratedColumn<String> correctionReason = GeneratedColumn<String>(
    'correction_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctedAtMeta = const VerificationMeta(
    'correctedAt',
  );
  @override
  late final GeneratedColumn<DateTime> correctedAt = GeneratedColumn<DateTime>(
    'corrected_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    transactionType,
    quantityDelta,
    unitOfMeasureId,
    fromLocationId,
    toLocationId,
    assignedToPersonId,
    assignedToLocationId,
    assignedToTargetId,
    assignedToText,
    performedByUserId,
    notes,
    reversedByTransactionId,
    reversesTransactionId,
    correctionReason,
    correctedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryTransactionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('quantity_delta')) {
      context.handle(
        _quantityDeltaMeta,
        quantityDelta.isAcceptableOrUnknown(
          data['quantity_delta']!,
          _quantityDeltaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityDeltaMeta);
    }
    if (data.containsKey('unit_of_measure_id')) {
      context.handle(
        _unitOfMeasureIdMeta,
        unitOfMeasureId.isAcceptableOrUnknown(
          data['unit_of_measure_id']!,
          _unitOfMeasureIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitOfMeasureIdMeta);
    }
    if (data.containsKey('from_location_id')) {
      context.handle(
        _fromLocationIdMeta,
        fromLocationId.isAcceptableOrUnknown(
          data['from_location_id']!,
          _fromLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('to_location_id')) {
      context.handle(
        _toLocationIdMeta,
        toLocationId.isAcceptableOrUnknown(
          data['to_location_id']!,
          _toLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('assigned_to_person_id')) {
      context.handle(
        _assignedToPersonIdMeta,
        assignedToPersonId.isAcceptableOrUnknown(
          data['assigned_to_person_id']!,
          _assignedToPersonIdMeta,
        ),
      );
    }
    if (data.containsKey('assigned_to_location_id')) {
      context.handle(
        _assignedToLocationIdMeta,
        assignedToLocationId.isAcceptableOrUnknown(
          data['assigned_to_location_id']!,
          _assignedToLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('assigned_to_target_id')) {
      context.handle(
        _assignedToTargetIdMeta,
        assignedToTargetId.isAcceptableOrUnknown(
          data['assigned_to_target_id']!,
          _assignedToTargetIdMeta,
        ),
      );
    }
    if (data.containsKey('assigned_to_text')) {
      context.handle(
        _assignedToTextMeta,
        assignedToText.isAcceptableOrUnknown(
          data['assigned_to_text']!,
          _assignedToTextMeta,
        ),
      );
    }
    if (data.containsKey('performed_by_user_id')) {
      context.handle(
        _performedByUserIdMeta,
        performedByUserId.isAcceptableOrUnknown(
          data['performed_by_user_id']!,
          _performedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('reversed_by_transaction_id')) {
      context.handle(
        _reversedByTransactionIdMeta,
        reversedByTransactionId.isAcceptableOrUnknown(
          data['reversed_by_transaction_id']!,
          _reversedByTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('reverses_transaction_id')) {
      context.handle(
        _reversesTransactionIdMeta,
        reversesTransactionId.isAcceptableOrUnknown(
          data['reverses_transaction_id']!,
          _reversesTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('correction_reason')) {
      context.handle(
        _correctionReasonMeta,
        correctionReason.isAcceptableOrUnknown(
          data['correction_reason']!,
          _correctionReasonMeta,
        ),
      );
    }
    if (data.containsKey('corrected_at')) {
      context.handle(
        _correctedAtMeta,
        correctedAt.isAcceptableOrUnknown(
          data['corrected_at']!,
          _correctedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryTransactionRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryTransactionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      quantityDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_delta'],
      )!,
      unitOfMeasureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_of_measure_id'],
      )!,
      fromLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_location_id'],
      ),
      toLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_location_id'],
      ),
      assignedToPersonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to_person_id'],
      ),
      assignedToLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to_location_id'],
      ),
      assignedToTargetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to_target_id'],
      ),
      assignedToText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to_text'],
      ),
      performedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}performed_by_user_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      reversedByTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reversed_by_transaction_id'],
      ),
      reversesTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_transaction_id'],
      ),
      correctionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correction_reason'],
      ),
      correctedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}corrected_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InventoryTransactionsTable createAlias(String alias) {
    return $InventoryTransactionsTable(attachedDatabase, alias);
  }
}

class InventoryTransactionRecord extends DataClass
    implements Insertable<InventoryTransactionRecord> {
  final String id;
  final String itemId;
  final String transactionType;
  final double quantityDelta;
  final String unitOfMeasureId;
  final String? fromLocationId;
  final String? toLocationId;
  final String? assignedToPersonId;
  final String? assignedToLocationId;
  final String? assignedToTargetId;
  final String? assignedToText;
  final String? performedByUserId;
  final String? notes;
  final String? reversedByTransactionId;
  final String? reversesTransactionId;
  final String? correctionReason;
  final DateTime? correctedAt;
  final DateTime createdAt;
  const InventoryTransactionRecord({
    required this.id,
    required this.itemId,
    required this.transactionType,
    required this.quantityDelta,
    required this.unitOfMeasureId,
    this.fromLocationId,
    this.toLocationId,
    this.assignedToPersonId,
    this.assignedToLocationId,
    this.assignedToTargetId,
    this.assignedToText,
    this.performedByUserId,
    this.notes,
    this.reversedByTransactionId,
    this.reversesTransactionId,
    this.correctionReason,
    this.correctedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['transaction_type'] = Variable<String>(transactionType);
    map['quantity_delta'] = Variable<double>(quantityDelta);
    map['unit_of_measure_id'] = Variable<String>(unitOfMeasureId);
    if (!nullToAbsent || fromLocationId != null) {
      map['from_location_id'] = Variable<String>(fromLocationId);
    }
    if (!nullToAbsent || toLocationId != null) {
      map['to_location_id'] = Variable<String>(toLocationId);
    }
    if (!nullToAbsent || assignedToPersonId != null) {
      map['assigned_to_person_id'] = Variable<String>(assignedToPersonId);
    }
    if (!nullToAbsent || assignedToLocationId != null) {
      map['assigned_to_location_id'] = Variable<String>(assignedToLocationId);
    }
    if (!nullToAbsent || assignedToTargetId != null) {
      map['assigned_to_target_id'] = Variable<String>(assignedToTargetId);
    }
    if (!nullToAbsent || assignedToText != null) {
      map['assigned_to_text'] = Variable<String>(assignedToText);
    }
    if (!nullToAbsent || performedByUserId != null) {
      map['performed_by_user_id'] = Variable<String>(performedByUserId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || reversedByTransactionId != null) {
      map['reversed_by_transaction_id'] = Variable<String>(
        reversedByTransactionId,
      );
    }
    if (!nullToAbsent || reversesTransactionId != null) {
      map['reverses_transaction_id'] = Variable<String>(reversesTransactionId);
    }
    if (!nullToAbsent || correctionReason != null) {
      map['correction_reason'] = Variable<String>(correctionReason);
    }
    if (!nullToAbsent || correctedAt != null) {
      map['corrected_at'] = Variable<DateTime>(correctedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InventoryTransactionsCompanion toCompanion(bool nullToAbsent) {
    return InventoryTransactionsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      transactionType: Value(transactionType),
      quantityDelta: Value(quantityDelta),
      unitOfMeasureId: Value(unitOfMeasureId),
      fromLocationId: fromLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromLocationId),
      toLocationId: toLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(toLocationId),
      assignedToPersonId: assignedToPersonId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToPersonId),
      assignedToLocationId: assignedToLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToLocationId),
      assignedToTargetId: assignedToTargetId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToTargetId),
      assignedToText: assignedToText == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToText),
      performedByUserId: performedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(performedByUserId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      reversedByTransactionId: reversedByTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversedByTransactionId),
      reversesTransactionId: reversesTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversesTransactionId),
      correctionReason: correctionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(correctionReason),
      correctedAt: correctedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(correctedAt),
      createdAt: Value(createdAt),
    );
  }

  factory InventoryTransactionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryTransactionRecord(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      quantityDelta: serializer.fromJson<double>(json['quantityDelta']),
      unitOfMeasureId: serializer.fromJson<String>(json['unitOfMeasureId']),
      fromLocationId: serializer.fromJson<String?>(json['fromLocationId']),
      toLocationId: serializer.fromJson<String?>(json['toLocationId']),
      assignedToPersonId: serializer.fromJson<String?>(
        json['assignedToPersonId'],
      ),
      assignedToLocationId: serializer.fromJson<String?>(
        json['assignedToLocationId'],
      ),
      assignedToTargetId: serializer.fromJson<String?>(
        json['assignedToTargetId'],
      ),
      assignedToText: serializer.fromJson<String?>(json['assignedToText']),
      performedByUserId: serializer.fromJson<String?>(
        json['performedByUserId'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      reversedByTransactionId: serializer.fromJson<String?>(
        json['reversedByTransactionId'],
      ),
      reversesTransactionId: serializer.fromJson<String?>(
        json['reversesTransactionId'],
      ),
      correctionReason: serializer.fromJson<String?>(json['correctionReason']),
      correctedAt: serializer.fromJson<DateTime?>(json['correctedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'transactionType': serializer.toJson<String>(transactionType),
      'quantityDelta': serializer.toJson<double>(quantityDelta),
      'unitOfMeasureId': serializer.toJson<String>(unitOfMeasureId),
      'fromLocationId': serializer.toJson<String?>(fromLocationId),
      'toLocationId': serializer.toJson<String?>(toLocationId),
      'assignedToPersonId': serializer.toJson<String?>(assignedToPersonId),
      'assignedToLocationId': serializer.toJson<String?>(assignedToLocationId),
      'assignedToTargetId': serializer.toJson<String?>(assignedToTargetId),
      'assignedToText': serializer.toJson<String?>(assignedToText),
      'performedByUserId': serializer.toJson<String?>(performedByUserId),
      'notes': serializer.toJson<String?>(notes),
      'reversedByTransactionId': serializer.toJson<String?>(
        reversedByTransactionId,
      ),
      'reversesTransactionId': serializer.toJson<String?>(
        reversesTransactionId,
      ),
      'correctionReason': serializer.toJson<String?>(correctionReason),
      'correctedAt': serializer.toJson<DateTime?>(correctedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InventoryTransactionRecord copyWith({
    String? id,
    String? itemId,
    String? transactionType,
    double? quantityDelta,
    String? unitOfMeasureId,
    Value<String?> fromLocationId = const Value.absent(),
    Value<String?> toLocationId = const Value.absent(),
    Value<String?> assignedToPersonId = const Value.absent(),
    Value<String?> assignedToLocationId = const Value.absent(),
    Value<String?> assignedToTargetId = const Value.absent(),
    Value<String?> assignedToText = const Value.absent(),
    Value<String?> performedByUserId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> reversedByTransactionId = const Value.absent(),
    Value<String?> reversesTransactionId = const Value.absent(),
    Value<String?> correctionReason = const Value.absent(),
    Value<DateTime?> correctedAt = const Value.absent(),
    DateTime? createdAt,
  }) => InventoryTransactionRecord(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    transactionType: transactionType ?? this.transactionType,
    quantityDelta: quantityDelta ?? this.quantityDelta,
    unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
    fromLocationId: fromLocationId.present
        ? fromLocationId.value
        : this.fromLocationId,
    toLocationId: toLocationId.present ? toLocationId.value : this.toLocationId,
    assignedToPersonId: assignedToPersonId.present
        ? assignedToPersonId.value
        : this.assignedToPersonId,
    assignedToLocationId: assignedToLocationId.present
        ? assignedToLocationId.value
        : this.assignedToLocationId,
    assignedToTargetId: assignedToTargetId.present
        ? assignedToTargetId.value
        : this.assignedToTargetId,
    assignedToText: assignedToText.present
        ? assignedToText.value
        : this.assignedToText,
    performedByUserId: performedByUserId.present
        ? performedByUserId.value
        : this.performedByUserId,
    notes: notes.present ? notes.value : this.notes,
    reversedByTransactionId: reversedByTransactionId.present
        ? reversedByTransactionId.value
        : this.reversedByTransactionId,
    reversesTransactionId: reversesTransactionId.present
        ? reversesTransactionId.value
        : this.reversesTransactionId,
    correctionReason: correctionReason.present
        ? correctionReason.value
        : this.correctionReason,
    correctedAt: correctedAt.present ? correctedAt.value : this.correctedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  InventoryTransactionRecord copyWithCompanion(
    InventoryTransactionsCompanion data,
  ) {
    return InventoryTransactionRecord(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      quantityDelta: data.quantityDelta.present
          ? data.quantityDelta.value
          : this.quantityDelta,
      unitOfMeasureId: data.unitOfMeasureId.present
          ? data.unitOfMeasureId.value
          : this.unitOfMeasureId,
      fromLocationId: data.fromLocationId.present
          ? data.fromLocationId.value
          : this.fromLocationId,
      toLocationId: data.toLocationId.present
          ? data.toLocationId.value
          : this.toLocationId,
      assignedToPersonId: data.assignedToPersonId.present
          ? data.assignedToPersonId.value
          : this.assignedToPersonId,
      assignedToLocationId: data.assignedToLocationId.present
          ? data.assignedToLocationId.value
          : this.assignedToLocationId,
      assignedToTargetId: data.assignedToTargetId.present
          ? data.assignedToTargetId.value
          : this.assignedToTargetId,
      assignedToText: data.assignedToText.present
          ? data.assignedToText.value
          : this.assignedToText,
      performedByUserId: data.performedByUserId.present
          ? data.performedByUserId.value
          : this.performedByUserId,
      notes: data.notes.present ? data.notes.value : this.notes,
      reversedByTransactionId: data.reversedByTransactionId.present
          ? data.reversedByTransactionId.value
          : this.reversedByTransactionId,
      reversesTransactionId: data.reversesTransactionId.present
          ? data.reversesTransactionId.value
          : this.reversesTransactionId,
      correctionReason: data.correctionReason.present
          ? data.correctionReason.value
          : this.correctionReason,
      correctedAt: data.correctedAt.present
          ? data.correctedAt.value
          : this.correctedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryTransactionRecord(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('transactionType: $transactionType, ')
          ..write('quantityDelta: $quantityDelta, ')
          ..write('unitOfMeasureId: $unitOfMeasureId, ')
          ..write('fromLocationId: $fromLocationId, ')
          ..write('toLocationId: $toLocationId, ')
          ..write('assignedToPersonId: $assignedToPersonId, ')
          ..write('assignedToLocationId: $assignedToLocationId, ')
          ..write('assignedToTargetId: $assignedToTargetId, ')
          ..write('assignedToText: $assignedToText, ')
          ..write('performedByUserId: $performedByUserId, ')
          ..write('notes: $notes, ')
          ..write('reversedByTransactionId: $reversedByTransactionId, ')
          ..write('reversesTransactionId: $reversesTransactionId, ')
          ..write('correctionReason: $correctionReason, ')
          ..write('correctedAt: $correctedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    transactionType,
    quantityDelta,
    unitOfMeasureId,
    fromLocationId,
    toLocationId,
    assignedToPersonId,
    assignedToLocationId,
    assignedToTargetId,
    assignedToText,
    performedByUserId,
    notes,
    reversedByTransactionId,
    reversesTransactionId,
    correctionReason,
    correctedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryTransactionRecord &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.transactionType == this.transactionType &&
          other.quantityDelta == this.quantityDelta &&
          other.unitOfMeasureId == this.unitOfMeasureId &&
          other.fromLocationId == this.fromLocationId &&
          other.toLocationId == this.toLocationId &&
          other.assignedToPersonId == this.assignedToPersonId &&
          other.assignedToLocationId == this.assignedToLocationId &&
          other.assignedToTargetId == this.assignedToTargetId &&
          other.assignedToText == this.assignedToText &&
          other.performedByUserId == this.performedByUserId &&
          other.notes == this.notes &&
          other.reversedByTransactionId == this.reversedByTransactionId &&
          other.reversesTransactionId == this.reversesTransactionId &&
          other.correctionReason == this.correctionReason &&
          other.correctedAt == this.correctedAt &&
          other.createdAt == this.createdAt);
}

class InventoryTransactionsCompanion
    extends UpdateCompanion<InventoryTransactionRecord> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> transactionType;
  final Value<double> quantityDelta;
  final Value<String> unitOfMeasureId;
  final Value<String?> fromLocationId;
  final Value<String?> toLocationId;
  final Value<String?> assignedToPersonId;
  final Value<String?> assignedToLocationId;
  final Value<String?> assignedToTargetId;
  final Value<String?> assignedToText;
  final Value<String?> performedByUserId;
  final Value<String?> notes;
  final Value<String?> reversedByTransactionId;
  final Value<String?> reversesTransactionId;
  final Value<String?> correctionReason;
  final Value<DateTime?> correctedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InventoryTransactionsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.quantityDelta = const Value.absent(),
    this.unitOfMeasureId = const Value.absent(),
    this.fromLocationId = const Value.absent(),
    this.toLocationId = const Value.absent(),
    this.assignedToPersonId = const Value.absent(),
    this.assignedToLocationId = const Value.absent(),
    this.assignedToTargetId = const Value.absent(),
    this.assignedToText = const Value.absent(),
    this.performedByUserId = const Value.absent(),
    this.notes = const Value.absent(),
    this.reversedByTransactionId = const Value.absent(),
    this.reversesTransactionId = const Value.absent(),
    this.correctionReason = const Value.absent(),
    this.correctedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryTransactionsCompanion.insert({
    required String id,
    required String itemId,
    required String transactionType,
    required double quantityDelta,
    required String unitOfMeasureId,
    this.fromLocationId = const Value.absent(),
    this.toLocationId = const Value.absent(),
    this.assignedToPersonId = const Value.absent(),
    this.assignedToLocationId = const Value.absent(),
    this.assignedToTargetId = const Value.absent(),
    this.assignedToText = const Value.absent(),
    this.performedByUserId = const Value.absent(),
    this.notes = const Value.absent(),
    this.reversedByTransactionId = const Value.absent(),
    this.reversesTransactionId = const Value.absent(),
    this.correctionReason = const Value.absent(),
    this.correctedAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       transactionType = Value(transactionType),
       quantityDelta = Value(quantityDelta),
       unitOfMeasureId = Value(unitOfMeasureId),
       createdAt = Value(createdAt);
  static Insertable<InventoryTransactionRecord> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? transactionType,
    Expression<double>? quantityDelta,
    Expression<String>? unitOfMeasureId,
    Expression<String>? fromLocationId,
    Expression<String>? toLocationId,
    Expression<String>? assignedToPersonId,
    Expression<String>? assignedToLocationId,
    Expression<String>? assignedToTargetId,
    Expression<String>? assignedToText,
    Expression<String>? performedByUserId,
    Expression<String>? notes,
    Expression<String>? reversedByTransactionId,
    Expression<String>? reversesTransactionId,
    Expression<String>? correctionReason,
    Expression<DateTime>? correctedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (transactionType != null) 'transaction_type': transactionType,
      if (quantityDelta != null) 'quantity_delta': quantityDelta,
      if (unitOfMeasureId != null) 'unit_of_measure_id': unitOfMeasureId,
      if (fromLocationId != null) 'from_location_id': fromLocationId,
      if (toLocationId != null) 'to_location_id': toLocationId,
      if (assignedToPersonId != null)
        'assigned_to_person_id': assignedToPersonId,
      if (assignedToLocationId != null)
        'assigned_to_location_id': assignedToLocationId,
      if (assignedToTargetId != null)
        'assigned_to_target_id': assignedToTargetId,
      if (assignedToText != null) 'assigned_to_text': assignedToText,
      if (performedByUserId != null) 'performed_by_user_id': performedByUserId,
      if (notes != null) 'notes': notes,
      if (reversedByTransactionId != null)
        'reversed_by_transaction_id': reversedByTransactionId,
      if (reversesTransactionId != null)
        'reverses_transaction_id': reversesTransactionId,
      if (correctionReason != null) 'correction_reason': correctionReason,
      if (correctedAt != null) 'corrected_at': correctedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? transactionType,
    Value<double>? quantityDelta,
    Value<String>? unitOfMeasureId,
    Value<String?>? fromLocationId,
    Value<String?>? toLocationId,
    Value<String?>? assignedToPersonId,
    Value<String?>? assignedToLocationId,
    Value<String?>? assignedToTargetId,
    Value<String?>? assignedToText,
    Value<String?>? performedByUserId,
    Value<String?>? notes,
    Value<String?>? reversedByTransactionId,
    Value<String?>? reversesTransactionId,
    Value<String?>? correctionReason,
    Value<DateTime?>? correctedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InventoryTransactionsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      transactionType: transactionType ?? this.transactionType,
      quantityDelta: quantityDelta ?? this.quantityDelta,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      fromLocationId: fromLocationId ?? this.fromLocationId,
      toLocationId: toLocationId ?? this.toLocationId,
      assignedToPersonId: assignedToPersonId ?? this.assignedToPersonId,
      assignedToLocationId: assignedToLocationId ?? this.assignedToLocationId,
      assignedToTargetId: assignedToTargetId ?? this.assignedToTargetId,
      assignedToText: assignedToText ?? this.assignedToText,
      performedByUserId: performedByUserId ?? this.performedByUserId,
      notes: notes ?? this.notes,
      reversedByTransactionId:
          reversedByTransactionId ?? this.reversedByTransactionId,
      reversesTransactionId:
          reversesTransactionId ?? this.reversesTransactionId,
      correctionReason: correctionReason ?? this.correctionReason,
      correctedAt: correctedAt ?? this.correctedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (quantityDelta.present) {
      map['quantity_delta'] = Variable<double>(quantityDelta.value);
    }
    if (unitOfMeasureId.present) {
      map['unit_of_measure_id'] = Variable<String>(unitOfMeasureId.value);
    }
    if (fromLocationId.present) {
      map['from_location_id'] = Variable<String>(fromLocationId.value);
    }
    if (toLocationId.present) {
      map['to_location_id'] = Variable<String>(toLocationId.value);
    }
    if (assignedToPersonId.present) {
      map['assigned_to_person_id'] = Variable<String>(assignedToPersonId.value);
    }
    if (assignedToLocationId.present) {
      map['assigned_to_location_id'] = Variable<String>(
        assignedToLocationId.value,
      );
    }
    if (assignedToTargetId.present) {
      map['assigned_to_target_id'] = Variable<String>(assignedToTargetId.value);
    }
    if (assignedToText.present) {
      map['assigned_to_text'] = Variable<String>(assignedToText.value);
    }
    if (performedByUserId.present) {
      map['performed_by_user_id'] = Variable<String>(performedByUserId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (reversedByTransactionId.present) {
      map['reversed_by_transaction_id'] = Variable<String>(
        reversedByTransactionId.value,
      );
    }
    if (reversesTransactionId.present) {
      map['reverses_transaction_id'] = Variable<String>(
        reversesTransactionId.value,
      );
    }
    if (correctionReason.present) {
      map['correction_reason'] = Variable<String>(correctionReason.value);
    }
    if (correctedAt.present) {
      map['corrected_at'] = Variable<DateTime>(correctedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('transactionType: $transactionType, ')
          ..write('quantityDelta: $quantityDelta, ')
          ..write('unitOfMeasureId: $unitOfMeasureId, ')
          ..write('fromLocationId: $fromLocationId, ')
          ..write('toLocationId: $toLocationId, ')
          ..write('assignedToPersonId: $assignedToPersonId, ')
          ..write('assignedToLocationId: $assignedToLocationId, ')
          ..write('assignedToTargetId: $assignedToTargetId, ')
          ..write('assignedToText: $assignedToText, ')
          ..write('performedByUserId: $performedByUserId, ')
          ..write('notes: $notes, ')
          ..write('reversedByTransactionId: $reversedByTransactionId, ')
          ..write('reversesTransactionId: $reversesTransactionId, ')
          ..write('correctionReason: $correctionReason, ')
          ..write('correctedAt: $correctedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemLocationBalancesTable extends ItemLocationBalances
    with TableInfo<$ItemLocationBalancesTable, ItemLocationBalanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemLocationBalancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityOnHandMeta = const VerificationMeta(
    'quantityOnHand',
  );
  @override
  late final GeneratedColumn<double> quantityOnHand = GeneratedColumn<double>(
    'quantity_on_hand',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minimumQuantityMeta = const VerificationMeta(
    'minimumQuantity',
  );
  @override
  late final GeneratedColumn<double> minimumQuantity = GeneratedColumn<double>(
    'minimum_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    locationId,
    quantityOnHand,
    minimumQuantity,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_location_balances';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemLocationBalanceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    if (data.containsKey('quantity_on_hand')) {
      context.handle(
        _quantityOnHandMeta,
        quantityOnHand.isAcceptableOrUnknown(
          data['quantity_on_hand']!,
          _quantityOnHandMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityOnHandMeta);
    }
    if (data.containsKey('minimum_quantity')) {
      context.handle(
        _minimumQuantityMeta,
        minimumQuantity.isAcceptableOrUnknown(
          data['minimum_quantity']!,
          _minimumQuantityMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemLocationBalanceRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemLocationBalanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      )!,
      quantityOnHand: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_on_hand'],
      )!,
      minimumQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}minimum_quantity'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ItemLocationBalancesTable createAlias(String alias) {
    return $ItemLocationBalancesTable(attachedDatabase, alias);
  }
}

class ItemLocationBalanceRecord extends DataClass
    implements Insertable<ItemLocationBalanceRecord> {
  final String id;
  final String itemId;
  final String locationId;
  final double quantityOnHand;
  final double minimumQuantity;
  final DateTime updatedAt;
  const ItemLocationBalanceRecord({
    required this.id,
    required this.itemId,
    required this.locationId,
    required this.quantityOnHand,
    required this.minimumQuantity,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['location_id'] = Variable<String>(locationId);
    map['quantity_on_hand'] = Variable<double>(quantityOnHand);
    map['minimum_quantity'] = Variable<double>(minimumQuantity);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ItemLocationBalancesCompanion toCompanion(bool nullToAbsent) {
    return ItemLocationBalancesCompanion(
      id: Value(id),
      itemId: Value(itemId),
      locationId: Value(locationId),
      quantityOnHand: Value(quantityOnHand),
      minimumQuantity: Value(minimumQuantity),
      updatedAt: Value(updatedAt),
    );
  }

  factory ItemLocationBalanceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemLocationBalanceRecord(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      locationId: serializer.fromJson<String>(json['locationId']),
      quantityOnHand: serializer.fromJson<double>(json['quantityOnHand']),
      minimumQuantity: serializer.fromJson<double>(json['minimumQuantity']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'locationId': serializer.toJson<String>(locationId),
      'quantityOnHand': serializer.toJson<double>(quantityOnHand),
      'minimumQuantity': serializer.toJson<double>(minimumQuantity),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ItemLocationBalanceRecord copyWith({
    String? id,
    String? itemId,
    String? locationId,
    double? quantityOnHand,
    double? minimumQuantity,
    DateTime? updatedAt,
  }) => ItemLocationBalanceRecord(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    locationId: locationId ?? this.locationId,
    quantityOnHand: quantityOnHand ?? this.quantityOnHand,
    minimumQuantity: minimumQuantity ?? this.minimumQuantity,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ItemLocationBalanceRecord copyWithCompanion(
    ItemLocationBalancesCompanion data,
  ) {
    return ItemLocationBalanceRecord(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      quantityOnHand: data.quantityOnHand.present
          ? data.quantityOnHand.value
          : this.quantityOnHand,
      minimumQuantity: data.minimumQuantity.present
          ? data.minimumQuantity.value
          : this.minimumQuantity,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemLocationBalanceRecord(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('locationId: $locationId, ')
          ..write('quantityOnHand: $quantityOnHand, ')
          ..write('minimumQuantity: $minimumQuantity, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    locationId,
    quantityOnHand,
    minimumQuantity,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemLocationBalanceRecord &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.locationId == this.locationId &&
          other.quantityOnHand == this.quantityOnHand &&
          other.minimumQuantity == this.minimumQuantity &&
          other.updatedAt == this.updatedAt);
}

class ItemLocationBalancesCompanion
    extends UpdateCompanion<ItemLocationBalanceRecord> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> locationId;
  final Value<double> quantityOnHand;
  final Value<double> minimumQuantity;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ItemLocationBalancesCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.locationId = const Value.absent(),
    this.quantityOnHand = const Value.absent(),
    this.minimumQuantity = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemLocationBalancesCompanion.insert({
    required String id,
    required String itemId,
    required String locationId,
    required double quantityOnHand,
    this.minimumQuantity = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       locationId = Value(locationId),
       quantityOnHand = Value(quantityOnHand),
       updatedAt = Value(updatedAt);
  static Insertable<ItemLocationBalanceRecord> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? locationId,
    Expression<double>? quantityOnHand,
    Expression<double>? minimumQuantity,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (locationId != null) 'location_id': locationId,
      if (quantityOnHand != null) 'quantity_on_hand': quantityOnHand,
      if (minimumQuantity != null) 'minimum_quantity': minimumQuantity,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemLocationBalancesCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? locationId,
    Value<double>? quantityOnHand,
    Value<double>? minimumQuantity,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ItemLocationBalancesCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      locationId: locationId ?? this.locationId,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (quantityOnHand.present) {
      map['quantity_on_hand'] = Variable<double>(quantityOnHand.value);
    }
    if (minimumQuantity.present) {
      map['minimum_quantity'] = Variable<double>(minimumQuantity.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemLocationBalancesCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('locationId: $locationId, ')
          ..write('quantityOnHand: $quantityOnHand, ')
          ..write('minimumQuantity: $minimumQuantity, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, SupplierRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactNameMeta = const VerificationMeta(
    'contactName',
  );
  @override
  late final GeneratedColumn<String> contactName = GeneratedColumn<String>(
    'contact_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _websiteMeta = const VerificationMeta(
    'website',
  );
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
    'website',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountNumberMeta = const VerificationMeta(
    'accountNumber',
  );
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
    'account_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultLeadTimeDaysMeta =
      const VerificationMeta('defaultLeadTimeDays');
  @override
  late final GeneratedColumn<int> defaultLeadTimeDays = GeneratedColumn<int>(
    'default_lead_time_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minimumOrderAmountMeta =
      const VerificationMeta('minimumOrderAmount');
  @override
  late final GeneratedColumn<double> minimumOrderAmount =
      GeneratedColumn<double>(
        'minimum_order_amount',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    contactName,
    email,
    phone,
    website,
    address,
    accountNumber,
    notes,
    defaultLeadTimeDays,
    minimumOrderAmount,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact_name')) {
      context.handle(
        _contactNameMeta,
        contactName.isAcceptableOrUnknown(
          data['contact_name']!,
          _contactNameMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('website')) {
      context.handle(
        _websiteMeta,
        website.isAcceptableOrUnknown(data['website']!, _websiteMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('account_number')) {
      context.handle(
        _accountNumberMeta,
        accountNumber.isAcceptableOrUnknown(
          data['account_number']!,
          _accountNumberMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('default_lead_time_days')) {
      context.handle(
        _defaultLeadTimeDaysMeta,
        defaultLeadTimeDays.isAcceptableOrUnknown(
          data['default_lead_time_days']!,
          _defaultLeadTimeDaysMeta,
        ),
      );
    }
    if (data.containsKey('minimum_order_amount')) {
      context.handle(
        _minimumOrderAmountMeta,
        minimumOrderAmount.isAcceptableOrUnknown(
          data['minimum_order_amount']!,
          _minimumOrderAmountMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contactName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_name'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      website: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      accountNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_number'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      defaultLeadTimeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_lead_time_days'],
      ),
      minimumOrderAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}minimum_order_amount'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class SupplierRecord extends DataClass implements Insertable<SupplierRecord> {
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
  const SupplierRecord({
    required this.id,
    required this.name,
    this.contactName,
    this.email,
    this.phone,
    this.website,
    this.address,
    this.accountNumber,
    this.notes,
    this.defaultLeadTimeDays,
    this.minimumOrderAmount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contactName != null) {
      map['contact_name'] = Variable<String>(contactName);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || accountNumber != null) {
      map['account_number'] = Variable<String>(accountNumber);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || defaultLeadTimeDays != null) {
      map['default_lead_time_days'] = Variable<int>(defaultLeadTimeDays);
    }
    if (!nullToAbsent || minimumOrderAmount != null) {
      map['minimum_order_amount'] = Variable<double>(minimumOrderAmount);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      contactName: contactName == null && nullToAbsent
          ? const Value.absent()
          : Value(contactName),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      accountNumber: accountNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(accountNumber),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      defaultLeadTimeDays: defaultLeadTimeDays == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultLeadTimeDays),
      minimumOrderAmount: minimumOrderAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumOrderAmount),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SupplierRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contactName: serializer.fromJson<String?>(json['contactName']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      website: serializer.fromJson<String?>(json['website']),
      address: serializer.fromJson<String?>(json['address']),
      accountNumber: serializer.fromJson<String?>(json['accountNumber']),
      notes: serializer.fromJson<String?>(json['notes']),
      defaultLeadTimeDays: serializer.fromJson<int?>(
        json['defaultLeadTimeDays'],
      ),
      minimumOrderAmount: serializer.fromJson<double?>(
        json['minimumOrderAmount'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'contactName': serializer.toJson<String?>(contactName),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'website': serializer.toJson<String?>(website),
      'address': serializer.toJson<String?>(address),
      'accountNumber': serializer.toJson<String?>(accountNumber),
      'notes': serializer.toJson<String?>(notes),
      'defaultLeadTimeDays': serializer.toJson<int?>(defaultLeadTimeDays),
      'minimumOrderAmount': serializer.toJson<double?>(minimumOrderAmount),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SupplierRecord copyWith({
    String? id,
    String? name,
    Value<String?> contactName = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> website = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> accountNumber = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> defaultLeadTimeDays = const Value.absent(),
    Value<double?> minimumOrderAmount = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SupplierRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    contactName: contactName.present ? contactName.value : this.contactName,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    website: website.present ? website.value : this.website,
    address: address.present ? address.value : this.address,
    accountNumber: accountNumber.present
        ? accountNumber.value
        : this.accountNumber,
    notes: notes.present ? notes.value : this.notes,
    defaultLeadTimeDays: defaultLeadTimeDays.present
        ? defaultLeadTimeDays.value
        : this.defaultLeadTimeDays,
    minimumOrderAmount: minimumOrderAmount.present
        ? minimumOrderAmount.value
        : this.minimumOrderAmount,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SupplierRecord copyWithCompanion(SuppliersCompanion data) {
    return SupplierRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contactName: data.contactName.present
          ? data.contactName.value
          : this.contactName,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      website: data.website.present ? data.website.value : this.website,
      address: data.address.present ? data.address.value : this.address,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      notes: data.notes.present ? data.notes.value : this.notes,
      defaultLeadTimeDays: data.defaultLeadTimeDays.present
          ? data.defaultLeadTimeDays.value
          : this.defaultLeadTimeDays,
      minimumOrderAmount: data.minimumOrderAmount.present
          ? data.minimumOrderAmount.value
          : this.minimumOrderAmount,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactName: $contactName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('website: $website, ')
          ..write('address: $address, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('notes: $notes, ')
          ..write('defaultLeadTimeDays: $defaultLeadTimeDays, ')
          ..write('minimumOrderAmount: $minimumOrderAmount, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    contactName,
    email,
    phone,
    website,
    address,
    accountNumber,
    notes,
    defaultLeadTimeDays,
    minimumOrderAmount,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.contactName == this.contactName &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.website == this.website &&
          other.address == this.address &&
          other.accountNumber == this.accountNumber &&
          other.notes == this.notes &&
          other.defaultLeadTimeDays == this.defaultLeadTimeDays &&
          other.minimumOrderAmount == this.minimumOrderAmount &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SuppliersCompanion extends UpdateCompanion<SupplierRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> contactName;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> website;
  final Value<String?> address;
  final Value<String?> accountNumber;
  final Value<String?> notes;
  final Value<int?> defaultLeadTimeDays;
  final Value<double?> minimumOrderAmount;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contactName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.website = const Value.absent(),
    this.address = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.defaultLeadTimeDays = const Value.absent(),
    this.minimumOrderAmount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String name,
    this.contactName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.website = const Value.absent(),
    this.address = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.defaultLeadTimeDays = const Value.absent(),
    this.minimumOrderAmount = const Value.absent(),
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       isActive = Value(isActive),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SupplierRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? contactName,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? website,
    Expression<String>? address,
    Expression<String>? accountNumber,
    Expression<String>? notes,
    Expression<int>? defaultLeadTimeDays,
    Expression<double>? minimumOrderAmount,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contactName != null) 'contact_name': contactName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      if (accountNumber != null) 'account_number': accountNumber,
      if (notes != null) 'notes': notes,
      if (defaultLeadTimeDays != null)
        'default_lead_time_days': defaultLeadTimeDays,
      if (minimumOrderAmount != null)
        'minimum_order_amount': minimumOrderAmount,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? contactName,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String?>? website,
    Value<String?>? address,
    Value<String?>? accountNumber,
    Value<String?>? notes,
    Value<int?>? defaultLeadTimeDays,
    Value<double?>? minimumOrderAmount,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contactName: contactName ?? this.contactName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      address: address ?? this.address,
      accountNumber: accountNumber ?? this.accountNumber,
      notes: notes ?? this.notes,
      defaultLeadTimeDays: defaultLeadTimeDays ?? this.defaultLeadTimeDays,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contactName.present) {
      map['contact_name'] = Variable<String>(contactName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (defaultLeadTimeDays.present) {
      map['default_lead_time_days'] = Variable<int>(defaultLeadTimeDays.value);
    }
    if (minimumOrderAmount.present) {
      map['minimum_order_amount'] = Variable<double>(minimumOrderAmount.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactName: $contactName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('website: $website, ')
          ..write('address: $address, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('notes: $notes, ')
          ..write('defaultLeadTimeDays: $defaultLeadTimeDays, ')
          ..write('minimumOrderAmount: $minimumOrderAmount, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReorderRequestsTable extends ReorderRequests
    with TableInfo<$ReorderRequestsTable, ReorderRequestRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReorderRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestedQuantityMeta = const VerificationMeta(
    'requestedQuantity',
  );
  @override
  late final GeneratedColumn<double> requestedQuantity =
      GeneratedColumn<double>(
        'requested_quantity',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _receivedQuantityMeta = const VerificationMeta(
    'receivedQuantity',
  );
  @override
  late final GeneratedColumn<double> receivedQuantity = GeneratedColumn<double>(
    'received_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unitOfMeasureIdMeta = const VerificationMeta(
    'unitOfMeasureId',
  );
  @override
  late final GeneratedColumn<String> unitOfMeasureId = GeneratedColumn<String>(
    'unit_of_measure_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierMeta = const VerificationMeta(
    'supplier',
  );
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
    'supplier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderedAtMeta = const VerificationMeta(
    'orderedAt',
  );
  @override
  late final GeneratedColumn<DateTime> orderedAt = GeneratedColumn<DateTime>(
    'ordered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByUserIdMeta = const VerificationMeta(
    'createdByUserId',
  );
  @override
  late final GeneratedColumn<String> createdByUserId = GeneratedColumn<String>(
    'created_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderedByUserIdMeta = const VerificationMeta(
    'orderedByUserId',
  );
  @override
  late final GeneratedColumn<String> orderedByUserId = GeneratedColumn<String>(
    'ordered_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedByUserIdMeta = const VerificationMeta(
    'receivedByUserId',
  );
  @override
  late final GeneratedColumn<String> receivedByUserId = GeneratedColumn<String>(
    'received_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationLocationIdMeta =
      const VerificationMeta('destinationLocationId');
  @override
  late final GeneratedColumn<String> destinationLocationId =
      GeneratedColumn<String>(
        'destination_location_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _purchaseUnitOfMeasureIdMeta =
      const VerificationMeta('purchaseUnitOfMeasureId');
  @override
  late final GeneratedColumn<String> purchaseUnitOfMeasureId =
      GeneratedColumn<String>(
        'purchase_unit_of_measure_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _purchaseQuantityMeta = const VerificationMeta(
    'purchaseQuantity',
  );
  @override
  late final GeneratedColumn<double> purchaseQuantity = GeneratedColumn<double>(
    'purchase_quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseToStockConversionFactorMeta =
      const VerificationMeta('purchaseToStockConversionFactor');
  @override
  late final GeneratedColumn<double> purchaseToStockConversionFactor =
      GeneratedColumn<double>(
        'purchase_to_stock_conversion_factor',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _expectedCostMeta = const VerificationMeta(
    'expectedCost',
  );
  @override
  late final GeneratedColumn<double> expectedCost = GeneratedColumn<double>(
    'expected_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderNumberMeta = const VerificationMeta(
    'orderNumber',
  );
  @override
  late final GeneratedColumn<String> orderNumber = GeneratedColumn<String>(
    'order_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    requestedQuantity,
    receivedQuantity,
    unitOfMeasureId,
    supplierId,
    supplier,
    status,
    notes,
    createdAt,
    orderedAt,
    receivedAt,
    cancelledAt,
    createdByUserId,
    orderedByUserId,
    receivedByUserId,
    destinationLocationId,
    purchaseUnitOfMeasureId,
    purchaseQuantity,
    purchaseToStockConversionFactor,
    expectedCost,
    orderNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reorder_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReorderRequestRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('requested_quantity')) {
      context.handle(
        _requestedQuantityMeta,
        requestedQuantity.isAcceptableOrUnknown(
          data['requested_quantity']!,
          _requestedQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedQuantityMeta);
    }
    if (data.containsKey('received_quantity')) {
      context.handle(
        _receivedQuantityMeta,
        receivedQuantity.isAcceptableOrUnknown(
          data['received_quantity']!,
          _receivedQuantityMeta,
        ),
      );
    }
    if (data.containsKey('unit_of_measure_id')) {
      context.handle(
        _unitOfMeasureIdMeta,
        unitOfMeasureId.isAcceptableOrUnknown(
          data['unit_of_measure_id']!,
          _unitOfMeasureIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitOfMeasureIdMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('supplier')) {
      context.handle(
        _supplierMeta,
        supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('ordered_at')) {
      context.handle(
        _orderedAtMeta,
        orderedAt.isAcceptableOrUnknown(data['ordered_at']!, _orderedAtMeta),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
        ),
      );
    }
    if (data.containsKey('created_by_user_id')) {
      context.handle(
        _createdByUserIdMeta,
        createdByUserId.isAcceptableOrUnknown(
          data['created_by_user_id']!,
          _createdByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('ordered_by_user_id')) {
      context.handle(
        _orderedByUserIdMeta,
        orderedByUserId.isAcceptableOrUnknown(
          data['ordered_by_user_id']!,
          _orderedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('received_by_user_id')) {
      context.handle(
        _receivedByUserIdMeta,
        receivedByUserId.isAcceptableOrUnknown(
          data['received_by_user_id']!,
          _receivedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('destination_location_id')) {
      context.handle(
        _destinationLocationIdMeta,
        destinationLocationId.isAcceptableOrUnknown(
          data['destination_location_id']!,
          _destinationLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('purchase_unit_of_measure_id')) {
      context.handle(
        _purchaseUnitOfMeasureIdMeta,
        purchaseUnitOfMeasureId.isAcceptableOrUnknown(
          data['purchase_unit_of_measure_id']!,
          _purchaseUnitOfMeasureIdMeta,
        ),
      );
    }
    if (data.containsKey('purchase_quantity')) {
      context.handle(
        _purchaseQuantityMeta,
        purchaseQuantity.isAcceptableOrUnknown(
          data['purchase_quantity']!,
          _purchaseQuantityMeta,
        ),
      );
    }
    if (data.containsKey('purchase_to_stock_conversion_factor')) {
      context.handle(
        _purchaseToStockConversionFactorMeta,
        purchaseToStockConversionFactor.isAcceptableOrUnknown(
          data['purchase_to_stock_conversion_factor']!,
          _purchaseToStockConversionFactorMeta,
        ),
      );
    }
    if (data.containsKey('expected_cost')) {
      context.handle(
        _expectedCostMeta,
        expectedCost.isAcceptableOrUnknown(
          data['expected_cost']!,
          _expectedCostMeta,
        ),
      );
    }
    if (data.containsKey('order_number')) {
      context.handle(
        _orderNumberMeta,
        orderNumber.isAcceptableOrUnknown(
          data['order_number']!,
          _orderNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReorderRequestRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReorderRequestRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      requestedQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}requested_quantity'],
      )!,
      receivedQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}received_quantity'],
      )!,
      unitOfMeasureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_of_measure_id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      supplier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      orderedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ordered_at'],
      ),
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      ),
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancelled_at'],
      ),
      createdByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_user_id'],
      ),
      orderedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ordered_by_user_id'],
      ),
      receivedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_by_user_id'],
      ),
      destinationLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_location_id'],
      ),
      purchaseUnitOfMeasureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_unit_of_measure_id'],
      ),
      purchaseQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_quantity'],
      ),
      purchaseToStockConversionFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_to_stock_conversion_factor'],
      ),
      expectedCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expected_cost'],
      ),
      orderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_number'],
      ),
    );
  }

  @override
  $ReorderRequestsTable createAlias(String alias) {
    return $ReorderRequestsTable(attachedDatabase, alias);
  }
}

class ReorderRequestRecord extends DataClass
    implements Insertable<ReorderRequestRecord> {
  final String id;
  final String itemId;
  final double requestedQuantity;
  final double receivedQuantity;
  final String unitOfMeasureId;
  final String? supplierId;
  final String? supplier;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? orderedAt;
  final DateTime? receivedAt;
  final DateTime? cancelledAt;
  final String? createdByUserId;
  final String? orderedByUserId;
  final String? receivedByUserId;
  final String? destinationLocationId;
  final String? purchaseUnitOfMeasureId;
  final double? purchaseQuantity;
  final double? purchaseToStockConversionFactor;
  final double? expectedCost;
  final String? orderNumber;
  const ReorderRequestRecord({
    required this.id,
    required this.itemId,
    required this.requestedQuantity,
    required this.receivedQuantity,
    required this.unitOfMeasureId,
    this.supplierId,
    this.supplier,
    required this.status,
    this.notes,
    required this.createdAt,
    this.orderedAt,
    this.receivedAt,
    this.cancelledAt,
    this.createdByUserId,
    this.orderedByUserId,
    this.receivedByUserId,
    this.destinationLocationId,
    this.purchaseUnitOfMeasureId,
    this.purchaseQuantity,
    this.purchaseToStockConversionFactor,
    this.expectedCost,
    this.orderNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['requested_quantity'] = Variable<double>(requestedQuantity);
    map['received_quantity'] = Variable<double>(receivedQuantity);
    map['unit_of_measure_id'] = Variable<String>(unitOfMeasureId);
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || orderedAt != null) {
      map['ordered_at'] = Variable<DateTime>(orderedAt);
    }
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<DateTime>(receivedAt);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt);
    }
    if (!nullToAbsent || createdByUserId != null) {
      map['created_by_user_id'] = Variable<String>(createdByUserId);
    }
    if (!nullToAbsent || orderedByUserId != null) {
      map['ordered_by_user_id'] = Variable<String>(orderedByUserId);
    }
    if (!nullToAbsent || receivedByUserId != null) {
      map['received_by_user_id'] = Variable<String>(receivedByUserId);
    }
    if (!nullToAbsent || destinationLocationId != null) {
      map['destination_location_id'] = Variable<String>(destinationLocationId);
    }
    if (!nullToAbsent || purchaseUnitOfMeasureId != null) {
      map['purchase_unit_of_measure_id'] = Variable<String>(
        purchaseUnitOfMeasureId,
      );
    }
    if (!nullToAbsent || purchaseQuantity != null) {
      map['purchase_quantity'] = Variable<double>(purchaseQuantity);
    }
    if (!nullToAbsent || purchaseToStockConversionFactor != null) {
      map['purchase_to_stock_conversion_factor'] = Variable<double>(
        purchaseToStockConversionFactor,
      );
    }
    if (!nullToAbsent || expectedCost != null) {
      map['expected_cost'] = Variable<double>(expectedCost);
    }
    if (!nullToAbsent || orderNumber != null) {
      map['order_number'] = Variable<String>(orderNumber);
    }
    return map;
  }

  ReorderRequestsCompanion toCompanion(bool nullToAbsent) {
    return ReorderRequestsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      requestedQuantity: Value(requestedQuantity),
      receivedQuantity: Value(receivedQuantity),
      unitOfMeasureId: Value(unitOfMeasureId),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      orderedAt: orderedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(orderedAt),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      createdByUserId: createdByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByUserId),
      orderedByUserId: orderedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(orderedByUserId),
      receivedByUserId: receivedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedByUserId),
      destinationLocationId: destinationLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationLocationId),
      purchaseUnitOfMeasureId: purchaseUnitOfMeasureId == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseUnitOfMeasureId),
      purchaseQuantity: purchaseQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseQuantity),
      purchaseToStockConversionFactor:
          purchaseToStockConversionFactor == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseToStockConversionFactor),
      expectedCost: expectedCost == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedCost),
      orderNumber: orderNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(orderNumber),
    );
  }

  factory ReorderRequestRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReorderRequestRecord(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      requestedQuantity: serializer.fromJson<double>(json['requestedQuantity']),
      receivedQuantity: serializer.fromJson<double>(json['receivedQuantity']),
      unitOfMeasureId: serializer.fromJson<String>(json['unitOfMeasureId']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      orderedAt: serializer.fromJson<DateTime?>(json['orderedAt']),
      receivedAt: serializer.fromJson<DateTime?>(json['receivedAt']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
      createdByUserId: serializer.fromJson<String?>(json['createdByUserId']),
      orderedByUserId: serializer.fromJson<String?>(json['orderedByUserId']),
      receivedByUserId: serializer.fromJson<String?>(json['receivedByUserId']),
      destinationLocationId: serializer.fromJson<String?>(
        json['destinationLocationId'],
      ),
      purchaseUnitOfMeasureId: serializer.fromJson<String?>(
        json['purchaseUnitOfMeasureId'],
      ),
      purchaseQuantity: serializer.fromJson<double?>(json['purchaseQuantity']),
      purchaseToStockConversionFactor: serializer.fromJson<double?>(
        json['purchaseToStockConversionFactor'],
      ),
      expectedCost: serializer.fromJson<double?>(json['expectedCost']),
      orderNumber: serializer.fromJson<String?>(json['orderNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'requestedQuantity': serializer.toJson<double>(requestedQuantity),
      'receivedQuantity': serializer.toJson<double>(receivedQuantity),
      'unitOfMeasureId': serializer.toJson<String>(unitOfMeasureId),
      'supplierId': serializer.toJson<String?>(supplierId),
      'supplier': serializer.toJson<String?>(supplier),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'orderedAt': serializer.toJson<DateTime?>(orderedAt),
      'receivedAt': serializer.toJson<DateTime?>(receivedAt),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
      'createdByUserId': serializer.toJson<String?>(createdByUserId),
      'orderedByUserId': serializer.toJson<String?>(orderedByUserId),
      'receivedByUserId': serializer.toJson<String?>(receivedByUserId),
      'destinationLocationId': serializer.toJson<String?>(
        destinationLocationId,
      ),
      'purchaseUnitOfMeasureId': serializer.toJson<String?>(
        purchaseUnitOfMeasureId,
      ),
      'purchaseQuantity': serializer.toJson<double?>(purchaseQuantity),
      'purchaseToStockConversionFactor': serializer.toJson<double?>(
        purchaseToStockConversionFactor,
      ),
      'expectedCost': serializer.toJson<double?>(expectedCost),
      'orderNumber': serializer.toJson<String?>(orderNumber),
    };
  }

  ReorderRequestRecord copyWith({
    String? id,
    String? itemId,
    double? requestedQuantity,
    double? receivedQuantity,
    String? unitOfMeasureId,
    Value<String?> supplierId = const Value.absent(),
    Value<String?> supplier = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> orderedAt = const Value.absent(),
    Value<DateTime?> receivedAt = const Value.absent(),
    Value<DateTime?> cancelledAt = const Value.absent(),
    Value<String?> createdByUserId = const Value.absent(),
    Value<String?> orderedByUserId = const Value.absent(),
    Value<String?> receivedByUserId = const Value.absent(),
    Value<String?> destinationLocationId = const Value.absent(),
    Value<String?> purchaseUnitOfMeasureId = const Value.absent(),
    Value<double?> purchaseQuantity = const Value.absent(),
    Value<double?> purchaseToStockConversionFactor = const Value.absent(),
    Value<double?> expectedCost = const Value.absent(),
    Value<String?> orderNumber = const Value.absent(),
  }) => ReorderRequestRecord(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    requestedQuantity: requestedQuantity ?? this.requestedQuantity,
    receivedQuantity: receivedQuantity ?? this.receivedQuantity,
    unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    supplier: supplier.present ? supplier.value : this.supplier,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    orderedAt: orderedAt.present ? orderedAt.value : this.orderedAt,
    receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
    createdByUserId: createdByUserId.present
        ? createdByUserId.value
        : this.createdByUserId,
    orderedByUserId: orderedByUserId.present
        ? orderedByUserId.value
        : this.orderedByUserId,
    receivedByUserId: receivedByUserId.present
        ? receivedByUserId.value
        : this.receivedByUserId,
    destinationLocationId: destinationLocationId.present
        ? destinationLocationId.value
        : this.destinationLocationId,
    purchaseUnitOfMeasureId: purchaseUnitOfMeasureId.present
        ? purchaseUnitOfMeasureId.value
        : this.purchaseUnitOfMeasureId,
    purchaseQuantity: purchaseQuantity.present
        ? purchaseQuantity.value
        : this.purchaseQuantity,
    purchaseToStockConversionFactor: purchaseToStockConversionFactor.present
        ? purchaseToStockConversionFactor.value
        : this.purchaseToStockConversionFactor,
    expectedCost: expectedCost.present ? expectedCost.value : this.expectedCost,
    orderNumber: orderNumber.present ? orderNumber.value : this.orderNumber,
  );
  ReorderRequestRecord copyWithCompanion(ReorderRequestsCompanion data) {
    return ReorderRequestRecord(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      requestedQuantity: data.requestedQuantity.present
          ? data.requestedQuantity.value
          : this.requestedQuantity,
      receivedQuantity: data.receivedQuantity.present
          ? data.receivedQuantity.value
          : this.receivedQuantity,
      unitOfMeasureId: data.unitOfMeasureId.present
          ? data.unitOfMeasureId.value
          : this.unitOfMeasureId,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      orderedAt: data.orderedAt.present ? data.orderedAt.value : this.orderedAt,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
      createdByUserId: data.createdByUserId.present
          ? data.createdByUserId.value
          : this.createdByUserId,
      orderedByUserId: data.orderedByUserId.present
          ? data.orderedByUserId.value
          : this.orderedByUserId,
      receivedByUserId: data.receivedByUserId.present
          ? data.receivedByUserId.value
          : this.receivedByUserId,
      destinationLocationId: data.destinationLocationId.present
          ? data.destinationLocationId.value
          : this.destinationLocationId,
      purchaseUnitOfMeasureId: data.purchaseUnitOfMeasureId.present
          ? data.purchaseUnitOfMeasureId.value
          : this.purchaseUnitOfMeasureId,
      purchaseQuantity: data.purchaseQuantity.present
          ? data.purchaseQuantity.value
          : this.purchaseQuantity,
      purchaseToStockConversionFactor:
          data.purchaseToStockConversionFactor.present
          ? data.purchaseToStockConversionFactor.value
          : this.purchaseToStockConversionFactor,
      expectedCost: data.expectedCost.present
          ? data.expectedCost.value
          : this.expectedCost,
      orderNumber: data.orderNumber.present
          ? data.orderNumber.value
          : this.orderNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReorderRequestRecord(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('requestedQuantity: $requestedQuantity, ')
          ..write('receivedQuantity: $receivedQuantity, ')
          ..write('unitOfMeasureId: $unitOfMeasureId, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplier: $supplier, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('orderedAt: $orderedAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('orderedByUserId: $orderedByUserId, ')
          ..write('receivedByUserId: $receivedByUserId, ')
          ..write('destinationLocationId: $destinationLocationId, ')
          ..write('purchaseUnitOfMeasureId: $purchaseUnitOfMeasureId, ')
          ..write('purchaseQuantity: $purchaseQuantity, ')
          ..write(
            'purchaseToStockConversionFactor: $purchaseToStockConversionFactor, ',
          )
          ..write('expectedCost: $expectedCost, ')
          ..write('orderNumber: $orderNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    itemId,
    requestedQuantity,
    receivedQuantity,
    unitOfMeasureId,
    supplierId,
    supplier,
    status,
    notes,
    createdAt,
    orderedAt,
    receivedAt,
    cancelledAt,
    createdByUserId,
    orderedByUserId,
    receivedByUserId,
    destinationLocationId,
    purchaseUnitOfMeasureId,
    purchaseQuantity,
    purchaseToStockConversionFactor,
    expectedCost,
    orderNumber,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReorderRequestRecord &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.requestedQuantity == this.requestedQuantity &&
          other.receivedQuantity == this.receivedQuantity &&
          other.unitOfMeasureId == this.unitOfMeasureId &&
          other.supplierId == this.supplierId &&
          other.supplier == this.supplier &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.orderedAt == this.orderedAt &&
          other.receivedAt == this.receivedAt &&
          other.cancelledAt == this.cancelledAt &&
          other.createdByUserId == this.createdByUserId &&
          other.orderedByUserId == this.orderedByUserId &&
          other.receivedByUserId == this.receivedByUserId &&
          other.destinationLocationId == this.destinationLocationId &&
          other.purchaseUnitOfMeasureId == this.purchaseUnitOfMeasureId &&
          other.purchaseQuantity == this.purchaseQuantity &&
          other.purchaseToStockConversionFactor ==
              this.purchaseToStockConversionFactor &&
          other.expectedCost == this.expectedCost &&
          other.orderNumber == this.orderNumber);
}

class ReorderRequestsCompanion extends UpdateCompanion<ReorderRequestRecord> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<double> requestedQuantity;
  final Value<double> receivedQuantity;
  final Value<String> unitOfMeasureId;
  final Value<String?> supplierId;
  final Value<String?> supplier;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime?> orderedAt;
  final Value<DateTime?> receivedAt;
  final Value<DateTime?> cancelledAt;
  final Value<String?> createdByUserId;
  final Value<String?> orderedByUserId;
  final Value<String?> receivedByUserId;
  final Value<String?> destinationLocationId;
  final Value<String?> purchaseUnitOfMeasureId;
  final Value<double?> purchaseQuantity;
  final Value<double?> purchaseToStockConversionFactor;
  final Value<double?> expectedCost;
  final Value<String?> orderNumber;
  final Value<int> rowid;
  const ReorderRequestsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.requestedQuantity = const Value.absent(),
    this.receivedQuantity = const Value.absent(),
    this.unitOfMeasureId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.supplier = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.orderedAt = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.orderedByUserId = const Value.absent(),
    this.receivedByUserId = const Value.absent(),
    this.destinationLocationId = const Value.absent(),
    this.purchaseUnitOfMeasureId = const Value.absent(),
    this.purchaseQuantity = const Value.absent(),
    this.purchaseToStockConversionFactor = const Value.absent(),
    this.expectedCost = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReorderRequestsCompanion.insert({
    required String id,
    required String itemId,
    required double requestedQuantity,
    this.receivedQuantity = const Value.absent(),
    required String unitOfMeasureId,
    this.supplierId = const Value.absent(),
    this.supplier = const Value.absent(),
    required String status,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.orderedAt = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.orderedByUserId = const Value.absent(),
    this.receivedByUserId = const Value.absent(),
    this.destinationLocationId = const Value.absent(),
    this.purchaseUnitOfMeasureId = const Value.absent(),
    this.purchaseQuantity = const Value.absent(),
    this.purchaseToStockConversionFactor = const Value.absent(),
    this.expectedCost = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       requestedQuantity = Value(requestedQuantity),
       unitOfMeasureId = Value(unitOfMeasureId),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<ReorderRequestRecord> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<double>? requestedQuantity,
    Expression<double>? receivedQuantity,
    Expression<String>? unitOfMeasureId,
    Expression<String>? supplierId,
    Expression<String>? supplier,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? orderedAt,
    Expression<DateTime>? receivedAt,
    Expression<DateTime>? cancelledAt,
    Expression<String>? createdByUserId,
    Expression<String>? orderedByUserId,
    Expression<String>? receivedByUserId,
    Expression<String>? destinationLocationId,
    Expression<String>? purchaseUnitOfMeasureId,
    Expression<double>? purchaseQuantity,
    Expression<double>? purchaseToStockConversionFactor,
    Expression<double>? expectedCost,
    Expression<String>? orderNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (requestedQuantity != null) 'requested_quantity': requestedQuantity,
      if (receivedQuantity != null) 'received_quantity': receivedQuantity,
      if (unitOfMeasureId != null) 'unit_of_measure_id': unitOfMeasureId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (supplier != null) 'supplier': supplier,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (orderedAt != null) 'ordered_at': orderedAt,
      if (receivedAt != null) 'received_at': receivedAt,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (orderedByUserId != null) 'ordered_by_user_id': orderedByUserId,
      if (receivedByUserId != null) 'received_by_user_id': receivedByUserId,
      if (destinationLocationId != null)
        'destination_location_id': destinationLocationId,
      if (purchaseUnitOfMeasureId != null)
        'purchase_unit_of_measure_id': purchaseUnitOfMeasureId,
      if (purchaseQuantity != null) 'purchase_quantity': purchaseQuantity,
      if (purchaseToStockConversionFactor != null)
        'purchase_to_stock_conversion_factor': purchaseToStockConversionFactor,
      if (expectedCost != null) 'expected_cost': expectedCost,
      if (orderNumber != null) 'order_number': orderNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReorderRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<double>? requestedQuantity,
    Value<double>? receivedQuantity,
    Value<String>? unitOfMeasureId,
    Value<String?>? supplierId,
    Value<String?>? supplier,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime?>? orderedAt,
    Value<DateTime?>? receivedAt,
    Value<DateTime?>? cancelledAt,
    Value<String?>? createdByUserId,
    Value<String?>? orderedByUserId,
    Value<String?>? receivedByUserId,
    Value<String?>? destinationLocationId,
    Value<String?>? purchaseUnitOfMeasureId,
    Value<double?>? purchaseQuantity,
    Value<double?>? purchaseToStockConversionFactor,
    Value<double?>? expectedCost,
    Value<String?>? orderNumber,
    Value<int>? rowid,
  }) {
    return ReorderRequestsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      supplierId: supplierId ?? this.supplierId,
      supplier: supplier ?? this.supplier,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      orderedAt: orderedAt ?? this.orderedAt,
      receivedAt: receivedAt ?? this.receivedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      orderedByUserId: orderedByUserId ?? this.orderedByUserId,
      receivedByUserId: receivedByUserId ?? this.receivedByUserId,
      destinationLocationId:
          destinationLocationId ?? this.destinationLocationId,
      purchaseUnitOfMeasureId:
          purchaseUnitOfMeasureId ?? this.purchaseUnitOfMeasureId,
      purchaseQuantity: purchaseQuantity ?? this.purchaseQuantity,
      purchaseToStockConversionFactor:
          purchaseToStockConversionFactor ??
          this.purchaseToStockConversionFactor,
      expectedCost: expectedCost ?? this.expectedCost,
      orderNumber: orderNumber ?? this.orderNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (requestedQuantity.present) {
      map['requested_quantity'] = Variable<double>(requestedQuantity.value);
    }
    if (receivedQuantity.present) {
      map['received_quantity'] = Variable<double>(receivedQuantity.value);
    }
    if (unitOfMeasureId.present) {
      map['unit_of_measure_id'] = Variable<String>(unitOfMeasureId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (orderedAt.present) {
      map['ordered_at'] = Variable<DateTime>(orderedAt.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<String>(createdByUserId.value);
    }
    if (orderedByUserId.present) {
      map['ordered_by_user_id'] = Variable<String>(orderedByUserId.value);
    }
    if (receivedByUserId.present) {
      map['received_by_user_id'] = Variable<String>(receivedByUserId.value);
    }
    if (destinationLocationId.present) {
      map['destination_location_id'] = Variable<String>(
        destinationLocationId.value,
      );
    }
    if (purchaseUnitOfMeasureId.present) {
      map['purchase_unit_of_measure_id'] = Variable<String>(
        purchaseUnitOfMeasureId.value,
      );
    }
    if (purchaseQuantity.present) {
      map['purchase_quantity'] = Variable<double>(purchaseQuantity.value);
    }
    if (purchaseToStockConversionFactor.present) {
      map['purchase_to_stock_conversion_factor'] = Variable<double>(
        purchaseToStockConversionFactor.value,
      );
    }
    if (expectedCost.present) {
      map['expected_cost'] = Variable<double>(expectedCost.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<String>(orderNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReorderRequestsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('requestedQuantity: $requestedQuantity, ')
          ..write('receivedQuantity: $receivedQuantity, ')
          ..write('unitOfMeasureId: $unitOfMeasureId, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplier: $supplier, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('orderedAt: $orderedAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('orderedByUserId: $orderedByUserId, ')
          ..write('receivedByUserId: $receivedByUserId, ')
          ..write('destinationLocationId: $destinationLocationId, ')
          ..write('purchaseUnitOfMeasureId: $purchaseUnitOfMeasureId, ')
          ..write('purchaseQuantity: $purchaseQuantity, ')
          ..write(
            'purchaseToStockConversionFactor: $purchaseToStockConversionFactor, ',
          )
          ..write('expectedCost: $expectedCost, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CheckoutRecordsTable extends CheckoutRecords
    with TableInfo<$CheckoutRecordsTable, CheckoutRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckoutRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assignedToPersonIdMeta =
      const VerificationMeta('assignedToPersonId');
  @override
  late final GeneratedColumn<String> assignedToPersonId =
      GeneratedColumn<String>(
        'assigned_to_person_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _assignedToLocationIdMeta =
      const VerificationMeta('assignedToLocationId');
  @override
  late final GeneratedColumn<String> assignedToLocationId =
      GeneratedColumn<String>(
        'assigned_to_location_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _assignedToTargetIdMeta =
      const VerificationMeta('assignedToTargetId');
  @override
  late final GeneratedColumn<String> assignedToTargetId =
      GeneratedColumn<String>(
        'assigned_to_target_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _assignedToTextMeta = const VerificationMeta(
    'assignedToText',
  );
  @override
  late final GeneratedColumn<String> assignedToText = GeneratedColumn<String>(
    'assigned_to_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityReturnedMeta = const VerificationMeta(
    'quantityReturned',
  );
  @override
  late final GeneratedColumn<double> quantityReturned = GeneratedColumn<double>(
    'quantity_returned',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceLocationIdMeta = const VerificationMeta(
    'sourceLocationId',
  );
  @override
  late final GeneratedColumn<String> sourceLocationId = GeneratedColumn<String>(
    'source_location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitOfMeasureIdMeta = const VerificationMeta(
    'unitOfMeasureId',
  );
  @override
  late final GeneratedColumn<String> unitOfMeasureId = GeneratedColumn<String>(
    'unit_of_measure_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkedOutAtMeta = const VerificationMeta(
    'checkedOutAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkedOutAt = GeneratedColumn<DateTime>(
    'checked_out_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _returnedAtMeta = const VerificationMeta(
    'returnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> returnedAt = GeneratedColumn<DateTime>(
    'returned_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkedOutByUserIdMeta =
      const VerificationMeta('checkedOutByUserId');
  @override
  late final GeneratedColumn<String> checkedOutByUserId =
      GeneratedColumn<String>(
        'checked_out_by_user_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _returnedByUserIdMeta = const VerificationMeta(
    'returnedByUserId',
  );
  @override
  late final GeneratedColumn<String> returnedByUserId = GeneratedColumn<String>(
    'returned_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _returnNotesMeta = const VerificationMeta(
    'returnNotes',
  );
  @override
  late final GeneratedColumn<String> returnNotes = GeneratedColumn<String>(
    'return_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conditionOnReturnMeta = const VerificationMeta(
    'conditionOnReturn',
  );
  @override
  late final GeneratedColumn<String> conditionOnReturn =
      GeneratedColumn<String>(
        'condition_on_return',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    assignedToPersonId,
    assignedToLocationId,
    assignedToTargetId,
    assignedToText,
    quantity,
    quantityReturned,
    sourceLocationId,
    unitOfMeasureId,
    status,
    checkedOutAt,
    dueAt,
    returnedAt,
    checkedOutByUserId,
    returnedByUserId,
    notes,
    returnNotes,
    conditionOnReturn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkout_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckoutRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('assigned_to_person_id')) {
      context.handle(
        _assignedToPersonIdMeta,
        assignedToPersonId.isAcceptableOrUnknown(
          data['assigned_to_person_id']!,
          _assignedToPersonIdMeta,
        ),
      );
    }
    if (data.containsKey('assigned_to_location_id')) {
      context.handle(
        _assignedToLocationIdMeta,
        assignedToLocationId.isAcceptableOrUnknown(
          data['assigned_to_location_id']!,
          _assignedToLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('assigned_to_target_id')) {
      context.handle(
        _assignedToTargetIdMeta,
        assignedToTargetId.isAcceptableOrUnknown(
          data['assigned_to_target_id']!,
          _assignedToTargetIdMeta,
        ),
      );
    }
    if (data.containsKey('assigned_to_text')) {
      context.handle(
        _assignedToTextMeta,
        assignedToText.isAcceptableOrUnknown(
          data['assigned_to_text']!,
          _assignedToTextMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('quantity_returned')) {
      context.handle(
        _quantityReturnedMeta,
        quantityReturned.isAcceptableOrUnknown(
          data['quantity_returned']!,
          _quantityReturnedMeta,
        ),
      );
    }
    if (data.containsKey('source_location_id')) {
      context.handle(
        _sourceLocationIdMeta,
        sourceLocationId.isAcceptableOrUnknown(
          data['source_location_id']!,
          _sourceLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('unit_of_measure_id')) {
      context.handle(
        _unitOfMeasureIdMeta,
        unitOfMeasureId.isAcceptableOrUnknown(
          data['unit_of_measure_id']!,
          _unitOfMeasureIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitOfMeasureIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('checked_out_at')) {
      context.handle(
        _checkedOutAtMeta,
        checkedOutAt.isAcceptableOrUnknown(
          data['checked_out_at']!,
          _checkedOutAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkedOutAtMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('returned_at')) {
      context.handle(
        _returnedAtMeta,
        returnedAt.isAcceptableOrUnknown(data['returned_at']!, _returnedAtMeta),
      );
    }
    if (data.containsKey('checked_out_by_user_id')) {
      context.handle(
        _checkedOutByUserIdMeta,
        checkedOutByUserId.isAcceptableOrUnknown(
          data['checked_out_by_user_id']!,
          _checkedOutByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('returned_by_user_id')) {
      context.handle(
        _returnedByUserIdMeta,
        returnedByUserId.isAcceptableOrUnknown(
          data['returned_by_user_id']!,
          _returnedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('return_notes')) {
      context.handle(
        _returnNotesMeta,
        returnNotes.isAcceptableOrUnknown(
          data['return_notes']!,
          _returnNotesMeta,
        ),
      );
    }
    if (data.containsKey('condition_on_return')) {
      context.handle(
        _conditionOnReturnMeta,
        conditionOnReturn.isAcceptableOrUnknown(
          data['condition_on_return']!,
          _conditionOnReturnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CheckoutRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckoutRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      assignedToPersonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to_person_id'],
      ),
      assignedToLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to_location_id'],
      ),
      assignedToTargetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to_target_id'],
      ),
      assignedToText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to_text'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      quantityReturned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_returned'],
      )!,
      sourceLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_location_id'],
      ),
      unitOfMeasureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_of_measure_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      checkedOutAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_out_at'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      returnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}returned_at'],
      ),
      checkedOutByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checked_out_by_user_id'],
      ),
      returnedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}returned_by_user_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      returnNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}return_notes'],
      ),
      conditionOnReturn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_on_return'],
      ),
    );
  }

  @override
  $CheckoutRecordsTable createAlias(String alias) {
    return $CheckoutRecordsTable(attachedDatabase, alias);
  }
}

class CheckoutRecordRow extends DataClass
    implements Insertable<CheckoutRecordRow> {
  final String id;
  final String itemId;
  final String? assignedToPersonId;
  final String? assignedToLocationId;
  final String? assignedToTargetId;
  final String? assignedToText;
  final double quantity;
  final double quantityReturned;
  final String? sourceLocationId;
  final String unitOfMeasureId;
  final String status;
  final DateTime checkedOutAt;
  final DateTime? dueAt;
  final DateTime? returnedAt;
  final String? checkedOutByUserId;
  final String? returnedByUserId;
  final String? notes;
  final String? returnNotes;
  final String? conditionOnReturn;
  const CheckoutRecordRow({
    required this.id,
    required this.itemId,
    this.assignedToPersonId,
    this.assignedToLocationId,
    this.assignedToTargetId,
    this.assignedToText,
    required this.quantity,
    required this.quantityReturned,
    this.sourceLocationId,
    required this.unitOfMeasureId,
    required this.status,
    required this.checkedOutAt,
    this.dueAt,
    this.returnedAt,
    this.checkedOutByUserId,
    this.returnedByUserId,
    this.notes,
    this.returnNotes,
    this.conditionOnReturn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || assignedToPersonId != null) {
      map['assigned_to_person_id'] = Variable<String>(assignedToPersonId);
    }
    if (!nullToAbsent || assignedToLocationId != null) {
      map['assigned_to_location_id'] = Variable<String>(assignedToLocationId);
    }
    if (!nullToAbsent || assignedToTargetId != null) {
      map['assigned_to_target_id'] = Variable<String>(assignedToTargetId);
    }
    if (!nullToAbsent || assignedToText != null) {
      map['assigned_to_text'] = Variable<String>(assignedToText);
    }
    map['quantity'] = Variable<double>(quantity);
    map['quantity_returned'] = Variable<double>(quantityReturned);
    if (!nullToAbsent || sourceLocationId != null) {
      map['source_location_id'] = Variable<String>(sourceLocationId);
    }
    map['unit_of_measure_id'] = Variable<String>(unitOfMeasureId);
    map['status'] = Variable<String>(status);
    map['checked_out_at'] = Variable<DateTime>(checkedOutAt);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || returnedAt != null) {
      map['returned_at'] = Variable<DateTime>(returnedAt);
    }
    if (!nullToAbsent || checkedOutByUserId != null) {
      map['checked_out_by_user_id'] = Variable<String>(checkedOutByUserId);
    }
    if (!nullToAbsent || returnedByUserId != null) {
      map['returned_by_user_id'] = Variable<String>(returnedByUserId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || returnNotes != null) {
      map['return_notes'] = Variable<String>(returnNotes);
    }
    if (!nullToAbsent || conditionOnReturn != null) {
      map['condition_on_return'] = Variable<String>(conditionOnReturn);
    }
    return map;
  }

  CheckoutRecordsCompanion toCompanion(bool nullToAbsent) {
    return CheckoutRecordsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      assignedToPersonId: assignedToPersonId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToPersonId),
      assignedToLocationId: assignedToLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToLocationId),
      assignedToTargetId: assignedToTargetId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToTargetId),
      assignedToText: assignedToText == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToText),
      quantity: Value(quantity),
      quantityReturned: Value(quantityReturned),
      sourceLocationId: sourceLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceLocationId),
      unitOfMeasureId: Value(unitOfMeasureId),
      status: Value(status),
      checkedOutAt: Value(checkedOutAt),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      returnedAt: returnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedAt),
      checkedOutByUserId: checkedOutByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedOutByUserId),
      returnedByUserId: returnedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedByUserId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      returnNotes: returnNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(returnNotes),
      conditionOnReturn: conditionOnReturn == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionOnReturn),
    );
  }

  factory CheckoutRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckoutRecordRow(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      assignedToPersonId: serializer.fromJson<String?>(
        json['assignedToPersonId'],
      ),
      assignedToLocationId: serializer.fromJson<String?>(
        json['assignedToLocationId'],
      ),
      assignedToTargetId: serializer.fromJson<String?>(
        json['assignedToTargetId'],
      ),
      assignedToText: serializer.fromJson<String?>(json['assignedToText']),
      quantity: serializer.fromJson<double>(json['quantity']),
      quantityReturned: serializer.fromJson<double>(json['quantityReturned']),
      sourceLocationId: serializer.fromJson<String?>(json['sourceLocationId']),
      unitOfMeasureId: serializer.fromJson<String>(json['unitOfMeasureId']),
      status: serializer.fromJson<String>(json['status']),
      checkedOutAt: serializer.fromJson<DateTime>(json['checkedOutAt']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      returnedAt: serializer.fromJson<DateTime?>(json['returnedAt']),
      checkedOutByUserId: serializer.fromJson<String?>(
        json['checkedOutByUserId'],
      ),
      returnedByUserId: serializer.fromJson<String?>(json['returnedByUserId']),
      notes: serializer.fromJson<String?>(json['notes']),
      returnNotes: serializer.fromJson<String?>(json['returnNotes']),
      conditionOnReturn: serializer.fromJson<String?>(
        json['conditionOnReturn'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'assignedToPersonId': serializer.toJson<String?>(assignedToPersonId),
      'assignedToLocationId': serializer.toJson<String?>(assignedToLocationId),
      'assignedToTargetId': serializer.toJson<String?>(assignedToTargetId),
      'assignedToText': serializer.toJson<String?>(assignedToText),
      'quantity': serializer.toJson<double>(quantity),
      'quantityReturned': serializer.toJson<double>(quantityReturned),
      'sourceLocationId': serializer.toJson<String?>(sourceLocationId),
      'unitOfMeasureId': serializer.toJson<String>(unitOfMeasureId),
      'status': serializer.toJson<String>(status),
      'checkedOutAt': serializer.toJson<DateTime>(checkedOutAt),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'returnedAt': serializer.toJson<DateTime?>(returnedAt),
      'checkedOutByUserId': serializer.toJson<String?>(checkedOutByUserId),
      'returnedByUserId': serializer.toJson<String?>(returnedByUserId),
      'notes': serializer.toJson<String?>(notes),
      'returnNotes': serializer.toJson<String?>(returnNotes),
      'conditionOnReturn': serializer.toJson<String?>(conditionOnReturn),
    };
  }

  CheckoutRecordRow copyWith({
    String? id,
    String? itemId,
    Value<String?> assignedToPersonId = const Value.absent(),
    Value<String?> assignedToLocationId = const Value.absent(),
    Value<String?> assignedToTargetId = const Value.absent(),
    Value<String?> assignedToText = const Value.absent(),
    double? quantity,
    double? quantityReturned,
    Value<String?> sourceLocationId = const Value.absent(),
    String? unitOfMeasureId,
    String? status,
    DateTime? checkedOutAt,
    Value<DateTime?> dueAt = const Value.absent(),
    Value<DateTime?> returnedAt = const Value.absent(),
    Value<String?> checkedOutByUserId = const Value.absent(),
    Value<String?> returnedByUserId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> returnNotes = const Value.absent(),
    Value<String?> conditionOnReturn = const Value.absent(),
  }) => CheckoutRecordRow(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    assignedToPersonId: assignedToPersonId.present
        ? assignedToPersonId.value
        : this.assignedToPersonId,
    assignedToLocationId: assignedToLocationId.present
        ? assignedToLocationId.value
        : this.assignedToLocationId,
    assignedToTargetId: assignedToTargetId.present
        ? assignedToTargetId.value
        : this.assignedToTargetId,
    assignedToText: assignedToText.present
        ? assignedToText.value
        : this.assignedToText,
    quantity: quantity ?? this.quantity,
    quantityReturned: quantityReturned ?? this.quantityReturned,
    sourceLocationId: sourceLocationId.present
        ? sourceLocationId.value
        : this.sourceLocationId,
    unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
    status: status ?? this.status,
    checkedOutAt: checkedOutAt ?? this.checkedOutAt,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    returnedAt: returnedAt.present ? returnedAt.value : this.returnedAt,
    checkedOutByUserId: checkedOutByUserId.present
        ? checkedOutByUserId.value
        : this.checkedOutByUserId,
    returnedByUserId: returnedByUserId.present
        ? returnedByUserId.value
        : this.returnedByUserId,
    notes: notes.present ? notes.value : this.notes,
    returnNotes: returnNotes.present ? returnNotes.value : this.returnNotes,
    conditionOnReturn: conditionOnReturn.present
        ? conditionOnReturn.value
        : this.conditionOnReturn,
  );
  CheckoutRecordRow copyWithCompanion(CheckoutRecordsCompanion data) {
    return CheckoutRecordRow(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      assignedToPersonId: data.assignedToPersonId.present
          ? data.assignedToPersonId.value
          : this.assignedToPersonId,
      assignedToLocationId: data.assignedToLocationId.present
          ? data.assignedToLocationId.value
          : this.assignedToLocationId,
      assignedToTargetId: data.assignedToTargetId.present
          ? data.assignedToTargetId.value
          : this.assignedToTargetId,
      assignedToText: data.assignedToText.present
          ? data.assignedToText.value
          : this.assignedToText,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      quantityReturned: data.quantityReturned.present
          ? data.quantityReturned.value
          : this.quantityReturned,
      sourceLocationId: data.sourceLocationId.present
          ? data.sourceLocationId.value
          : this.sourceLocationId,
      unitOfMeasureId: data.unitOfMeasureId.present
          ? data.unitOfMeasureId.value
          : this.unitOfMeasureId,
      status: data.status.present ? data.status.value : this.status,
      checkedOutAt: data.checkedOutAt.present
          ? data.checkedOutAt.value
          : this.checkedOutAt,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      returnedAt: data.returnedAt.present
          ? data.returnedAt.value
          : this.returnedAt,
      checkedOutByUserId: data.checkedOutByUserId.present
          ? data.checkedOutByUserId.value
          : this.checkedOutByUserId,
      returnedByUserId: data.returnedByUserId.present
          ? data.returnedByUserId.value
          : this.returnedByUserId,
      notes: data.notes.present ? data.notes.value : this.notes,
      returnNotes: data.returnNotes.present
          ? data.returnNotes.value
          : this.returnNotes,
      conditionOnReturn: data.conditionOnReturn.present
          ? data.conditionOnReturn.value
          : this.conditionOnReturn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckoutRecordRow(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('assignedToPersonId: $assignedToPersonId, ')
          ..write('assignedToLocationId: $assignedToLocationId, ')
          ..write('assignedToTargetId: $assignedToTargetId, ')
          ..write('assignedToText: $assignedToText, ')
          ..write('quantity: $quantity, ')
          ..write('quantityReturned: $quantityReturned, ')
          ..write('sourceLocationId: $sourceLocationId, ')
          ..write('unitOfMeasureId: $unitOfMeasureId, ')
          ..write('status: $status, ')
          ..write('checkedOutAt: $checkedOutAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('returnedAt: $returnedAt, ')
          ..write('checkedOutByUserId: $checkedOutByUserId, ')
          ..write('returnedByUserId: $returnedByUserId, ')
          ..write('notes: $notes, ')
          ..write('returnNotes: $returnNotes, ')
          ..write('conditionOnReturn: $conditionOnReturn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    assignedToPersonId,
    assignedToLocationId,
    assignedToTargetId,
    assignedToText,
    quantity,
    quantityReturned,
    sourceLocationId,
    unitOfMeasureId,
    status,
    checkedOutAt,
    dueAt,
    returnedAt,
    checkedOutByUserId,
    returnedByUserId,
    notes,
    returnNotes,
    conditionOnReturn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckoutRecordRow &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.assignedToPersonId == this.assignedToPersonId &&
          other.assignedToLocationId == this.assignedToLocationId &&
          other.assignedToTargetId == this.assignedToTargetId &&
          other.assignedToText == this.assignedToText &&
          other.quantity == this.quantity &&
          other.quantityReturned == this.quantityReturned &&
          other.sourceLocationId == this.sourceLocationId &&
          other.unitOfMeasureId == this.unitOfMeasureId &&
          other.status == this.status &&
          other.checkedOutAt == this.checkedOutAt &&
          other.dueAt == this.dueAt &&
          other.returnedAt == this.returnedAt &&
          other.checkedOutByUserId == this.checkedOutByUserId &&
          other.returnedByUserId == this.returnedByUserId &&
          other.notes == this.notes &&
          other.returnNotes == this.returnNotes &&
          other.conditionOnReturn == this.conditionOnReturn);
}

class CheckoutRecordsCompanion extends UpdateCompanion<CheckoutRecordRow> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> assignedToPersonId;
  final Value<String?> assignedToLocationId;
  final Value<String?> assignedToTargetId;
  final Value<String?> assignedToText;
  final Value<double> quantity;
  final Value<double> quantityReturned;
  final Value<String?> sourceLocationId;
  final Value<String> unitOfMeasureId;
  final Value<String> status;
  final Value<DateTime> checkedOutAt;
  final Value<DateTime?> dueAt;
  final Value<DateTime?> returnedAt;
  final Value<String?> checkedOutByUserId;
  final Value<String?> returnedByUserId;
  final Value<String?> notes;
  final Value<String?> returnNotes;
  final Value<String?> conditionOnReturn;
  final Value<int> rowid;
  const CheckoutRecordsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.assignedToPersonId = const Value.absent(),
    this.assignedToLocationId = const Value.absent(),
    this.assignedToTargetId = const Value.absent(),
    this.assignedToText = const Value.absent(),
    this.quantity = const Value.absent(),
    this.quantityReturned = const Value.absent(),
    this.sourceLocationId = const Value.absent(),
    this.unitOfMeasureId = const Value.absent(),
    this.status = const Value.absent(),
    this.checkedOutAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.returnedAt = const Value.absent(),
    this.checkedOutByUserId = const Value.absent(),
    this.returnedByUserId = const Value.absent(),
    this.notes = const Value.absent(),
    this.returnNotes = const Value.absent(),
    this.conditionOnReturn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CheckoutRecordsCompanion.insert({
    required String id,
    required String itemId,
    this.assignedToPersonId = const Value.absent(),
    this.assignedToLocationId = const Value.absent(),
    this.assignedToTargetId = const Value.absent(),
    this.assignedToText = const Value.absent(),
    required double quantity,
    this.quantityReturned = const Value.absent(),
    this.sourceLocationId = const Value.absent(),
    required String unitOfMeasureId,
    required String status,
    required DateTime checkedOutAt,
    this.dueAt = const Value.absent(),
    this.returnedAt = const Value.absent(),
    this.checkedOutByUserId = const Value.absent(),
    this.returnedByUserId = const Value.absent(),
    this.notes = const Value.absent(),
    this.returnNotes = const Value.absent(),
    this.conditionOnReturn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       quantity = Value(quantity),
       unitOfMeasureId = Value(unitOfMeasureId),
       status = Value(status),
       checkedOutAt = Value(checkedOutAt);
  static Insertable<CheckoutRecordRow> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? assignedToPersonId,
    Expression<String>? assignedToLocationId,
    Expression<String>? assignedToTargetId,
    Expression<String>? assignedToText,
    Expression<double>? quantity,
    Expression<double>? quantityReturned,
    Expression<String>? sourceLocationId,
    Expression<String>? unitOfMeasureId,
    Expression<String>? status,
    Expression<DateTime>? checkedOutAt,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? returnedAt,
    Expression<String>? checkedOutByUserId,
    Expression<String>? returnedByUserId,
    Expression<String>? notes,
    Expression<String>? returnNotes,
    Expression<String>? conditionOnReturn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (assignedToPersonId != null)
        'assigned_to_person_id': assignedToPersonId,
      if (assignedToLocationId != null)
        'assigned_to_location_id': assignedToLocationId,
      if (assignedToTargetId != null)
        'assigned_to_target_id': assignedToTargetId,
      if (assignedToText != null) 'assigned_to_text': assignedToText,
      if (quantity != null) 'quantity': quantity,
      if (quantityReturned != null) 'quantity_returned': quantityReturned,
      if (sourceLocationId != null) 'source_location_id': sourceLocationId,
      if (unitOfMeasureId != null) 'unit_of_measure_id': unitOfMeasureId,
      if (status != null) 'status': status,
      if (checkedOutAt != null) 'checked_out_at': checkedOutAt,
      if (dueAt != null) 'due_at': dueAt,
      if (returnedAt != null) 'returned_at': returnedAt,
      if (checkedOutByUserId != null)
        'checked_out_by_user_id': checkedOutByUserId,
      if (returnedByUserId != null) 'returned_by_user_id': returnedByUserId,
      if (notes != null) 'notes': notes,
      if (returnNotes != null) 'return_notes': returnNotes,
      if (conditionOnReturn != null) 'condition_on_return': conditionOnReturn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CheckoutRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String?>? assignedToPersonId,
    Value<String?>? assignedToLocationId,
    Value<String?>? assignedToTargetId,
    Value<String?>? assignedToText,
    Value<double>? quantity,
    Value<double>? quantityReturned,
    Value<String?>? sourceLocationId,
    Value<String>? unitOfMeasureId,
    Value<String>? status,
    Value<DateTime>? checkedOutAt,
    Value<DateTime?>? dueAt,
    Value<DateTime?>? returnedAt,
    Value<String?>? checkedOutByUserId,
    Value<String?>? returnedByUserId,
    Value<String?>? notes,
    Value<String?>? returnNotes,
    Value<String?>? conditionOnReturn,
    Value<int>? rowid,
  }) {
    return CheckoutRecordsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      assignedToPersonId: assignedToPersonId ?? this.assignedToPersonId,
      assignedToLocationId: assignedToLocationId ?? this.assignedToLocationId,
      assignedToTargetId: assignedToTargetId ?? this.assignedToTargetId,
      assignedToText: assignedToText ?? this.assignedToText,
      quantity: quantity ?? this.quantity,
      quantityReturned: quantityReturned ?? this.quantityReturned,
      sourceLocationId: sourceLocationId ?? this.sourceLocationId,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      status: status ?? this.status,
      checkedOutAt: checkedOutAt ?? this.checkedOutAt,
      dueAt: dueAt ?? this.dueAt,
      returnedAt: returnedAt ?? this.returnedAt,
      checkedOutByUserId: checkedOutByUserId ?? this.checkedOutByUserId,
      returnedByUserId: returnedByUserId ?? this.returnedByUserId,
      notes: notes ?? this.notes,
      returnNotes: returnNotes ?? this.returnNotes,
      conditionOnReturn: conditionOnReturn ?? this.conditionOnReturn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (assignedToPersonId.present) {
      map['assigned_to_person_id'] = Variable<String>(assignedToPersonId.value);
    }
    if (assignedToLocationId.present) {
      map['assigned_to_location_id'] = Variable<String>(
        assignedToLocationId.value,
      );
    }
    if (assignedToTargetId.present) {
      map['assigned_to_target_id'] = Variable<String>(assignedToTargetId.value);
    }
    if (assignedToText.present) {
      map['assigned_to_text'] = Variable<String>(assignedToText.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (quantityReturned.present) {
      map['quantity_returned'] = Variable<double>(quantityReturned.value);
    }
    if (sourceLocationId.present) {
      map['source_location_id'] = Variable<String>(sourceLocationId.value);
    }
    if (unitOfMeasureId.present) {
      map['unit_of_measure_id'] = Variable<String>(unitOfMeasureId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (checkedOutAt.present) {
      map['checked_out_at'] = Variable<DateTime>(checkedOutAt.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (returnedAt.present) {
      map['returned_at'] = Variable<DateTime>(returnedAt.value);
    }
    if (checkedOutByUserId.present) {
      map['checked_out_by_user_id'] = Variable<String>(
        checkedOutByUserId.value,
      );
    }
    if (returnedByUserId.present) {
      map['returned_by_user_id'] = Variable<String>(returnedByUserId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (returnNotes.present) {
      map['return_notes'] = Variable<String>(returnNotes.value);
    }
    if (conditionOnReturn.present) {
      map['condition_on_return'] = Variable<String>(conditionOnReturn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckoutRecordsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('assignedToPersonId: $assignedToPersonId, ')
          ..write('assignedToLocationId: $assignedToLocationId, ')
          ..write('assignedToTargetId: $assignedToTargetId, ')
          ..write('assignedToText: $assignedToText, ')
          ..write('quantity: $quantity, ')
          ..write('quantityReturned: $quantityReturned, ')
          ..write('sourceLocationId: $sourceLocationId, ')
          ..write('unitOfMeasureId: $unitOfMeasureId, ')
          ..write('status: $status, ')
          ..write('checkedOutAt: $checkedOutAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('returnedAt: $returnedAt, ')
          ..write('checkedOutByUserId: $checkedOutByUserId, ')
          ..write('returnedByUserId: $returnedByUserId, ')
          ..write('notes: $notes, ')
          ..write('returnNotes: $returnNotes, ')
          ..write('conditionOnReturn: $conditionOnReturn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssignmentTargetsTable extends AssignmentTargets
    with TableInfo<$AssignmentTargetsTable, AssignmentTargetRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignmentTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    targetType,
    code,
    description,
    locationId,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assignment_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssignmentTargetRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssignmentTargetRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssignmentTargetRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AssignmentTargetsTable createAlias(String alias) {
    return $AssignmentTargetsTable(attachedDatabase, alias);
  }
}

class AssignmentTargetRecord extends DataClass
    implements Insertable<AssignmentTargetRecord> {
  final String id;
  final String name;
  final String targetType;
  final String? code;
  final String? description;
  final String? locationId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AssignmentTargetRecord({
    required this.id,
    required this.name,
    required this.targetType,
    this.code,
    this.description,
    this.locationId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['target_type'] = Variable<String>(targetType);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AssignmentTargetsCompanion toCompanion(bool nullToAbsent) {
    return AssignmentTargetsCompanion(
      id: Value(id),
      name: Value(name),
      targetType: Value(targetType),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AssignmentTargetRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssignmentTargetRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetType: serializer.fromJson<String>(json['targetType']),
      code: serializer.fromJson<String?>(json['code']),
      description: serializer.fromJson<String?>(json['description']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'targetType': serializer.toJson<String>(targetType),
      'code': serializer.toJson<String?>(code),
      'description': serializer.toJson<String?>(description),
      'locationId': serializer.toJson<String?>(locationId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AssignmentTargetRecord copyWith({
    String? id,
    String? name,
    String? targetType,
    Value<String?> code = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> locationId = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AssignmentTargetRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    targetType: targetType ?? this.targetType,
    code: code.present ? code.value : this.code,
    description: description.present ? description.value : this.description,
    locationId: locationId.present ? locationId.value : this.locationId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AssignmentTargetRecord copyWithCompanion(AssignmentTargetsCompanion data) {
    return AssignmentTargetRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      code: data.code.present ? data.code.value : this.code,
      description: data.description.present
          ? data.description.value
          : this.description,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentTargetRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetType: $targetType, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('locationId: $locationId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    targetType,
    code,
    description,
    locationId,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssignmentTargetRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetType == this.targetType &&
          other.code == this.code &&
          other.description == this.description &&
          other.locationId == this.locationId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AssignmentTargetsCompanion
    extends UpdateCompanion<AssignmentTargetRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> targetType;
  final Value<String?> code;
  final Value<String?> description;
  final Value<String?> locationId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AssignmentTargetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetType = const Value.absent(),
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.locationId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssignmentTargetsCompanion.insert({
    required String id,
    required String name,
    required String targetType,
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.locationId = const Value.absent(),
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       targetType = Value(targetType),
       isActive = Value(isActive),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AssignmentTargetRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? targetType,
    Expression<String>? code,
    Expression<String>? description,
    Expression<String>? locationId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetType != null) 'target_type': targetType,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (locationId != null) 'location_id': locationId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssignmentTargetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? targetType,
    Value<String?>? code,
    Value<String?>? description,
    Value<String?>? locationId,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AssignmentTargetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetType: targetType ?? this.targetType,
      code: code ?? this.code,
      description: description ?? this.description,
      locationId: locationId ?? this.locationId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentTargetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetType: $targetType, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('locationId: $locationId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CycleCountSessionsTable extends CycleCountSessions
    with TableInfo<$CycleCountSessionsTable, CycleCountSessionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CycleCountSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assignedToUserIdMeta = const VerificationMeta(
    'assignedToUserId',
  );
  @override
  late final GeneratedColumn<String> assignedToUserId = GeneratedColumn<String>(
    'assigned_to_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blindCountMeta = const VerificationMeta(
    'blindCount',
  );
  @override
  late final GeneratedColumn<bool> blindCount = GeneratedColumn<bool>(
    'blind_count',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("blind_count" IN (0, 1))',
    ),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
    'submitted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _approvedAtMeta = const VerificationMeta(
    'approvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> approvedAt = GeneratedColumn<DateTime>(
    'approved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    status,
    assignedToUserId,
    blindCount,
    dueAt,
    createdAt,
    submittedAt,
    approvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_count_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CycleCountSessionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('assigned_to_user_id')) {
      context.handle(
        _assignedToUserIdMeta,
        assignedToUserId.isAcceptableOrUnknown(
          data['assigned_to_user_id']!,
          _assignedToUserIdMeta,
        ),
      );
    }
    if (data.containsKey('blind_count')) {
      context.handle(
        _blindCountMeta,
        blindCount.isAcceptableOrUnknown(data['blind_count']!, _blindCountMeta),
      );
    } else if (isInserting) {
      context.missing(_blindCountMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    }
    if (data.containsKey('approved_at')) {
      context.handle(
        _approvedAtMeta,
        approvedAt.isAcceptableOrUnknown(data['approved_at']!, _approvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CycleCountSessionRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CycleCountSessionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      assignedToUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to_user_id'],
      ),
      blindCount: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}blind_count'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submitted_at'],
      ),
      approvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}approved_at'],
      ),
    );
  }

  @override
  $CycleCountSessionsTable createAlias(String alias) {
    return $CycleCountSessionsTable(attachedDatabase, alias);
  }
}

class CycleCountSessionRecord extends DataClass
    implements Insertable<CycleCountSessionRecord> {
  final String id;
  final String name;
  final String status;
  final String? assignedToUserId;
  final bool blindCount;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  const CycleCountSessionRecord({
    required this.id,
    required this.name,
    required this.status,
    this.assignedToUserId,
    required this.blindCount,
    this.dueAt,
    required this.createdAt,
    this.submittedAt,
    this.approvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || assignedToUserId != null) {
      map['assigned_to_user_id'] = Variable<String>(assignedToUserId);
    }
    map['blind_count'] = Variable<bool>(blindCount);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || submittedAt != null) {
      map['submitted_at'] = Variable<DateTime>(submittedAt);
    }
    if (!nullToAbsent || approvedAt != null) {
      map['approved_at'] = Variable<DateTime>(approvedAt);
    }
    return map;
  }

  CycleCountSessionsCompanion toCompanion(bool nullToAbsent) {
    return CycleCountSessionsCompanion(
      id: Value(id),
      name: Value(name),
      status: Value(status),
      assignedToUserId: assignedToUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToUserId),
      blindCount: Value(blindCount),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      createdAt: Value(createdAt),
      submittedAt: submittedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedAt),
      approvedAt: approvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedAt),
    );
  }

  factory CycleCountSessionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CycleCountSessionRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      status: serializer.fromJson<String>(json['status']),
      assignedToUserId: serializer.fromJson<String?>(json['assignedToUserId']),
      blindCount: serializer.fromJson<bool>(json['blindCount']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      submittedAt: serializer.fromJson<DateTime?>(json['submittedAt']),
      approvedAt: serializer.fromJson<DateTime?>(json['approvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(status),
      'assignedToUserId': serializer.toJson<String?>(assignedToUserId),
      'blindCount': serializer.toJson<bool>(blindCount),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'submittedAt': serializer.toJson<DateTime?>(submittedAt),
      'approvedAt': serializer.toJson<DateTime?>(approvedAt),
    };
  }

  CycleCountSessionRecord copyWith({
    String? id,
    String? name,
    String? status,
    Value<String?> assignedToUserId = const Value.absent(),
    bool? blindCount,
    Value<DateTime?> dueAt = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> submittedAt = const Value.absent(),
    Value<DateTime?> approvedAt = const Value.absent(),
  }) => CycleCountSessionRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    status: status ?? this.status,
    assignedToUserId: assignedToUserId.present
        ? assignedToUserId.value
        : this.assignedToUserId,
    blindCount: blindCount ?? this.blindCount,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    createdAt: createdAt ?? this.createdAt,
    submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
    approvedAt: approvedAt.present ? approvedAt.value : this.approvedAt,
  );
  CycleCountSessionRecord copyWithCompanion(CycleCountSessionsCompanion data) {
    return CycleCountSessionRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      assignedToUserId: data.assignedToUserId.present
          ? data.assignedToUserId.value
          : this.assignedToUserId,
      blindCount: data.blindCount.present
          ? data.blindCount.value
          : this.blindCount,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
      approvedAt: data.approvedAt.present
          ? data.approvedAt.value
          : this.approvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CycleCountSessionRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('assignedToUserId: $assignedToUserId, ')
          ..write('blindCount: $blindCount, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('approvedAt: $approvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    status,
    assignedToUserId,
    blindCount,
    dueAt,
    createdAt,
    submittedAt,
    approvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CycleCountSessionRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.status == this.status &&
          other.assignedToUserId == this.assignedToUserId &&
          other.blindCount == this.blindCount &&
          other.dueAt == this.dueAt &&
          other.createdAt == this.createdAt &&
          other.submittedAt == this.submittedAt &&
          other.approvedAt == this.approvedAt);
}

class CycleCountSessionsCompanion
    extends UpdateCompanion<CycleCountSessionRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> status;
  final Value<String?> assignedToUserId;
  final Value<bool> blindCount;
  final Value<DateTime?> dueAt;
  final Value<DateTime> createdAt;
  final Value<DateTime?> submittedAt;
  final Value<DateTime?> approvedAt;
  final Value<int> rowid;
  const CycleCountSessionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.assignedToUserId = const Value.absent(),
    this.blindCount = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CycleCountSessionsCompanion.insert({
    required String id,
    required String name,
    required String status,
    this.assignedToUserId = const Value.absent(),
    required bool blindCount,
    this.dueAt = const Value.absent(),
    required DateTime createdAt,
    this.submittedAt = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       status = Value(status),
       blindCount = Value(blindCount),
       createdAt = Value(createdAt);
  static Insertable<CycleCountSessionRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? status,
    Expression<String>? assignedToUserId,
    Expression<bool>? blindCount,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? submittedAt,
    Expression<DateTime>? approvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (assignedToUserId != null) 'assigned_to_user_id': assignedToUserId,
      if (blindCount != null) 'blind_count': blindCount,
      if (dueAt != null) 'due_at': dueAt,
      if (createdAt != null) 'created_at': createdAt,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (approvedAt != null) 'approved_at': approvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CycleCountSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? status,
    Value<String?>? assignedToUserId,
    Value<bool>? blindCount,
    Value<DateTime?>? dueAt,
    Value<DateTime>? createdAt,
    Value<DateTime?>? submittedAt,
    Value<DateTime?>? approvedAt,
    Value<int>? rowid,
  }) {
    return CycleCountSessionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      blindCount: blindCount ?? this.blindCount,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (assignedToUserId.present) {
      map['assigned_to_user_id'] = Variable<String>(assignedToUserId.value);
    }
    if (blindCount.present) {
      map['blind_count'] = Variable<bool>(blindCount.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (approvedAt.present) {
      map['approved_at'] = Variable<DateTime>(approvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CycleCountSessionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('assignedToUserId: $assignedToUserId, ')
          ..write('blindCount: $blindCount, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CycleCountLinesTable extends CycleCountLines
    with TableInfo<$CycleCountLinesTable, CycleCountLineRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CycleCountLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedQuantityMeta = const VerificationMeta(
    'expectedQuantity',
  );
  @override
  late final GeneratedColumn<double> expectedQuantity = GeneratedColumn<double>(
    'expected_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countedQuantityMeta = const VerificationMeta(
    'countedQuantity',
  );
  @override
  late final GeneratedColumn<double> countedQuantity = GeneratedColumn<double>(
    'counted_quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _varianceQuantityMeta = const VerificationMeta(
    'varianceQuantity',
  );
  @override
  late final GeneratedColumn<double> varianceQuantity = GeneratedColumn<double>(
    'variance_quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitOfMeasureIdMeta = const VerificationMeta(
    'unitOfMeasureId',
  );
  @override
  late final GeneratedColumn<String> unitOfMeasureId = GeneratedColumn<String>(
    'unit_of_measure_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    itemId,
    locationId,
    expectedQuantity,
    countedQuantity,
    varianceQuantity,
    unitOfMeasureId,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_count_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<CycleCountLineRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    if (data.containsKey('expected_quantity')) {
      context.handle(
        _expectedQuantityMeta,
        expectedQuantity.isAcceptableOrUnknown(
          data['expected_quantity']!,
          _expectedQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedQuantityMeta);
    }
    if (data.containsKey('counted_quantity')) {
      context.handle(
        _countedQuantityMeta,
        countedQuantity.isAcceptableOrUnknown(
          data['counted_quantity']!,
          _countedQuantityMeta,
        ),
      );
    }
    if (data.containsKey('variance_quantity')) {
      context.handle(
        _varianceQuantityMeta,
        varianceQuantity.isAcceptableOrUnknown(
          data['variance_quantity']!,
          _varianceQuantityMeta,
        ),
      );
    }
    if (data.containsKey('unit_of_measure_id')) {
      context.handle(
        _unitOfMeasureIdMeta,
        unitOfMeasureId.isAcceptableOrUnknown(
          data['unit_of_measure_id']!,
          _unitOfMeasureIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitOfMeasureIdMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CycleCountLineRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CycleCountLineRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      )!,
      expectedQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expected_quantity'],
      )!,
      countedQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}counted_quantity'],
      ),
      varianceQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}variance_quantity'],
      ),
      unitOfMeasureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_of_measure_id'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CycleCountLinesTable createAlias(String alias) {
    return $CycleCountLinesTable(attachedDatabase, alias);
  }
}

class CycleCountLineRecord extends DataClass
    implements Insertable<CycleCountLineRecord> {
  final String id;
  final String sessionId;
  final String itemId;
  final String locationId;
  final double expectedQuantity;
  final double? countedQuantity;
  final double? varianceQuantity;
  final String unitOfMeasureId;
  final String? notes;
  const CycleCountLineRecord({
    required this.id,
    required this.sessionId,
    required this.itemId,
    required this.locationId,
    required this.expectedQuantity,
    this.countedQuantity,
    this.varianceQuantity,
    required this.unitOfMeasureId,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['item_id'] = Variable<String>(itemId);
    map['location_id'] = Variable<String>(locationId);
    map['expected_quantity'] = Variable<double>(expectedQuantity);
    if (!nullToAbsent || countedQuantity != null) {
      map['counted_quantity'] = Variable<double>(countedQuantity);
    }
    if (!nullToAbsent || varianceQuantity != null) {
      map['variance_quantity'] = Variable<double>(varianceQuantity);
    }
    map['unit_of_measure_id'] = Variable<String>(unitOfMeasureId);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CycleCountLinesCompanion toCompanion(bool nullToAbsent) {
    return CycleCountLinesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      itemId: Value(itemId),
      locationId: Value(locationId),
      expectedQuantity: Value(expectedQuantity),
      countedQuantity: countedQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(countedQuantity),
      varianceQuantity: varianceQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(varianceQuantity),
      unitOfMeasureId: Value(unitOfMeasureId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CycleCountLineRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CycleCountLineRecord(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      locationId: serializer.fromJson<String>(json['locationId']),
      expectedQuantity: serializer.fromJson<double>(json['expectedQuantity']),
      countedQuantity: serializer.fromJson<double?>(json['countedQuantity']),
      varianceQuantity: serializer.fromJson<double?>(json['varianceQuantity']),
      unitOfMeasureId: serializer.fromJson<String>(json['unitOfMeasureId']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'itemId': serializer.toJson<String>(itemId),
      'locationId': serializer.toJson<String>(locationId),
      'expectedQuantity': serializer.toJson<double>(expectedQuantity),
      'countedQuantity': serializer.toJson<double?>(countedQuantity),
      'varianceQuantity': serializer.toJson<double?>(varianceQuantity),
      'unitOfMeasureId': serializer.toJson<String>(unitOfMeasureId),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CycleCountLineRecord copyWith({
    String? id,
    String? sessionId,
    String? itemId,
    String? locationId,
    double? expectedQuantity,
    Value<double?> countedQuantity = const Value.absent(),
    Value<double?> varianceQuantity = const Value.absent(),
    String? unitOfMeasureId,
    Value<String?> notes = const Value.absent(),
  }) => CycleCountLineRecord(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    itemId: itemId ?? this.itemId,
    locationId: locationId ?? this.locationId,
    expectedQuantity: expectedQuantity ?? this.expectedQuantity,
    countedQuantity: countedQuantity.present
        ? countedQuantity.value
        : this.countedQuantity,
    varianceQuantity: varianceQuantity.present
        ? varianceQuantity.value
        : this.varianceQuantity,
    unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
    notes: notes.present ? notes.value : this.notes,
  );
  CycleCountLineRecord copyWithCompanion(CycleCountLinesCompanion data) {
    return CycleCountLineRecord(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      expectedQuantity: data.expectedQuantity.present
          ? data.expectedQuantity.value
          : this.expectedQuantity,
      countedQuantity: data.countedQuantity.present
          ? data.countedQuantity.value
          : this.countedQuantity,
      varianceQuantity: data.varianceQuantity.present
          ? data.varianceQuantity.value
          : this.varianceQuantity,
      unitOfMeasureId: data.unitOfMeasureId.present
          ? data.unitOfMeasureId.value
          : this.unitOfMeasureId,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CycleCountLineRecord(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('itemId: $itemId, ')
          ..write('locationId: $locationId, ')
          ..write('expectedQuantity: $expectedQuantity, ')
          ..write('countedQuantity: $countedQuantity, ')
          ..write('varianceQuantity: $varianceQuantity, ')
          ..write('unitOfMeasureId: $unitOfMeasureId, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    itemId,
    locationId,
    expectedQuantity,
    countedQuantity,
    varianceQuantity,
    unitOfMeasureId,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CycleCountLineRecord &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.itemId == this.itemId &&
          other.locationId == this.locationId &&
          other.expectedQuantity == this.expectedQuantity &&
          other.countedQuantity == this.countedQuantity &&
          other.varianceQuantity == this.varianceQuantity &&
          other.unitOfMeasureId == this.unitOfMeasureId &&
          other.notes == this.notes);
}

class CycleCountLinesCompanion extends UpdateCompanion<CycleCountLineRecord> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> itemId;
  final Value<String> locationId;
  final Value<double> expectedQuantity;
  final Value<double?> countedQuantity;
  final Value<double?> varianceQuantity;
  final Value<String> unitOfMeasureId;
  final Value<String?> notes;
  final Value<int> rowid;
  const CycleCountLinesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.locationId = const Value.absent(),
    this.expectedQuantity = const Value.absent(),
    this.countedQuantity = const Value.absent(),
    this.varianceQuantity = const Value.absent(),
    this.unitOfMeasureId = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CycleCountLinesCompanion.insert({
    required String id,
    required String sessionId,
    required String itemId,
    required String locationId,
    required double expectedQuantity,
    this.countedQuantity = const Value.absent(),
    this.varianceQuantity = const Value.absent(),
    required String unitOfMeasureId,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       itemId = Value(itemId),
       locationId = Value(locationId),
       expectedQuantity = Value(expectedQuantity),
       unitOfMeasureId = Value(unitOfMeasureId);
  static Insertable<CycleCountLineRecord> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? itemId,
    Expression<String>? locationId,
    Expression<double>? expectedQuantity,
    Expression<double>? countedQuantity,
    Expression<double>? varianceQuantity,
    Expression<String>? unitOfMeasureId,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (itemId != null) 'item_id': itemId,
      if (locationId != null) 'location_id': locationId,
      if (expectedQuantity != null) 'expected_quantity': expectedQuantity,
      if (countedQuantity != null) 'counted_quantity': countedQuantity,
      if (varianceQuantity != null) 'variance_quantity': varianceQuantity,
      if (unitOfMeasureId != null) 'unit_of_measure_id': unitOfMeasureId,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CycleCountLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? itemId,
    Value<String>? locationId,
    Value<double>? expectedQuantity,
    Value<double?>? countedQuantity,
    Value<double?>? varianceQuantity,
    Value<String>? unitOfMeasureId,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return CycleCountLinesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      itemId: itemId ?? this.itemId,
      locationId: locationId ?? this.locationId,
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
      countedQuantity: countedQuantity ?? this.countedQuantity,
      varianceQuantity: varianceQuantity ?? this.varianceQuantity,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (expectedQuantity.present) {
      map['expected_quantity'] = Variable<double>(expectedQuantity.value);
    }
    if (countedQuantity.present) {
      map['counted_quantity'] = Variable<double>(countedQuantity.value);
    }
    if (varianceQuantity.present) {
      map['variance_quantity'] = Variable<double>(varianceQuantity.value);
    }
    if (unitOfMeasureId.present) {
      map['unit_of_measure_id'] = Variable<String>(unitOfMeasureId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CycleCountLinesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('itemId: $itemId, ')
          ..write('locationId: $locationId, ')
          ..write('expectedQuantity: $expectedQuantity, ')
          ..write('countedQuantity: $countedQuantity, ')
          ..write('varianceQuantity: $varianceQuantity, ')
          ..write('unitOfMeasureId: $unitOfMeasureId, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomFieldDefinitionsTable extends CustomFieldDefinitions
    with TableInfo<$CustomFieldDefinitionsTable, CustomFieldDefinitionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFieldDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldTypeMeta = const VerificationMeta(
    'fieldType',
  );
  @override
  late final GeneratedColumn<String> fieldType = GeneratedColumn<String>(
    'field_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRequiredMeta = const VerificationMeta(
    'isRequired',
  );
  @override
  late final GeneratedColumn<bool> isRequired = GeneratedColumn<bool>(
    'is_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_required" IN (0, 1))',
    ),
  );
  static const VerificationMeta _optionsJsonMeta = const VerificationMeta(
    'optionsJson',
  );
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
    'options_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliesToItemTypeMeta = const VerificationMeta(
    'appliesToItemType',
  );
  @override
  late final GeneratedColumn<String> appliesToItemType =
      GeneratedColumn<String>(
        'applies_to_item_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _appliesToCategoryMeta = const VerificationMeta(
    'appliesToCategory',
  );
  @override
  late final GeneratedColumn<String> appliesToCategory =
      GeneratedColumn<String>(
        'applies_to_category',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    name,
    fieldType,
    isRequired,
    optionsJson,
    appliesToItemType,
    appliesToCategory,
    sortOrder,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_field_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomFieldDefinitionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('field_type')) {
      context.handle(
        _fieldTypeMeta,
        fieldType.isAcceptableOrUnknown(data['field_type']!, _fieldTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldTypeMeta);
    }
    if (data.containsKey('is_required')) {
      context.handle(
        _isRequiredMeta,
        isRequired.isAcceptableOrUnknown(data['is_required']!, _isRequiredMeta),
      );
    } else if (isInserting) {
      context.missing(_isRequiredMeta);
    }
    if (data.containsKey('options_json')) {
      context.handle(
        _optionsJsonMeta,
        optionsJson.isAcceptableOrUnknown(
          data['options_json']!,
          _optionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_optionsJsonMeta);
    }
    if (data.containsKey('applies_to_item_type')) {
      context.handle(
        _appliesToItemTypeMeta,
        appliesToItemType.isAcceptableOrUnknown(
          data['applies_to_item_type']!,
          _appliesToItemTypeMeta,
        ),
      );
    }
    if (data.containsKey('applies_to_category')) {
      context.handle(
        _appliesToCategoryMeta,
        appliesToCategory.isAcceptableOrUnknown(
          data['applies_to_category']!,
          _appliesToCategoryMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomFieldDefinitionRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFieldDefinitionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fieldType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_type'],
      )!,
      isRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_required'],
      )!,
      optionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options_json'],
      )!,
      appliesToItemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applies_to_item_type'],
      ),
      appliesToCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applies_to_category'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CustomFieldDefinitionsTable createAlias(String alias) {
    return $CustomFieldDefinitionsTable(attachedDatabase, alias);
  }
}

class CustomFieldDefinitionRecord extends DataClass
    implements Insertable<CustomFieldDefinitionRecord> {
  final String id;
  final String entityType;
  final String name;
  final String fieldType;
  final bool isRequired;
  final String optionsJson;
  final String? appliesToItemType;
  final String? appliesToCategory;
  final int sortOrder;
  final bool isActive;
  const CustomFieldDefinitionRecord({
    required this.id,
    required this.entityType,
    required this.name,
    required this.fieldType,
    required this.isRequired,
    required this.optionsJson,
    this.appliesToItemType,
    this.appliesToCategory,
    required this.sortOrder,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['name'] = Variable<String>(name);
    map['field_type'] = Variable<String>(fieldType);
    map['is_required'] = Variable<bool>(isRequired);
    map['options_json'] = Variable<String>(optionsJson);
    if (!nullToAbsent || appliesToItemType != null) {
      map['applies_to_item_type'] = Variable<String>(appliesToItemType);
    }
    if (!nullToAbsent || appliesToCategory != null) {
      map['applies_to_category'] = Variable<String>(appliesToCategory);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CustomFieldDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return CustomFieldDefinitionsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      name: Value(name),
      fieldType: Value(fieldType),
      isRequired: Value(isRequired),
      optionsJson: Value(optionsJson),
      appliesToItemType: appliesToItemType == null && nullToAbsent
          ? const Value.absent()
          : Value(appliesToItemType),
      appliesToCategory: appliesToCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(appliesToCategory),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory CustomFieldDefinitionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFieldDefinitionRecord(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      name: serializer.fromJson<String>(json['name']),
      fieldType: serializer.fromJson<String>(json['fieldType']),
      isRequired: serializer.fromJson<bool>(json['isRequired']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      appliesToItemType: serializer.fromJson<String?>(
        json['appliesToItemType'],
      ),
      appliesToCategory: serializer.fromJson<String?>(
        json['appliesToCategory'],
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'name': serializer.toJson<String>(name),
      'fieldType': serializer.toJson<String>(fieldType),
      'isRequired': serializer.toJson<bool>(isRequired),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'appliesToItemType': serializer.toJson<String?>(appliesToItemType),
      'appliesToCategory': serializer.toJson<String?>(appliesToCategory),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CustomFieldDefinitionRecord copyWith({
    String? id,
    String? entityType,
    String? name,
    String? fieldType,
    bool? isRequired,
    String? optionsJson,
    Value<String?> appliesToItemType = const Value.absent(),
    Value<String?> appliesToCategory = const Value.absent(),
    int? sortOrder,
    bool? isActive,
  }) => CustomFieldDefinitionRecord(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    name: name ?? this.name,
    fieldType: fieldType ?? this.fieldType,
    isRequired: isRequired ?? this.isRequired,
    optionsJson: optionsJson ?? this.optionsJson,
    appliesToItemType: appliesToItemType.present
        ? appliesToItemType.value
        : this.appliesToItemType,
    appliesToCategory: appliesToCategory.present
        ? appliesToCategory.value
        : this.appliesToCategory,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
  );
  CustomFieldDefinitionRecord copyWithCompanion(
    CustomFieldDefinitionsCompanion data,
  ) {
    return CustomFieldDefinitionRecord(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      name: data.name.present ? data.name.value : this.name,
      fieldType: data.fieldType.present ? data.fieldType.value : this.fieldType,
      isRequired: data.isRequired.present
          ? data.isRequired.value
          : this.isRequired,
      optionsJson: data.optionsJson.present
          ? data.optionsJson.value
          : this.optionsJson,
      appliesToItemType: data.appliesToItemType.present
          ? data.appliesToItemType.value
          : this.appliesToItemType,
      appliesToCategory: data.appliesToCategory.present
          ? data.appliesToCategory.value
          : this.appliesToCategory,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldDefinitionRecord(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('name: $name, ')
          ..write('fieldType: $fieldType, ')
          ..write('isRequired: $isRequired, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('appliesToItemType: $appliesToItemType, ')
          ..write('appliesToCategory: $appliesToCategory, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    name,
    fieldType,
    isRequired,
    optionsJson,
    appliesToItemType,
    appliesToCategory,
    sortOrder,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFieldDefinitionRecord &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.name == this.name &&
          other.fieldType == this.fieldType &&
          other.isRequired == this.isRequired &&
          other.optionsJson == this.optionsJson &&
          other.appliesToItemType == this.appliesToItemType &&
          other.appliesToCategory == this.appliesToCategory &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class CustomFieldDefinitionsCompanion
    extends UpdateCompanion<CustomFieldDefinitionRecord> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> name;
  final Value<String> fieldType;
  final Value<bool> isRequired;
  final Value<String> optionsJson;
  final Value<String?> appliesToItemType;
  final Value<String?> appliesToCategory;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CustomFieldDefinitionsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.name = const Value.absent(),
    this.fieldType = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.appliesToItemType = const Value.absent(),
    this.appliesToCategory = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomFieldDefinitionsCompanion.insert({
    required String id,
    required String entityType,
    required String name,
    required String fieldType,
    required bool isRequired,
    required String optionsJson,
    this.appliesToItemType = const Value.absent(),
    this.appliesToCategory = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required bool isActive,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       name = Value(name),
       fieldType = Value(fieldType),
       isRequired = Value(isRequired),
       optionsJson = Value(optionsJson),
       isActive = Value(isActive);
  static Insertable<CustomFieldDefinitionRecord> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? name,
    Expression<String>? fieldType,
    Expression<bool>? isRequired,
    Expression<String>? optionsJson,
    Expression<String>? appliesToItemType,
    Expression<String>? appliesToCategory,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (name != null) 'name': name,
      if (fieldType != null) 'field_type': fieldType,
      if (isRequired != null) 'is_required': isRequired,
      if (optionsJson != null) 'options_json': optionsJson,
      if (appliesToItemType != null) 'applies_to_item_type': appliesToItemType,
      if (appliesToCategory != null) 'applies_to_category': appliesToCategory,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomFieldDefinitionsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? name,
    Value<String>? fieldType,
    Value<bool>? isRequired,
    Value<String>? optionsJson,
    Value<String?>? appliesToItemType,
    Value<String?>? appliesToCategory,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return CustomFieldDefinitionsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      isRequired: isRequired ?? this.isRequired,
      optionsJson: optionsJson ?? this.optionsJson,
      appliesToItemType: appliesToItemType ?? this.appliesToItemType,
      appliesToCategory: appliesToCategory ?? this.appliesToCategory,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fieldType.present) {
      map['field_type'] = Variable<String>(fieldType.value);
    }
    if (isRequired.present) {
      map['is_required'] = Variable<bool>(isRequired.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (appliesToItemType.present) {
      map['applies_to_item_type'] = Variable<String>(appliesToItemType.value);
    }
    if (appliesToCategory.present) {
      map['applies_to_category'] = Variable<String>(appliesToCategory.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('name: $name, ')
          ..write('fieldType: $fieldType, ')
          ..write('isRequired: $isRequired, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('appliesToItemType: $appliesToItemType, ')
          ..write('appliesToCategory: $appliesToCategory, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomFieldValuesTable extends CustomFieldValues
    with TableInfo<$CustomFieldValuesTable, CustomFieldValueRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFieldValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionIdMeta = const VerificationMeta(
    'definitionId',
  );
  @override
  late final GeneratedColumn<String> definitionId = GeneratedColumn<String>(
    'definition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numberValueMeta = const VerificationMeta(
    'numberValue',
  );
  @override
  late final GeneratedColumn<double> numberValue = GeneratedColumn<double>(
    'number_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateValueMeta = const VerificationMeta(
    'dateValue',
  );
  @override
  late final GeneratedColumn<DateTime> dateValue = GeneratedColumn<DateTime>(
    'date_value',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _booleanValueMeta = const VerificationMeta(
    'booleanValue',
  );
  @override
  late final GeneratedColumn<bool> booleanValue = GeneratedColumn<bool>(
    'boolean_value',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("boolean_value" IN (0, 1))',
    ),
  );
  static const VerificationMeta _selectedOptionMeta = const VerificationMeta(
    'selectedOption',
  );
  @override
  late final GeneratedColumn<String> selectedOption = GeneratedColumn<String>(
    'selected_option',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    definitionId,
    entityId,
    textValue,
    numberValue,
    dateValue,
    booleanValue,
    selectedOption,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_field_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomFieldValueRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('definition_id')) {
      context.handle(
        _definitionIdMeta,
        definitionId.isAcceptableOrUnknown(
          data['definition_id']!,
          _definitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionIdMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    }
    if (data.containsKey('number_value')) {
      context.handle(
        _numberValueMeta,
        numberValue.isAcceptableOrUnknown(
          data['number_value']!,
          _numberValueMeta,
        ),
      );
    }
    if (data.containsKey('date_value')) {
      context.handle(
        _dateValueMeta,
        dateValue.isAcceptableOrUnknown(data['date_value']!, _dateValueMeta),
      );
    }
    if (data.containsKey('boolean_value')) {
      context.handle(
        _booleanValueMeta,
        booleanValue.isAcceptableOrUnknown(
          data['boolean_value']!,
          _booleanValueMeta,
        ),
      );
    }
    if (data.containsKey('selected_option')) {
      context.handle(
        _selectedOptionMeta,
        selectedOption.isAcceptableOrUnknown(
          data['selected_option']!,
          _selectedOptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomFieldValueRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFieldValueRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      definitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      ),
      numberValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}number_value'],
      ),
      dateValue: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_value'],
      ),
      booleanValue: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}boolean_value'],
      ),
      selectedOption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_option'],
      ),
    );
  }

  @override
  $CustomFieldValuesTable createAlias(String alias) {
    return $CustomFieldValuesTable(attachedDatabase, alias);
  }
}

class CustomFieldValueRecord extends DataClass
    implements Insertable<CustomFieldValueRecord> {
  final String id;
  final String definitionId;
  final String entityId;
  final String? textValue;
  final double? numberValue;
  final DateTime? dateValue;
  final bool? booleanValue;
  final String? selectedOption;
  const CustomFieldValueRecord({
    required this.id,
    required this.definitionId,
    required this.entityId,
    this.textValue,
    this.numberValue,
    this.dateValue,
    this.booleanValue,
    this.selectedOption,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['definition_id'] = Variable<String>(definitionId);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || textValue != null) {
      map['text_value'] = Variable<String>(textValue);
    }
    if (!nullToAbsent || numberValue != null) {
      map['number_value'] = Variable<double>(numberValue);
    }
    if (!nullToAbsent || dateValue != null) {
      map['date_value'] = Variable<DateTime>(dateValue);
    }
    if (!nullToAbsent || booleanValue != null) {
      map['boolean_value'] = Variable<bool>(booleanValue);
    }
    if (!nullToAbsent || selectedOption != null) {
      map['selected_option'] = Variable<String>(selectedOption);
    }
    return map;
  }

  CustomFieldValuesCompanion toCompanion(bool nullToAbsent) {
    return CustomFieldValuesCompanion(
      id: Value(id),
      definitionId: Value(definitionId),
      entityId: Value(entityId),
      textValue: textValue == null && nullToAbsent
          ? const Value.absent()
          : Value(textValue),
      numberValue: numberValue == null && nullToAbsent
          ? const Value.absent()
          : Value(numberValue),
      dateValue: dateValue == null && nullToAbsent
          ? const Value.absent()
          : Value(dateValue),
      booleanValue: booleanValue == null && nullToAbsent
          ? const Value.absent()
          : Value(booleanValue),
      selectedOption: selectedOption == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedOption),
    );
  }

  factory CustomFieldValueRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFieldValueRecord(
      id: serializer.fromJson<String>(json['id']),
      definitionId: serializer.fromJson<String>(json['definitionId']),
      entityId: serializer.fromJson<String>(json['entityId']),
      textValue: serializer.fromJson<String?>(json['textValue']),
      numberValue: serializer.fromJson<double?>(json['numberValue']),
      dateValue: serializer.fromJson<DateTime?>(json['dateValue']),
      booleanValue: serializer.fromJson<bool?>(json['booleanValue']),
      selectedOption: serializer.fromJson<String?>(json['selectedOption']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'definitionId': serializer.toJson<String>(definitionId),
      'entityId': serializer.toJson<String>(entityId),
      'textValue': serializer.toJson<String?>(textValue),
      'numberValue': serializer.toJson<double?>(numberValue),
      'dateValue': serializer.toJson<DateTime?>(dateValue),
      'booleanValue': serializer.toJson<bool?>(booleanValue),
      'selectedOption': serializer.toJson<String?>(selectedOption),
    };
  }

  CustomFieldValueRecord copyWith({
    String? id,
    String? definitionId,
    String? entityId,
    Value<String?> textValue = const Value.absent(),
    Value<double?> numberValue = const Value.absent(),
    Value<DateTime?> dateValue = const Value.absent(),
    Value<bool?> booleanValue = const Value.absent(),
    Value<String?> selectedOption = const Value.absent(),
  }) => CustomFieldValueRecord(
    id: id ?? this.id,
    definitionId: definitionId ?? this.definitionId,
    entityId: entityId ?? this.entityId,
    textValue: textValue.present ? textValue.value : this.textValue,
    numberValue: numberValue.present ? numberValue.value : this.numberValue,
    dateValue: dateValue.present ? dateValue.value : this.dateValue,
    booleanValue: booleanValue.present ? booleanValue.value : this.booleanValue,
    selectedOption: selectedOption.present
        ? selectedOption.value
        : this.selectedOption,
  );
  CustomFieldValueRecord copyWithCompanion(CustomFieldValuesCompanion data) {
    return CustomFieldValueRecord(
      id: data.id.present ? data.id.value : this.id,
      definitionId: data.definitionId.present
          ? data.definitionId.value
          : this.definitionId,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      numberValue: data.numberValue.present
          ? data.numberValue.value
          : this.numberValue,
      dateValue: data.dateValue.present ? data.dateValue.value : this.dateValue,
      booleanValue: data.booleanValue.present
          ? data.booleanValue.value
          : this.booleanValue,
      selectedOption: data.selectedOption.present
          ? data.selectedOption.value
          : this.selectedOption,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldValueRecord(')
          ..write('id: $id, ')
          ..write('definitionId: $definitionId, ')
          ..write('entityId: $entityId, ')
          ..write('textValue: $textValue, ')
          ..write('numberValue: $numberValue, ')
          ..write('dateValue: $dateValue, ')
          ..write('booleanValue: $booleanValue, ')
          ..write('selectedOption: $selectedOption')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    definitionId,
    entityId,
    textValue,
    numberValue,
    dateValue,
    booleanValue,
    selectedOption,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFieldValueRecord &&
          other.id == this.id &&
          other.definitionId == this.definitionId &&
          other.entityId == this.entityId &&
          other.textValue == this.textValue &&
          other.numberValue == this.numberValue &&
          other.dateValue == this.dateValue &&
          other.booleanValue == this.booleanValue &&
          other.selectedOption == this.selectedOption);
}

class CustomFieldValuesCompanion
    extends UpdateCompanion<CustomFieldValueRecord> {
  final Value<String> id;
  final Value<String> definitionId;
  final Value<String> entityId;
  final Value<String?> textValue;
  final Value<double?> numberValue;
  final Value<DateTime?> dateValue;
  final Value<bool?> booleanValue;
  final Value<String?> selectedOption;
  final Value<int> rowid;
  const CustomFieldValuesCompanion({
    this.id = const Value.absent(),
    this.definitionId = const Value.absent(),
    this.entityId = const Value.absent(),
    this.textValue = const Value.absent(),
    this.numberValue = const Value.absent(),
    this.dateValue = const Value.absent(),
    this.booleanValue = const Value.absent(),
    this.selectedOption = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomFieldValuesCompanion.insert({
    required String id,
    required String definitionId,
    required String entityId,
    this.textValue = const Value.absent(),
    this.numberValue = const Value.absent(),
    this.dateValue = const Value.absent(),
    this.booleanValue = const Value.absent(),
    this.selectedOption = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       definitionId = Value(definitionId),
       entityId = Value(entityId);
  static Insertable<CustomFieldValueRecord> custom({
    Expression<String>? id,
    Expression<String>? definitionId,
    Expression<String>? entityId,
    Expression<String>? textValue,
    Expression<double>? numberValue,
    Expression<DateTime>? dateValue,
    Expression<bool>? booleanValue,
    Expression<String>? selectedOption,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (definitionId != null) 'definition_id': definitionId,
      if (entityId != null) 'entity_id': entityId,
      if (textValue != null) 'text_value': textValue,
      if (numberValue != null) 'number_value': numberValue,
      if (dateValue != null) 'date_value': dateValue,
      if (booleanValue != null) 'boolean_value': booleanValue,
      if (selectedOption != null) 'selected_option': selectedOption,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomFieldValuesCompanion copyWith({
    Value<String>? id,
    Value<String>? definitionId,
    Value<String>? entityId,
    Value<String?>? textValue,
    Value<double?>? numberValue,
    Value<DateTime?>? dateValue,
    Value<bool?>? booleanValue,
    Value<String?>? selectedOption,
    Value<int>? rowid,
  }) {
    return CustomFieldValuesCompanion(
      id: id ?? this.id,
      definitionId: definitionId ?? this.definitionId,
      entityId: entityId ?? this.entityId,
      textValue: textValue ?? this.textValue,
      numberValue: numberValue ?? this.numberValue,
      dateValue: dateValue ?? this.dateValue,
      booleanValue: booleanValue ?? this.booleanValue,
      selectedOption: selectedOption ?? this.selectedOption,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (definitionId.present) {
      map['definition_id'] = Variable<String>(definitionId.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    if (numberValue.present) {
      map['number_value'] = Variable<double>(numberValue.value);
    }
    if (dateValue.present) {
      map['date_value'] = Variable<DateTime>(dateValue.value);
    }
    if (booleanValue.present) {
      map['boolean_value'] = Variable<bool>(booleanValue.value);
    }
    if (selectedOption.present) {
      map['selected_option'] = Variable<String>(selectedOption.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldValuesCompanion(')
          ..write('id: $id, ')
          ..write('definitionId: $definitionId, ')
          ..write('entityId: $entityId, ')
          ..write('textValue: $textValue, ')
          ..write('numberValue: $numberValue, ')
          ..write('dateValue: $dateValue, ')
          ..write('booleanValue: $booleanValue, ')
          ..write('selectedOption: $selectedOption, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlansTable extends Plans with TableInfo<$PlansTable, PlanRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemLimitMeta = const VerificationMeta(
    'itemLimit',
  );
  @override
  late final GeneratedColumn<int> itemLimit = GeneratedColumn<int>(
    'item_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userLimitMeta = const VerificationMeta(
    'userLimit',
  );
  @override
  late final GeneratedColumn<int> userLimit = GeneratedColumn<int>(
    'user_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationLimitMeta = const VerificationMeta(
    'locationLimit',
  );
  @override
  late final GeneratedColumn<int> locationLimit = GeneratedColumn<int>(
    'location_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoLimitMeta = const VerificationMeta(
    'photoLimit',
  );
  @override
  late final GeneratedColumn<int> photoLimit = GeneratedColumn<int>(
    'photo_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelExportLimitMeta = const VerificationMeta(
    'labelExportLimit',
  );
  @override
  late final GeneratedColumn<int> labelExportLimit = GeneratedColumn<int>(
    'label_export_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    name,
    itemLimit,
    userLimit,
    locationLimit,
    photoLimit,
    labelExportLimit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('item_limit')) {
      context.handle(
        _itemLimitMeta,
        itemLimit.isAcceptableOrUnknown(data['item_limit']!, _itemLimitMeta),
      );
    } else if (isInserting) {
      context.missing(_itemLimitMeta);
    }
    if (data.containsKey('user_limit')) {
      context.handle(
        _userLimitMeta,
        userLimit.isAcceptableOrUnknown(data['user_limit']!, _userLimitMeta),
      );
    } else if (isInserting) {
      context.missing(_userLimitMeta);
    }
    if (data.containsKey('location_limit')) {
      context.handle(
        _locationLimitMeta,
        locationLimit.isAcceptableOrUnknown(
          data['location_limit']!,
          _locationLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationLimitMeta);
    }
    if (data.containsKey('photo_limit')) {
      context.handle(
        _photoLimitMeta,
        photoLimit.isAcceptableOrUnknown(data['photo_limit']!, _photoLimitMeta),
      );
    } else if (isInserting) {
      context.missing(_photoLimitMeta);
    }
    if (data.containsKey('label_export_limit')) {
      context.handle(
        _labelExportLimitMeta,
        labelExportLimit.isAcceptableOrUnknown(
          data['label_export_limit']!,
          _labelExportLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_labelExportLimitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  PlanRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRecord(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      itemLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_limit'],
      )!,
      userLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_limit'],
      )!,
      locationLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}location_limit'],
      )!,
      photoLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}photo_limit'],
      )!,
      labelExportLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}label_export_limit'],
      )!,
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class PlanRecord extends DataClass implements Insertable<PlanRecord> {
  final String code;
  final String name;
  final int itemLimit;
  final int userLimit;
  final int locationLimit;
  final int photoLimit;
  final int labelExportLimit;
  const PlanRecord({
    required this.code,
    required this.name,
    required this.itemLimit,
    required this.userLimit,
    required this.locationLimit,
    required this.photoLimit,
    required this.labelExportLimit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['item_limit'] = Variable<int>(itemLimit);
    map['user_limit'] = Variable<int>(userLimit);
    map['location_limit'] = Variable<int>(locationLimit);
    map['photo_limit'] = Variable<int>(photoLimit);
    map['label_export_limit'] = Variable<int>(labelExportLimit);
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      code: Value(code),
      name: Value(name),
      itemLimit: Value(itemLimit),
      userLimit: Value(userLimit),
      locationLimit: Value(locationLimit),
      photoLimit: Value(photoLimit),
      labelExportLimit: Value(labelExportLimit),
    );
  }

  factory PlanRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRecord(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      itemLimit: serializer.fromJson<int>(json['itemLimit']),
      userLimit: serializer.fromJson<int>(json['userLimit']),
      locationLimit: serializer.fromJson<int>(json['locationLimit']),
      photoLimit: serializer.fromJson<int>(json['photoLimit']),
      labelExportLimit: serializer.fromJson<int>(json['labelExportLimit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'itemLimit': serializer.toJson<int>(itemLimit),
      'userLimit': serializer.toJson<int>(userLimit),
      'locationLimit': serializer.toJson<int>(locationLimit),
      'photoLimit': serializer.toJson<int>(photoLimit),
      'labelExportLimit': serializer.toJson<int>(labelExportLimit),
    };
  }

  PlanRecord copyWith({
    String? code,
    String? name,
    int? itemLimit,
    int? userLimit,
    int? locationLimit,
    int? photoLimit,
    int? labelExportLimit,
  }) => PlanRecord(
    code: code ?? this.code,
    name: name ?? this.name,
    itemLimit: itemLimit ?? this.itemLimit,
    userLimit: userLimit ?? this.userLimit,
    locationLimit: locationLimit ?? this.locationLimit,
    photoLimit: photoLimit ?? this.photoLimit,
    labelExportLimit: labelExportLimit ?? this.labelExportLimit,
  );
  PlanRecord copyWithCompanion(PlansCompanion data) {
    return PlanRecord(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      itemLimit: data.itemLimit.present ? data.itemLimit.value : this.itemLimit,
      userLimit: data.userLimit.present ? data.userLimit.value : this.userLimit,
      locationLimit: data.locationLimit.present
          ? data.locationLimit.value
          : this.locationLimit,
      photoLimit: data.photoLimit.present
          ? data.photoLimit.value
          : this.photoLimit,
      labelExportLimit: data.labelExportLimit.present
          ? data.labelExportLimit.value
          : this.labelExportLimit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRecord(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('itemLimit: $itemLimit, ')
          ..write('userLimit: $userLimit, ')
          ..write('locationLimit: $locationLimit, ')
          ..write('photoLimit: $photoLimit, ')
          ..write('labelExportLimit: $labelExportLimit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    code,
    name,
    itemLimit,
    userLimit,
    locationLimit,
    photoLimit,
    labelExportLimit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRecord &&
          other.code == this.code &&
          other.name == this.name &&
          other.itemLimit == this.itemLimit &&
          other.userLimit == this.userLimit &&
          other.locationLimit == this.locationLimit &&
          other.photoLimit == this.photoLimit &&
          other.labelExportLimit == this.labelExportLimit);
}

class PlansCompanion extends UpdateCompanion<PlanRecord> {
  final Value<String> code;
  final Value<String> name;
  final Value<int> itemLimit;
  final Value<int> userLimit;
  final Value<int> locationLimit;
  final Value<int> photoLimit;
  final Value<int> labelExportLimit;
  final Value<int> rowid;
  const PlansCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.itemLimit = const Value.absent(),
    this.userLimit = const Value.absent(),
    this.locationLimit = const Value.absent(),
    this.photoLimit = const Value.absent(),
    this.labelExportLimit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlansCompanion.insert({
    required String code,
    required String name,
    required int itemLimit,
    required int userLimit,
    required int locationLimit,
    required int photoLimit,
    required int labelExportLimit,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       itemLimit = Value(itemLimit),
       userLimit = Value(userLimit),
       locationLimit = Value(locationLimit),
       photoLimit = Value(photoLimit),
       labelExportLimit = Value(labelExportLimit);
  static Insertable<PlanRecord> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? itemLimit,
    Expression<int>? userLimit,
    Expression<int>? locationLimit,
    Expression<int>? photoLimit,
    Expression<int>? labelExportLimit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (itemLimit != null) 'item_limit': itemLimit,
      if (userLimit != null) 'user_limit': userLimit,
      if (locationLimit != null) 'location_limit': locationLimit,
      if (photoLimit != null) 'photo_limit': photoLimit,
      if (labelExportLimit != null) 'label_export_limit': labelExportLimit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlansCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<int>? itemLimit,
    Value<int>? userLimit,
    Value<int>? locationLimit,
    Value<int>? photoLimit,
    Value<int>? labelExportLimit,
    Value<int>? rowid,
  }) {
    return PlansCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      itemLimit: itemLimit ?? this.itemLimit,
      userLimit: userLimit ?? this.userLimit,
      locationLimit: locationLimit ?? this.locationLimit,
      photoLimit: photoLimit ?? this.photoLimit,
      labelExportLimit: labelExportLimit ?? this.labelExportLimit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (itemLimit.present) {
      map['item_limit'] = Variable<int>(itemLimit.value);
    }
    if (userLimit.present) {
      map['user_limit'] = Variable<int>(userLimit.value);
    }
    if (locationLimit.present) {
      map['location_limit'] = Variable<int>(locationLimit.value);
    }
    if (photoLimit.present) {
      map['photo_limit'] = Variable<int>(photoLimit.value);
    }
    if (labelExportLimit.present) {
      map['label_export_limit'] = Variable<int>(labelExportLimit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('itemLimit: $itemLimit, ')
          ..write('userLimit: $userLimit, ')
          ..write('locationLimit: $locationLimit, ')
          ..write('photoLimit: $photoLimit, ')
          ..write('labelExportLimit: $labelExportLimit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompanyUsagesTable extends CompanyUsages
    with TableInfo<$CompanyUsagesTable, CompanyUsageRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompanyUsagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeItemCountMeta = const VerificationMeta(
    'activeItemCount',
  );
  @override
  late final GeneratedColumn<int> activeItemCount = GeneratedColumn<int>(
    'active_item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userCountMeta = const VerificationMeta(
    'userCount',
  );
  @override
  late final GeneratedColumn<int> userCount = GeneratedColumn<int>(
    'user_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationCountMeta = const VerificationMeta(
    'locationCount',
  );
  @override
  late final GeneratedColumn<int> locationCount = GeneratedColumn<int>(
    'location_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoCountMeta = const VerificationMeta(
    'photoCount',
  );
  @override
  late final GeneratedColumn<int> photoCount = GeneratedColumn<int>(
    'photo_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelExportCountMeta = const VerificationMeta(
    'labelExportCount',
  );
  @override
  late final GeneratedColumn<int> labelExportCount = GeneratedColumn<int>(
    'label_export_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activeItemCount,
    userCount,
    locationCount,
    photoCount,
    labelExportCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'company_usages';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanyUsageRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('active_item_count')) {
      context.handle(
        _activeItemCountMeta,
        activeItemCount.isAcceptableOrUnknown(
          data['active_item_count']!,
          _activeItemCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeItemCountMeta);
    }
    if (data.containsKey('user_count')) {
      context.handle(
        _userCountMeta,
        userCount.isAcceptableOrUnknown(data['user_count']!, _userCountMeta),
      );
    } else if (isInserting) {
      context.missing(_userCountMeta);
    }
    if (data.containsKey('location_count')) {
      context.handle(
        _locationCountMeta,
        locationCount.isAcceptableOrUnknown(
          data['location_count']!,
          _locationCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationCountMeta);
    }
    if (data.containsKey('photo_count')) {
      context.handle(
        _photoCountMeta,
        photoCount.isAcceptableOrUnknown(data['photo_count']!, _photoCountMeta),
      );
    } else if (isInserting) {
      context.missing(_photoCountMeta);
    }
    if (data.containsKey('label_export_count')) {
      context.handle(
        _labelExportCountMeta,
        labelExportCount.isAcceptableOrUnknown(
          data['label_export_count']!,
          _labelExportCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_labelExportCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompanyUsageRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanyUsageRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      activeItemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_item_count'],
      )!,
      userCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_count'],
      )!,
      locationCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}location_count'],
      )!,
      photoCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}photo_count'],
      )!,
      labelExportCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}label_export_count'],
      )!,
    );
  }

  @override
  $CompanyUsagesTable createAlias(String alias) {
    return $CompanyUsagesTable(attachedDatabase, alias);
  }
}

class CompanyUsageRecord extends DataClass
    implements Insertable<CompanyUsageRecord> {
  final String id;
  final int activeItemCount;
  final int userCount;
  final int locationCount;
  final int photoCount;
  final int labelExportCount;
  const CompanyUsageRecord({
    required this.id,
    required this.activeItemCount,
    required this.userCount,
    required this.locationCount,
    required this.photoCount,
    required this.labelExportCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['active_item_count'] = Variable<int>(activeItemCount);
    map['user_count'] = Variable<int>(userCount);
    map['location_count'] = Variable<int>(locationCount);
    map['photo_count'] = Variable<int>(photoCount);
    map['label_export_count'] = Variable<int>(labelExportCount);
    return map;
  }

  CompanyUsagesCompanion toCompanion(bool nullToAbsent) {
    return CompanyUsagesCompanion(
      id: Value(id),
      activeItemCount: Value(activeItemCount),
      userCount: Value(userCount),
      locationCount: Value(locationCount),
      photoCount: Value(photoCount),
      labelExportCount: Value(labelExportCount),
    );
  }

  factory CompanyUsageRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanyUsageRecord(
      id: serializer.fromJson<String>(json['id']),
      activeItemCount: serializer.fromJson<int>(json['activeItemCount']),
      userCount: serializer.fromJson<int>(json['userCount']),
      locationCount: serializer.fromJson<int>(json['locationCount']),
      photoCount: serializer.fromJson<int>(json['photoCount']),
      labelExportCount: serializer.fromJson<int>(json['labelExportCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activeItemCount': serializer.toJson<int>(activeItemCount),
      'userCount': serializer.toJson<int>(userCount),
      'locationCount': serializer.toJson<int>(locationCount),
      'photoCount': serializer.toJson<int>(photoCount),
      'labelExportCount': serializer.toJson<int>(labelExportCount),
    };
  }

  CompanyUsageRecord copyWith({
    String? id,
    int? activeItemCount,
    int? userCount,
    int? locationCount,
    int? photoCount,
    int? labelExportCount,
  }) => CompanyUsageRecord(
    id: id ?? this.id,
    activeItemCount: activeItemCount ?? this.activeItemCount,
    userCount: userCount ?? this.userCount,
    locationCount: locationCount ?? this.locationCount,
    photoCount: photoCount ?? this.photoCount,
    labelExportCount: labelExportCount ?? this.labelExportCount,
  );
  CompanyUsageRecord copyWithCompanion(CompanyUsagesCompanion data) {
    return CompanyUsageRecord(
      id: data.id.present ? data.id.value : this.id,
      activeItemCount: data.activeItemCount.present
          ? data.activeItemCount.value
          : this.activeItemCount,
      userCount: data.userCount.present ? data.userCount.value : this.userCount,
      locationCount: data.locationCount.present
          ? data.locationCount.value
          : this.locationCount,
      photoCount: data.photoCount.present
          ? data.photoCount.value
          : this.photoCount,
      labelExportCount: data.labelExportCount.present
          ? data.labelExportCount.value
          : this.labelExportCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanyUsageRecord(')
          ..write('id: $id, ')
          ..write('activeItemCount: $activeItemCount, ')
          ..write('userCount: $userCount, ')
          ..write('locationCount: $locationCount, ')
          ..write('photoCount: $photoCount, ')
          ..write('labelExportCount: $labelExportCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activeItemCount,
    userCount,
    locationCount,
    photoCount,
    labelExportCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanyUsageRecord &&
          other.id == this.id &&
          other.activeItemCount == this.activeItemCount &&
          other.userCount == this.userCount &&
          other.locationCount == this.locationCount &&
          other.photoCount == this.photoCount &&
          other.labelExportCount == this.labelExportCount);
}

class CompanyUsagesCompanion extends UpdateCompanion<CompanyUsageRecord> {
  final Value<String> id;
  final Value<int> activeItemCount;
  final Value<int> userCount;
  final Value<int> locationCount;
  final Value<int> photoCount;
  final Value<int> labelExportCount;
  final Value<int> rowid;
  const CompanyUsagesCompanion({
    this.id = const Value.absent(),
    this.activeItemCount = const Value.absent(),
    this.userCount = const Value.absent(),
    this.locationCount = const Value.absent(),
    this.photoCount = const Value.absent(),
    this.labelExportCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompanyUsagesCompanion.insert({
    required String id,
    required int activeItemCount,
    required int userCount,
    required int locationCount,
    required int photoCount,
    required int labelExportCount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       activeItemCount = Value(activeItemCount),
       userCount = Value(userCount),
       locationCount = Value(locationCount),
       photoCount = Value(photoCount),
       labelExportCount = Value(labelExportCount);
  static Insertable<CompanyUsageRecord> custom({
    Expression<String>? id,
    Expression<int>? activeItemCount,
    Expression<int>? userCount,
    Expression<int>? locationCount,
    Expression<int>? photoCount,
    Expression<int>? labelExportCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activeItemCount != null) 'active_item_count': activeItemCount,
      if (userCount != null) 'user_count': userCount,
      if (locationCount != null) 'location_count': locationCount,
      if (photoCount != null) 'photo_count': photoCount,
      if (labelExportCount != null) 'label_export_count': labelExportCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompanyUsagesCompanion copyWith({
    Value<String>? id,
    Value<int>? activeItemCount,
    Value<int>? userCount,
    Value<int>? locationCount,
    Value<int>? photoCount,
    Value<int>? labelExportCount,
    Value<int>? rowid,
  }) {
    return CompanyUsagesCompanion(
      id: id ?? this.id,
      activeItemCount: activeItemCount ?? this.activeItemCount,
      userCount: userCount ?? this.userCount,
      locationCount: locationCount ?? this.locationCount,
      photoCount: photoCount ?? this.photoCount,
      labelExportCount: labelExportCount ?? this.labelExportCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activeItemCount.present) {
      map['active_item_count'] = Variable<int>(activeItemCount.value);
    }
    if (userCount.present) {
      map['user_count'] = Variable<int>(userCount.value);
    }
    if (locationCount.present) {
      map['location_count'] = Variable<int>(locationCount.value);
    }
    if (photoCount.present) {
      map['photo_count'] = Variable<int>(photoCount.value);
    }
    if (labelExportCount.present) {
      map['label_export_count'] = Variable<int>(labelExportCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanyUsagesCompanion(')
          ..write('id: $id, ')
          ..write('activeItemCount: $activeItemCount, ')
          ..write('userCount: $userCount, ')
          ..write('locationCount: $locationCount, ')
          ..write('photoCount: $photoCount, ')
          ..write('labelExportCount: $labelExportCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompaniesTable extends Companies
    with TableInfo<$CompaniesTable, CompanyRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompaniesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _industryMeta = const VerificationMeta(
    'industry',
  );
  @override
  late final GeneratedColumn<String> industry = GeneratedColumn<String>(
    'industry',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setupCompletedMeta = const VerificationMeta(
    'setupCompleted',
  );
  @override
  late final GeneratedColumn<bool> setupCompleted = GeneratedColumn<bool>(
    'setup_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("setup_completed" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    industry,
    createdAt,
    updatedAt,
    setupCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanyRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('industry')) {
      context.handle(
        _industryMeta,
        industry.isAcceptableOrUnknown(data['industry']!, _industryMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('setup_completed')) {
      context.handle(
        _setupCompletedMeta,
        setupCompleted.isAcceptableOrUnknown(
          data['setup_completed']!,
          _setupCompletedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_setupCompletedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompanyRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanyRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      industry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}industry'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      setupCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}setup_completed'],
      )!,
    );
  }

  @override
  $CompaniesTable createAlias(String alias) {
    return $CompaniesTable(attachedDatabase, alias);
  }
}

class CompanyRecord extends DataClass implements Insertable<CompanyRecord> {
  final String id;
  final String name;
  final String? industry;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool setupCompleted;
  const CompanyRecord({
    required this.id,
    required this.name,
    this.industry,
    required this.createdAt,
    required this.updatedAt,
    required this.setupCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || industry != null) {
      map['industry'] = Variable<String>(industry);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['setup_completed'] = Variable<bool>(setupCompleted);
    return map;
  }

  CompaniesCompanion toCompanion(bool nullToAbsent) {
    return CompaniesCompanion(
      id: Value(id),
      name: Value(name),
      industry: industry == null && nullToAbsent
          ? const Value.absent()
          : Value(industry),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      setupCompleted: Value(setupCompleted),
    );
  }

  factory CompanyRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanyRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      industry: serializer.fromJson<String?>(json['industry']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      setupCompleted: serializer.fromJson<bool>(json['setupCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'industry': serializer.toJson<String?>(industry),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'setupCompleted': serializer.toJson<bool>(setupCompleted),
    };
  }

  CompanyRecord copyWith({
    String? id,
    String? name,
    Value<String?> industry = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? setupCompleted,
  }) => CompanyRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    industry: industry.present ? industry.value : this.industry,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    setupCompleted: setupCompleted ?? this.setupCompleted,
  );
  CompanyRecord copyWithCompanion(CompaniesCompanion data) {
    return CompanyRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      industry: data.industry.present ? data.industry.value : this.industry,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      setupCompleted: data.setupCompleted.present
          ? data.setupCompleted.value
          : this.setupCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanyRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('industry: $industry, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('setupCompleted: $setupCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, industry, createdAt, updatedAt, setupCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanyRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.industry == this.industry &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.setupCompleted == this.setupCompleted);
}

class CompaniesCompanion extends UpdateCompanion<CompanyRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> industry;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> setupCompleted;
  final Value<int> rowid;
  const CompaniesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.industry = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.setupCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompaniesCompanion.insert({
    required String id,
    required String name,
    this.industry = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool setupCompleted,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       setupCompleted = Value(setupCompleted);
  static Insertable<CompanyRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? industry,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? setupCompleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (industry != null) 'industry': industry,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (setupCompleted != null) 'setup_completed': setupCompleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompaniesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? industry,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? setupCompleted,
    Value<int>? rowid,
  }) {
    return CompaniesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      setupCompleted: setupCompleted ?? this.setupCompleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (industry.present) {
      map['industry'] = Variable<String>(industry.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (setupCompleted.present) {
      map['setup_completed'] = Variable<bool>(setupCompleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('industry: $industry, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('setupCompleted: $setupCompleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $UnitsOfMeasureTable unitsOfMeasure = $UnitsOfMeasureTable(this);
  late final $LocationsTable locations = $LocationsTable(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $InventoryTransactionsTable inventoryTransactions =
      $InventoryTransactionsTable(this);
  late final $ItemLocationBalancesTable itemLocationBalances =
      $ItemLocationBalancesTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $ReorderRequestsTable reorderRequests = $ReorderRequestsTable(
    this,
  );
  late final $CheckoutRecordsTable checkoutRecords = $CheckoutRecordsTable(
    this,
  );
  late final $AssignmentTargetsTable assignmentTargets =
      $AssignmentTargetsTable(this);
  late final $CycleCountSessionsTable cycleCountSessions =
      $CycleCountSessionsTable(this);
  late final $CycleCountLinesTable cycleCountLines = $CycleCountLinesTable(
    this,
  );
  late final $CustomFieldDefinitionsTable customFieldDefinitions =
      $CustomFieldDefinitionsTable(this);
  late final $CustomFieldValuesTable customFieldValues =
      $CustomFieldValuesTable(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $CompanyUsagesTable companyUsages = $CompanyUsagesTable(this);
  late final $CompaniesTable companies = $CompaniesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    items,
    unitsOfMeasure,
    locations,
    people,
    appUsers,
    inventoryTransactions,
    itemLocationBalances,
    suppliers,
    reorderRequests,
    checkoutRecords,
    assignmentTargets,
    cycleCountSessions,
    cycleCountLines,
    customFieldDefinitions,
    customFieldValues,
    plans,
    companyUsages,
    companies,
  ];
}

typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      required String id,
      required String name,
      required String description,
      required String itemType,
      required String category,
      required String locationId,
      required double quantityOnHand,
      required double minimumQuantity,
      required String unitOfMeasureId,
      Value<String?> purchaseUnitOfMeasureId,
      Value<double?> purchaseToStockConversionFactor,
      Value<String?> purchaseUnitLabel,
      Value<String?> barcode,
      Value<String?> sku,
      Value<String?> supplierId,
      Value<String?> supplier,
      Value<double?> unitCost,
      Value<String?> photoPath,
      required bool isActive,
      required bool allowFractionalQuantity,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> itemType,
      Value<String> category,
      Value<String> locationId,
      Value<double> quantityOnHand,
      Value<double> minimumQuantity,
      Value<String> unitOfMeasureId,
      Value<String?> purchaseUnitOfMeasureId,
      Value<double?> purchaseToStockConversionFactor,
      Value<String?> purchaseUnitLabel,
      Value<String?> barcode,
      Value<String?> sku,
      Value<String?> supplierId,
      Value<String?> supplier,
      Value<double?> unitCost,
      Value<String?> photoPath,
      Value<bool> isActive,
      Value<bool> allowFractionalQuantity,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityOnHand => $composableBuilder(
    column: $table.quantityOnHand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minimumQuantity => $composableBuilder(
    column: $table.minimumQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseUnitOfMeasureId => $composableBuilder(
    column: $table.purchaseUnitOfMeasureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchaseToStockConversionFactor =>
      $composableBuilder(
        column: $table.purchaseToStockConversionFactor,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get purchaseUnitLabel => $composableBuilder(
    column: $table.purchaseUnitLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowFractionalQuantity => $composableBuilder(
    column: $table.allowFractionalQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityOnHand => $composableBuilder(
    column: $table.quantityOnHand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minimumQuantity => $composableBuilder(
    column: $table.minimumQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseUnitOfMeasureId => $composableBuilder(
    column: $table.purchaseUnitOfMeasureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchaseToStockConversionFactor =>
      $composableBuilder(
        column: $table.purchaseToStockConversionFactor,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get purchaseUnitLabel => $composableBuilder(
    column: $table.purchaseUnitLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowFractionalQuantity => $composableBuilder(
    column: $table.allowFractionalQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantityOnHand => $composableBuilder(
    column: $table.quantityOnHand,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minimumQuantity => $composableBuilder(
    column: $table.minimumQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purchaseUnitOfMeasureId => $composableBuilder(
    column: $table.purchaseUnitOfMeasureId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get purchaseToStockConversionFactor =>
      $composableBuilder(
        column: $table.purchaseToStockConversionFactor,
        builder: (column) => column,
      );

  GeneratedColumn<String> get purchaseUnitLabel => $composableBuilder(
    column: $table.purchaseUnitLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get allowFractionalQuantity => $composableBuilder(
    column: $table.allowFractionalQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          ItemRecord,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (ItemRecord, BaseReferences<_$AppDatabase, $ItemsTable, ItemRecord>),
          ItemRecord,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> locationId = const Value.absent(),
                Value<double> quantityOnHand = const Value.absent(),
                Value<double> minimumQuantity = const Value.absent(),
                Value<String> unitOfMeasureId = const Value.absent(),
                Value<String?> purchaseUnitOfMeasureId = const Value.absent(),
                Value<double?> purchaseToStockConversionFactor =
                    const Value.absent(),
                Value<String?> purchaseUnitLabel = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                Value<double?> unitCost = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> allowFractionalQuantity = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                name: name,
                description: description,
                itemType: itemType,
                category: category,
                locationId: locationId,
                quantityOnHand: quantityOnHand,
                minimumQuantity: minimumQuantity,
                unitOfMeasureId: unitOfMeasureId,
                purchaseUnitOfMeasureId: purchaseUnitOfMeasureId,
                purchaseToStockConversionFactor:
                    purchaseToStockConversionFactor,
                purchaseUnitLabel: purchaseUnitLabel,
                barcode: barcode,
                sku: sku,
                supplierId: supplierId,
                supplier: supplier,
                unitCost: unitCost,
                photoPath: photoPath,
                isActive: isActive,
                allowFractionalQuantity: allowFractionalQuantity,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String description,
                required String itemType,
                required String category,
                required String locationId,
                required double quantityOnHand,
                required double minimumQuantity,
                required String unitOfMeasureId,
                Value<String?> purchaseUnitOfMeasureId = const Value.absent(),
                Value<double?> purchaseToStockConversionFactor =
                    const Value.absent(),
                Value<String?> purchaseUnitLabel = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                Value<double?> unitCost = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                required bool isActive,
                required bool allowFractionalQuantity,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                name: name,
                description: description,
                itemType: itemType,
                category: category,
                locationId: locationId,
                quantityOnHand: quantityOnHand,
                minimumQuantity: minimumQuantity,
                unitOfMeasureId: unitOfMeasureId,
                purchaseUnitOfMeasureId: purchaseUnitOfMeasureId,
                purchaseToStockConversionFactor:
                    purchaseToStockConversionFactor,
                purchaseUnitLabel: purchaseUnitLabel,
                barcode: barcode,
                sku: sku,
                supplierId: supplierId,
                supplier: supplier,
                unitCost: unitCost,
                photoPath: photoPath,
                isActive: isActive,
                allowFractionalQuantity: allowFractionalQuantity,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      ItemRecord,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (ItemRecord, BaseReferences<_$AppDatabase, $ItemsTable, ItemRecord>),
      ItemRecord,
      PrefetchHooks Function()
    >;
typedef $$UnitsOfMeasureTableCreateCompanionBuilder =
    UnitsOfMeasureCompanion Function({
      required String id,
      required String name,
      required String abbreviation,
      required bool allowsDecimal,
      required bool isActive,
      Value<int> rowid,
    });
typedef $$UnitsOfMeasureTableUpdateCompanionBuilder =
    UnitsOfMeasureCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> abbreviation,
      Value<bool> allowsDecimal,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$UnitsOfMeasureTableFilterComposer
    extends Composer<_$AppDatabase, $UnitsOfMeasureTable> {
  $$UnitsOfMeasureTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abbreviation => $composableBuilder(
    column: $table.abbreviation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowsDecimal => $composableBuilder(
    column: $table.allowsDecimal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnitsOfMeasureTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsOfMeasureTable> {
  $$UnitsOfMeasureTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abbreviation => $composableBuilder(
    column: $table.abbreviation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowsDecimal => $composableBuilder(
    column: $table.allowsDecimal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitsOfMeasureTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsOfMeasureTable> {
  $$UnitsOfMeasureTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get abbreviation => $composableBuilder(
    column: $table.abbreviation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowsDecimal => $composableBuilder(
    column: $table.allowsDecimal,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$UnitsOfMeasureTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitsOfMeasureTable,
          UnitOfMeasureRecord,
          $$UnitsOfMeasureTableFilterComposer,
          $$UnitsOfMeasureTableOrderingComposer,
          $$UnitsOfMeasureTableAnnotationComposer,
          $$UnitsOfMeasureTableCreateCompanionBuilder,
          $$UnitsOfMeasureTableUpdateCompanionBuilder,
          (
            UnitOfMeasureRecord,
            BaseReferences<
              _$AppDatabase,
              $UnitsOfMeasureTable,
              UnitOfMeasureRecord
            >,
          ),
          UnitOfMeasureRecord,
          PrefetchHooks Function()
        > {
  $$UnitsOfMeasureTableTableManager(
    _$AppDatabase db,
    $UnitsOfMeasureTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsOfMeasureTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsOfMeasureTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsOfMeasureTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> abbreviation = const Value.absent(),
                Value<bool> allowsDecimal = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitsOfMeasureCompanion(
                id: id,
                name: name,
                abbreviation: abbreviation,
                allowsDecimal: allowsDecimal,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String abbreviation,
                required bool allowsDecimal,
                required bool isActive,
                Value<int> rowid = const Value.absent(),
              }) => UnitsOfMeasureCompanion.insert(
                id: id,
                name: name,
                abbreviation: abbreviation,
                allowsDecimal: allowsDecimal,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnitsOfMeasureTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitsOfMeasureTable,
      UnitOfMeasureRecord,
      $$UnitsOfMeasureTableFilterComposer,
      $$UnitsOfMeasureTableOrderingComposer,
      $$UnitsOfMeasureTableAnnotationComposer,
      $$UnitsOfMeasureTableCreateCompanionBuilder,
      $$UnitsOfMeasureTableUpdateCompanionBuilder,
      (
        UnitOfMeasureRecord,
        BaseReferences<
          _$AppDatabase,
          $UnitsOfMeasureTable,
          UnitOfMeasureRecord
        >,
      ),
      UnitOfMeasureRecord,
      PrefetchHooks Function()
    >;
typedef $$LocationsTableCreateCompanionBuilder =
    LocationsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String?> code,
      required String type,
      Value<String?> parentLocationId,
      required bool isActive,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$LocationsTableUpdateCompanionBuilder =
    LocationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String?> code,
      Value<String> type,
      Value<String?> parentLocationId,
      Value<bool> isActive,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$LocationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentLocationId => $composableBuilder(
    column: $table.parentLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentLocationId => $composableBuilder(
    column: $table.parentLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get parentLocationId => $composableBuilder(
    column: $table.parentLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationsTable,
          LocationRecord,
          $$LocationsTableFilterComposer,
          $$LocationsTableOrderingComposer,
          $$LocationsTableAnnotationComposer,
          $$LocationsTableCreateCompanionBuilder,
          $$LocationsTableUpdateCompanionBuilder,
          (
            LocationRecord,
            BaseReferences<_$AppDatabase, $LocationsTable, LocationRecord>,
          ),
          LocationRecord,
          PrefetchHooks Function()
        > {
  $$LocationsTableTableManager(_$AppDatabase db, $LocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> parentLocationId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion(
                id: id,
                name: name,
                description: description,
                code: code,
                type: type,
                parentLocationId: parentLocationId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> code = const Value.absent(),
                required String type,
                Value<String?> parentLocationId = const Value.absent(),
                required bool isActive,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion.insert(
                id: id,
                name: name,
                description: description,
                code: code,
                type: type,
                parentLocationId: parentLocationId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationsTable,
      LocationRecord,
      $$LocationsTableFilterComposer,
      $$LocationsTableOrderingComposer,
      $$LocationsTableAnnotationComposer,
      $$LocationsTableCreateCompanionBuilder,
      $$LocationsTableUpdateCompanionBuilder,
      (
        LocationRecord,
        BaseReferences<_$AppDatabase, $LocationsTable, LocationRecord>,
      ),
      LocationRecord,
      PrefetchHooks Function()
    >;
typedef $$PeopleTableCreateCompanionBuilder =
    PeopleCompanion Function({
      required String id,
      required String displayName,
      Value<String?> email,
      Value<String?> phone,
      required bool isActive,
      required bool isLoginUser,
      Value<int> rowid,
    });
typedef $$PeopleTableUpdateCompanionBuilder =
    PeopleCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String?> email,
      Value<String?> phone,
      Value<bool> isActive,
      Value<bool> isLoginUser,
      Value<int> rowid,
    });

class $$PeopleTableFilterComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLoginUser => $composableBuilder(
    column: $table.isLoginUser,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeopleTableOrderingComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLoginUser => $composableBuilder(
    column: $table.isLoginUser,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeopleTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isLoginUser => $composableBuilder(
    column: $table.isLoginUser,
    builder: (column) => column,
  );
}

class $$PeopleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeopleTable,
          PersonRecord,
          $$PeopleTableFilterComposer,
          $$PeopleTableOrderingComposer,
          $$PeopleTableAnnotationComposer,
          $$PeopleTableCreateCompanionBuilder,
          $$PeopleTableUpdateCompanionBuilder,
          (
            PersonRecord,
            BaseReferences<_$AppDatabase, $PeopleTable, PersonRecord>,
          ),
          PersonRecord,
          PrefetchHooks Function()
        > {
  $$PeopleTableTableManager(_$AppDatabase db, $PeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isLoginUser = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion(
                id: id,
                displayName: displayName,
                email: email,
                phone: phone,
                isActive: isActive,
                isLoginUser: isLoginUser,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                required bool isActive,
                required bool isLoginUser,
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion.insert(
                id: id,
                displayName: displayName,
                email: email,
                phone: phone,
                isActive: isActive,
                isLoginUser: isLoginUser,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeopleTable,
      PersonRecord,
      $$PeopleTableFilterComposer,
      $$PeopleTableOrderingComposer,
      $$PeopleTableAnnotationComposer,
      $$PeopleTableCreateCompanionBuilder,
      $$PeopleTableUpdateCompanionBuilder,
      (PersonRecord, BaseReferences<_$AppDatabase, $PeopleTable, PersonRecord>),
      PersonRecord,
      PrefetchHooks Function()
    >;
typedef $$AppUsersTableCreateCompanionBuilder =
    AppUsersCompanion Function({
      required String id,
      required String personId,
      required String email,
      required String role,
      required bool isActive,
      Value<String?> pinHash,
      Value<String?> pinSalt,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> lastLoginAt,
      Value<int> rowid,
    });
typedef $$AppUsersTableUpdateCompanionBuilder =
    AppUsersCompanion Function({
      Value<String> id,
      Value<String> personId,
      Value<String> email,
      Value<String> role,
      Value<bool> isActive,
      Value<String?> pinHash,
      Value<String?> pinSalt,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> lastLoginAt,
      Value<int> rowid,
    });

class $$AppUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get pinSalt =>
      $composableBuilder(column: $table.pinSalt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );
}

class $$AppUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsersTable,
          AppUserRecord,
          $$AppUsersTableFilterComposer,
          $$AppUsersTableOrderingComposer,
          $$AppUsersTableAnnotationComposer,
          $$AppUsersTableCreateCompanionBuilder,
          $$AppUsersTableUpdateCompanionBuilder,
          (
            AppUserRecord,
            BaseReferences<_$AppDatabase, $AppUsersTable, AppUserRecord>,
          ),
          AppUserRecord,
          PrefetchHooks Function()
        > {
  $$AppUsersTableTableManager(_$AppDatabase db, $AppUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<String?> pinSalt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsersCompanion(
                id: id,
                personId: personId,
                email: email,
                role: role,
                isActive: isActive,
                pinHash: pinHash,
                pinSalt: pinSalt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastLoginAt: lastLoginAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personId,
                required String email,
                required String role,
                required bool isActive,
                Value<String?> pinHash = const Value.absent(),
                Value<String?> pinSalt = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsersCompanion.insert(
                id: id,
                personId: personId,
                email: email,
                role: role,
                isActive: isActive,
                pinHash: pinHash,
                pinSalt: pinSalt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastLoginAt: lastLoginAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppUsersTable,
      AppUserRecord,
      $$AppUsersTableFilterComposer,
      $$AppUsersTableOrderingComposer,
      $$AppUsersTableAnnotationComposer,
      $$AppUsersTableCreateCompanionBuilder,
      $$AppUsersTableUpdateCompanionBuilder,
      (
        AppUserRecord,
        BaseReferences<_$AppDatabase, $AppUsersTable, AppUserRecord>,
      ),
      AppUserRecord,
      PrefetchHooks Function()
    >;
typedef $$InventoryTransactionsTableCreateCompanionBuilder =
    InventoryTransactionsCompanion Function({
      required String id,
      required String itemId,
      required String transactionType,
      required double quantityDelta,
      required String unitOfMeasureId,
      Value<String?> fromLocationId,
      Value<String?> toLocationId,
      Value<String?> assignedToPersonId,
      Value<String?> assignedToLocationId,
      Value<String?> assignedToTargetId,
      Value<String?> assignedToText,
      Value<String?> performedByUserId,
      Value<String?> notes,
      Value<String?> reversedByTransactionId,
      Value<String?> reversesTransactionId,
      Value<String?> correctionReason,
      Value<DateTime?> correctedAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$InventoryTransactionsTableUpdateCompanionBuilder =
    InventoryTransactionsCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<String> transactionType,
      Value<double> quantityDelta,
      Value<String> unitOfMeasureId,
      Value<String?> fromLocationId,
      Value<String?> toLocationId,
      Value<String?> assignedToPersonId,
      Value<String?> assignedToLocationId,
      Value<String?> assignedToTargetId,
      Value<String?> assignedToText,
      Value<String?> performedByUserId,
      Value<String?> notes,
      Value<String?> reversedByTransactionId,
      Value<String?> reversesTransactionId,
      Value<String?> correctionReason,
      Value<DateTime?> correctedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$InventoryTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryTransactionsTable> {
  $$InventoryTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityDelta => $composableBuilder(
    column: $table.quantityDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromLocationId => $composableBuilder(
    column: $table.fromLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toLocationId => $composableBuilder(
    column: $table.toLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedToPersonId => $composableBuilder(
    column: $table.assignedToPersonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedToLocationId => $composableBuilder(
    column: $table.assignedToLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedToTargetId => $composableBuilder(
    column: $table.assignedToTargetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedToText => $composableBuilder(
    column: $table.assignedToText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get performedByUserId => $composableBuilder(
    column: $table.performedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversedByTransactionId => $composableBuilder(
    column: $table.reversedByTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversesTransactionId => $composableBuilder(
    column: $table.reversesTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctionReason => $composableBuilder(
    column: $table.correctionReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get correctedAt => $composableBuilder(
    column: $table.correctedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventoryTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryTransactionsTable> {
  $$InventoryTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityDelta => $composableBuilder(
    column: $table.quantityDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromLocationId => $composableBuilder(
    column: $table.fromLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toLocationId => $composableBuilder(
    column: $table.toLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedToPersonId => $composableBuilder(
    column: $table.assignedToPersonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedToLocationId => $composableBuilder(
    column: $table.assignedToLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedToTargetId => $composableBuilder(
    column: $table.assignedToTargetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedToText => $composableBuilder(
    column: $table.assignedToText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get performedByUserId => $composableBuilder(
    column: $table.performedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversedByTransactionId => $composableBuilder(
    column: $table.reversedByTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversesTransactionId => $composableBuilder(
    column: $table.reversesTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctionReason => $composableBuilder(
    column: $table.correctionReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get correctedAt => $composableBuilder(
    column: $table.correctedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryTransactionsTable> {
  $$InventoryTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantityDelta => $composableBuilder(
    column: $table.quantityDelta,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromLocationId => $composableBuilder(
    column: $table.fromLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toLocationId => $composableBuilder(
    column: $table.toLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignedToPersonId => $composableBuilder(
    column: $table.assignedToPersonId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignedToLocationId => $composableBuilder(
    column: $table.assignedToLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignedToTargetId => $composableBuilder(
    column: $table.assignedToTargetId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignedToText => $composableBuilder(
    column: $table.assignedToText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get performedByUserId => $composableBuilder(
    column: $table.performedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get reversedByTransactionId => $composableBuilder(
    column: $table.reversedByTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reversesTransactionId => $composableBuilder(
    column: $table.reversesTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctionReason => $composableBuilder(
    column: $table.correctionReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get correctedAt => $composableBuilder(
    column: $table.correctedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InventoryTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryTransactionsTable,
          InventoryTransactionRecord,
          $$InventoryTransactionsTableFilterComposer,
          $$InventoryTransactionsTableOrderingComposer,
          $$InventoryTransactionsTableAnnotationComposer,
          $$InventoryTransactionsTableCreateCompanionBuilder,
          $$InventoryTransactionsTableUpdateCompanionBuilder,
          (
            InventoryTransactionRecord,
            BaseReferences<
              _$AppDatabase,
              $InventoryTransactionsTable,
              InventoryTransactionRecord
            >,
          ),
          InventoryTransactionRecord,
          PrefetchHooks Function()
        > {
  $$InventoryTransactionsTableTableManager(
    _$AppDatabase db,
    $InventoryTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InventoryTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InventoryTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<double> quantityDelta = const Value.absent(),
                Value<String> unitOfMeasureId = const Value.absent(),
                Value<String?> fromLocationId = const Value.absent(),
                Value<String?> toLocationId = const Value.absent(),
                Value<String?> assignedToPersonId = const Value.absent(),
                Value<String?> assignedToLocationId = const Value.absent(),
                Value<String?> assignedToTargetId = const Value.absent(),
                Value<String?> assignedToText = const Value.absent(),
                Value<String?> performedByUserId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> reversedByTransactionId = const Value.absent(),
                Value<String?> reversesTransactionId = const Value.absent(),
                Value<String?> correctionReason = const Value.absent(),
                Value<DateTime?> correctedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryTransactionsCompanion(
                id: id,
                itemId: itemId,
                transactionType: transactionType,
                quantityDelta: quantityDelta,
                unitOfMeasureId: unitOfMeasureId,
                fromLocationId: fromLocationId,
                toLocationId: toLocationId,
                assignedToPersonId: assignedToPersonId,
                assignedToLocationId: assignedToLocationId,
                assignedToTargetId: assignedToTargetId,
                assignedToText: assignedToText,
                performedByUserId: performedByUserId,
                notes: notes,
                reversedByTransactionId: reversedByTransactionId,
                reversesTransactionId: reversesTransactionId,
                correctionReason: correctionReason,
                correctedAt: correctedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required String transactionType,
                required double quantityDelta,
                required String unitOfMeasureId,
                Value<String?> fromLocationId = const Value.absent(),
                Value<String?> toLocationId = const Value.absent(),
                Value<String?> assignedToPersonId = const Value.absent(),
                Value<String?> assignedToLocationId = const Value.absent(),
                Value<String?> assignedToTargetId = const Value.absent(),
                Value<String?> assignedToText = const Value.absent(),
                Value<String?> performedByUserId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> reversedByTransactionId = const Value.absent(),
                Value<String?> reversesTransactionId = const Value.absent(),
                Value<String?> correctionReason = const Value.absent(),
                Value<DateTime?> correctedAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => InventoryTransactionsCompanion.insert(
                id: id,
                itemId: itemId,
                transactionType: transactionType,
                quantityDelta: quantityDelta,
                unitOfMeasureId: unitOfMeasureId,
                fromLocationId: fromLocationId,
                toLocationId: toLocationId,
                assignedToPersonId: assignedToPersonId,
                assignedToLocationId: assignedToLocationId,
                assignedToTargetId: assignedToTargetId,
                assignedToText: assignedToText,
                performedByUserId: performedByUserId,
                notes: notes,
                reversedByTransactionId: reversedByTransactionId,
                reversesTransactionId: reversesTransactionId,
                correctionReason: correctionReason,
                correctedAt: correctedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventoryTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryTransactionsTable,
      InventoryTransactionRecord,
      $$InventoryTransactionsTableFilterComposer,
      $$InventoryTransactionsTableOrderingComposer,
      $$InventoryTransactionsTableAnnotationComposer,
      $$InventoryTransactionsTableCreateCompanionBuilder,
      $$InventoryTransactionsTableUpdateCompanionBuilder,
      (
        InventoryTransactionRecord,
        BaseReferences<
          _$AppDatabase,
          $InventoryTransactionsTable,
          InventoryTransactionRecord
        >,
      ),
      InventoryTransactionRecord,
      PrefetchHooks Function()
    >;
typedef $$ItemLocationBalancesTableCreateCompanionBuilder =
    ItemLocationBalancesCompanion Function({
      required String id,
      required String itemId,
      required String locationId,
      required double quantityOnHand,
      Value<double> minimumQuantity,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ItemLocationBalancesTableUpdateCompanionBuilder =
    ItemLocationBalancesCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<String> locationId,
      Value<double> quantityOnHand,
      Value<double> minimumQuantity,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ItemLocationBalancesTableFilterComposer
    extends Composer<_$AppDatabase, $ItemLocationBalancesTable> {
  $$ItemLocationBalancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityOnHand => $composableBuilder(
    column: $table.quantityOnHand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minimumQuantity => $composableBuilder(
    column: $table.minimumQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemLocationBalancesTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemLocationBalancesTable> {
  $$ItemLocationBalancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityOnHand => $composableBuilder(
    column: $table.quantityOnHand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minimumQuantity => $composableBuilder(
    column: $table.minimumQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemLocationBalancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemLocationBalancesTable> {
  $$ItemLocationBalancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantityOnHand => $composableBuilder(
    column: $table.quantityOnHand,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minimumQuantity => $composableBuilder(
    column: $table.minimumQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ItemLocationBalancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemLocationBalancesTable,
          ItemLocationBalanceRecord,
          $$ItemLocationBalancesTableFilterComposer,
          $$ItemLocationBalancesTableOrderingComposer,
          $$ItemLocationBalancesTableAnnotationComposer,
          $$ItemLocationBalancesTableCreateCompanionBuilder,
          $$ItemLocationBalancesTableUpdateCompanionBuilder,
          (
            ItemLocationBalanceRecord,
            BaseReferences<
              _$AppDatabase,
              $ItemLocationBalancesTable,
              ItemLocationBalanceRecord
            >,
          ),
          ItemLocationBalanceRecord,
          PrefetchHooks Function()
        > {
  $$ItemLocationBalancesTableTableManager(
    _$AppDatabase db,
    $ItemLocationBalancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemLocationBalancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemLocationBalancesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ItemLocationBalancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> locationId = const Value.absent(),
                Value<double> quantityOnHand = const Value.absent(),
                Value<double> minimumQuantity = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemLocationBalancesCompanion(
                id: id,
                itemId: itemId,
                locationId: locationId,
                quantityOnHand: quantityOnHand,
                minimumQuantity: minimumQuantity,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required String locationId,
                required double quantityOnHand,
                Value<double> minimumQuantity = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ItemLocationBalancesCompanion.insert(
                id: id,
                itemId: itemId,
                locationId: locationId,
                quantityOnHand: quantityOnHand,
                minimumQuantity: minimumQuantity,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemLocationBalancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemLocationBalancesTable,
      ItemLocationBalanceRecord,
      $$ItemLocationBalancesTableFilterComposer,
      $$ItemLocationBalancesTableOrderingComposer,
      $$ItemLocationBalancesTableAnnotationComposer,
      $$ItemLocationBalancesTableCreateCompanionBuilder,
      $$ItemLocationBalancesTableUpdateCompanionBuilder,
      (
        ItemLocationBalanceRecord,
        BaseReferences<
          _$AppDatabase,
          $ItemLocationBalancesTable,
          ItemLocationBalanceRecord
        >,
      ),
      ItemLocationBalanceRecord,
      PrefetchHooks Function()
    >;
typedef $$SuppliersTableCreateCompanionBuilder =
    SuppliersCompanion Function({
      required String id,
      required String name,
      Value<String?> contactName,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> website,
      Value<String?> address,
      Value<String?> accountNumber,
      Value<String?> notes,
      Value<int?> defaultLeadTimeDays,
      Value<double?> minimumOrderAmount,
      required bool isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SuppliersTableUpdateCompanionBuilder =
    SuppliersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> contactName,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> website,
      Value<String?> address,
      Value<String?> accountNumber,
      Value<String?> notes,
      Value<int?> defaultLeadTimeDays,
      Value<double?> minimumOrderAmount,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultLeadTimeDays => $composableBuilder(
    column: $table.defaultLeadTimeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minimumOrderAmount => $composableBuilder(
    column: $table.minimumOrderAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultLeadTimeDays => $composableBuilder(
    column: $table.defaultLeadTimeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minimumOrderAmount => $composableBuilder(
    column: $table.minimumOrderAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get defaultLeadTimeDays => $composableBuilder(
    column: $table.defaultLeadTimeDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minimumOrderAmount => $composableBuilder(
    column: $table.minimumOrderAmount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTable,
          SupplierRecord,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (
            SupplierRecord,
            BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRecord>,
          ),
          SupplierRecord,
          PrefetchHooks Function()
        > {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contactName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> accountNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> defaultLeadTimeDays = const Value.absent(),
                Value<double?> minimumOrderAmount = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                name: name,
                contactName: contactName,
                email: email,
                phone: phone,
                website: website,
                address: address,
                accountNumber: accountNumber,
                notes: notes,
                defaultLeadTimeDays: defaultLeadTimeDays,
                minimumOrderAmount: minimumOrderAmount,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> contactName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> accountNumber = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> defaultLeadTimeDays = const Value.absent(),
                Value<double?> minimumOrderAmount = const Value.absent(),
                required bool isActive,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                name: name,
                contactName: contactName,
                email: email,
                phone: phone,
                website: website,
                address: address,
                accountNumber: accountNumber,
                notes: notes,
                defaultLeadTimeDays: defaultLeadTimeDays,
                minimumOrderAmount: minimumOrderAmount,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTable,
      SupplierRecord,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (
        SupplierRecord,
        BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRecord>,
      ),
      SupplierRecord,
      PrefetchHooks Function()
    >;
typedef $$ReorderRequestsTableCreateCompanionBuilder =
    ReorderRequestsCompanion Function({
      required String id,
      required String itemId,
      required double requestedQuantity,
      Value<double> receivedQuantity,
      required String unitOfMeasureId,
      Value<String?> supplierId,
      Value<String?> supplier,
      required String status,
      Value<String?> notes,
      required DateTime createdAt,
      Value<DateTime?> orderedAt,
      Value<DateTime?> receivedAt,
      Value<DateTime?> cancelledAt,
      Value<String?> createdByUserId,
      Value<String?> orderedByUserId,
      Value<String?> receivedByUserId,
      Value<String?> destinationLocationId,
      Value<String?> purchaseUnitOfMeasureId,
      Value<double?> purchaseQuantity,
      Value<double?> purchaseToStockConversionFactor,
      Value<double?> expectedCost,
      Value<String?> orderNumber,
      Value<int> rowid,
    });
typedef $$ReorderRequestsTableUpdateCompanionBuilder =
    ReorderRequestsCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<double> requestedQuantity,
      Value<double> receivedQuantity,
      Value<String> unitOfMeasureId,
      Value<String?> supplierId,
      Value<String?> supplier,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime?> orderedAt,
      Value<DateTime?> receivedAt,
      Value<DateTime?> cancelledAt,
      Value<String?> createdByUserId,
      Value<String?> orderedByUserId,
      Value<String?> receivedByUserId,
      Value<String?> destinationLocationId,
      Value<String?> purchaseUnitOfMeasureId,
      Value<double?> purchaseQuantity,
      Value<double?> purchaseToStockConversionFactor,
      Value<double?> expectedCost,
      Value<String?> orderNumber,
      Value<int> rowid,
    });

class $$ReorderRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $ReorderRequestsTable> {
  $$ReorderRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get requestedQuantity => $composableBuilder(
    column: $table.requestedQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get receivedQuantity => $composableBuilder(
    column: $table.receivedQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get orderedAt => $composableBuilder(
    column: $table.orderedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderedByUserId => $composableBuilder(
    column: $table.orderedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedByUserId => $composableBuilder(
    column: $table.receivedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationLocationId => $composableBuilder(
    column: $table.destinationLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseUnitOfMeasureId => $composableBuilder(
    column: $table.purchaseUnitOfMeasureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchaseQuantity => $composableBuilder(
    column: $table.purchaseQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchaseToStockConversionFactor =>
      $composableBuilder(
        column: $table.purchaseToStockConversionFactor,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<double> get expectedCost => $composableBuilder(
    column: $table.expectedCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReorderRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReorderRequestsTable> {
  $$ReorderRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get requestedQuantity => $composableBuilder(
    column: $table.requestedQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get receivedQuantity => $composableBuilder(
    column: $table.receivedQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get orderedAt => $composableBuilder(
    column: $table.orderedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderedByUserId => $composableBuilder(
    column: $table.orderedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedByUserId => $composableBuilder(
    column: $table.receivedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationLocationId => $composableBuilder(
    column: $table.destinationLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseUnitOfMeasureId => $composableBuilder(
    column: $table.purchaseUnitOfMeasureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchaseQuantity => $composableBuilder(
    column: $table.purchaseQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchaseToStockConversionFactor =>
      $composableBuilder(
        column: $table.purchaseToStockConversionFactor,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<double> get expectedCost => $composableBuilder(
    column: $table.expectedCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReorderRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReorderRequestsTable> {
  $$ReorderRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<double> get requestedQuantity => $composableBuilder(
    column: $table.requestedQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get receivedQuantity => $composableBuilder(
    column: $table.receivedQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get orderedAt =>
      $composableBuilder(column: $table.orderedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderedByUserId => $composableBuilder(
    column: $table.orderedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receivedByUserId => $composableBuilder(
    column: $table.receivedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationLocationId => $composableBuilder(
    column: $table.destinationLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purchaseUnitOfMeasureId => $composableBuilder(
    column: $table.purchaseUnitOfMeasureId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get purchaseQuantity => $composableBuilder(
    column: $table.purchaseQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get purchaseToStockConversionFactor =>
      $composableBuilder(
        column: $table.purchaseToStockConversionFactor,
        builder: (column) => column,
      );

  GeneratedColumn<double> get expectedCost => $composableBuilder(
    column: $table.expectedCost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => column,
  );
}

class $$ReorderRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReorderRequestsTable,
          ReorderRequestRecord,
          $$ReorderRequestsTableFilterComposer,
          $$ReorderRequestsTableOrderingComposer,
          $$ReorderRequestsTableAnnotationComposer,
          $$ReorderRequestsTableCreateCompanionBuilder,
          $$ReorderRequestsTableUpdateCompanionBuilder,
          (
            ReorderRequestRecord,
            BaseReferences<
              _$AppDatabase,
              $ReorderRequestsTable,
              ReorderRequestRecord
            >,
          ),
          ReorderRequestRecord,
          PrefetchHooks Function()
        > {
  $$ReorderRequestsTableTableManager(
    _$AppDatabase db,
    $ReorderRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReorderRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReorderRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReorderRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<double> requestedQuantity = const Value.absent(),
                Value<double> receivedQuantity = const Value.absent(),
                Value<String> unitOfMeasureId = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> orderedAt = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> createdByUserId = const Value.absent(),
                Value<String?> orderedByUserId = const Value.absent(),
                Value<String?> receivedByUserId = const Value.absent(),
                Value<String?> destinationLocationId = const Value.absent(),
                Value<String?> purchaseUnitOfMeasureId = const Value.absent(),
                Value<double?> purchaseQuantity = const Value.absent(),
                Value<double?> purchaseToStockConversionFactor =
                    const Value.absent(),
                Value<double?> expectedCost = const Value.absent(),
                Value<String?> orderNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReorderRequestsCompanion(
                id: id,
                itemId: itemId,
                requestedQuantity: requestedQuantity,
                receivedQuantity: receivedQuantity,
                unitOfMeasureId: unitOfMeasureId,
                supplierId: supplierId,
                supplier: supplier,
                status: status,
                notes: notes,
                createdAt: createdAt,
                orderedAt: orderedAt,
                receivedAt: receivedAt,
                cancelledAt: cancelledAt,
                createdByUserId: createdByUserId,
                orderedByUserId: orderedByUserId,
                receivedByUserId: receivedByUserId,
                destinationLocationId: destinationLocationId,
                purchaseUnitOfMeasureId: purchaseUnitOfMeasureId,
                purchaseQuantity: purchaseQuantity,
                purchaseToStockConversionFactor:
                    purchaseToStockConversionFactor,
                expectedCost: expectedCost,
                orderNumber: orderNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required double requestedQuantity,
                Value<double> receivedQuantity = const Value.absent(),
                required String unitOfMeasureId,
                Value<String?> supplierId = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                required String status,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> orderedAt = const Value.absent(),
                Value<DateTime?> receivedAt = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> createdByUserId = const Value.absent(),
                Value<String?> orderedByUserId = const Value.absent(),
                Value<String?> receivedByUserId = const Value.absent(),
                Value<String?> destinationLocationId = const Value.absent(),
                Value<String?> purchaseUnitOfMeasureId = const Value.absent(),
                Value<double?> purchaseQuantity = const Value.absent(),
                Value<double?> purchaseToStockConversionFactor =
                    const Value.absent(),
                Value<double?> expectedCost = const Value.absent(),
                Value<String?> orderNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReorderRequestsCompanion.insert(
                id: id,
                itemId: itemId,
                requestedQuantity: requestedQuantity,
                receivedQuantity: receivedQuantity,
                unitOfMeasureId: unitOfMeasureId,
                supplierId: supplierId,
                supplier: supplier,
                status: status,
                notes: notes,
                createdAt: createdAt,
                orderedAt: orderedAt,
                receivedAt: receivedAt,
                cancelledAt: cancelledAt,
                createdByUserId: createdByUserId,
                orderedByUserId: orderedByUserId,
                receivedByUserId: receivedByUserId,
                destinationLocationId: destinationLocationId,
                purchaseUnitOfMeasureId: purchaseUnitOfMeasureId,
                purchaseQuantity: purchaseQuantity,
                purchaseToStockConversionFactor:
                    purchaseToStockConversionFactor,
                expectedCost: expectedCost,
                orderNumber: orderNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReorderRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReorderRequestsTable,
      ReorderRequestRecord,
      $$ReorderRequestsTableFilterComposer,
      $$ReorderRequestsTableOrderingComposer,
      $$ReorderRequestsTableAnnotationComposer,
      $$ReorderRequestsTableCreateCompanionBuilder,
      $$ReorderRequestsTableUpdateCompanionBuilder,
      (
        ReorderRequestRecord,
        BaseReferences<
          _$AppDatabase,
          $ReorderRequestsTable,
          ReorderRequestRecord
        >,
      ),
      ReorderRequestRecord,
      PrefetchHooks Function()
    >;
typedef $$CheckoutRecordsTableCreateCompanionBuilder =
    CheckoutRecordsCompanion Function({
      required String id,
      required String itemId,
      Value<String?> assignedToPersonId,
      Value<String?> assignedToLocationId,
      Value<String?> assignedToTargetId,
      Value<String?> assignedToText,
      required double quantity,
      Value<double> quantityReturned,
      Value<String?> sourceLocationId,
      required String unitOfMeasureId,
      required String status,
      required DateTime checkedOutAt,
      Value<DateTime?> dueAt,
      Value<DateTime?> returnedAt,
      Value<String?> checkedOutByUserId,
      Value<String?> returnedByUserId,
      Value<String?> notes,
      Value<String?> returnNotes,
      Value<String?> conditionOnReturn,
      Value<int> rowid,
    });
typedef $$CheckoutRecordsTableUpdateCompanionBuilder =
    CheckoutRecordsCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<String?> assignedToPersonId,
      Value<String?> assignedToLocationId,
      Value<String?> assignedToTargetId,
      Value<String?> assignedToText,
      Value<double> quantity,
      Value<double> quantityReturned,
      Value<String?> sourceLocationId,
      Value<String> unitOfMeasureId,
      Value<String> status,
      Value<DateTime> checkedOutAt,
      Value<DateTime?> dueAt,
      Value<DateTime?> returnedAt,
      Value<String?> checkedOutByUserId,
      Value<String?> returnedByUserId,
      Value<String?> notes,
      Value<String?> returnNotes,
      Value<String?> conditionOnReturn,
      Value<int> rowid,
    });

class $$CheckoutRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckoutRecordsTable> {
  $$CheckoutRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedToPersonId => $composableBuilder(
    column: $table.assignedToPersonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedToLocationId => $composableBuilder(
    column: $table.assignedToLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedToTargetId => $composableBuilder(
    column: $table.assignedToTargetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedToText => $composableBuilder(
    column: $table.assignedToText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityReturned => $composableBuilder(
    column: $table.quantityReturned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLocationId => $composableBuilder(
    column: $table.sourceLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkedOutAt => $composableBuilder(
    column: $table.checkedOutAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get returnedAt => $composableBuilder(
    column: $table.returnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkedOutByUserId => $composableBuilder(
    column: $table.checkedOutByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get returnedByUserId => $composableBuilder(
    column: $table.returnedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get returnNotes => $composableBuilder(
    column: $table.returnNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionOnReturn => $composableBuilder(
    column: $table.conditionOnReturn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CheckoutRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckoutRecordsTable> {
  $$CheckoutRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedToPersonId => $composableBuilder(
    column: $table.assignedToPersonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedToLocationId => $composableBuilder(
    column: $table.assignedToLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedToTargetId => $composableBuilder(
    column: $table.assignedToTargetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedToText => $composableBuilder(
    column: $table.assignedToText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityReturned => $composableBuilder(
    column: $table.quantityReturned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLocationId => $composableBuilder(
    column: $table.sourceLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkedOutAt => $composableBuilder(
    column: $table.checkedOutAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get returnedAt => $composableBuilder(
    column: $table.returnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkedOutByUserId => $composableBuilder(
    column: $table.checkedOutByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get returnedByUserId => $composableBuilder(
    column: $table.returnedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get returnNotes => $composableBuilder(
    column: $table.returnNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionOnReturn => $composableBuilder(
    column: $table.conditionOnReturn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CheckoutRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckoutRecordsTable> {
  $$CheckoutRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get assignedToPersonId => $composableBuilder(
    column: $table.assignedToPersonId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignedToLocationId => $composableBuilder(
    column: $table.assignedToLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignedToTargetId => $composableBuilder(
    column: $table.assignedToTargetId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignedToText => $composableBuilder(
    column: $table.assignedToText,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get quantityReturned => $composableBuilder(
    column: $table.quantityReturned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceLocationId => $composableBuilder(
    column: $table.sourceLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedOutAt => $composableBuilder(
    column: $table.checkedOutAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get returnedAt => $composableBuilder(
    column: $table.returnedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checkedOutByUserId => $composableBuilder(
    column: $table.checkedOutByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get returnedByUserId => $composableBuilder(
    column: $table.returnedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get returnNotes => $composableBuilder(
    column: $table.returnNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conditionOnReturn => $composableBuilder(
    column: $table.conditionOnReturn,
    builder: (column) => column,
  );
}

class $$CheckoutRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckoutRecordsTable,
          CheckoutRecordRow,
          $$CheckoutRecordsTableFilterComposer,
          $$CheckoutRecordsTableOrderingComposer,
          $$CheckoutRecordsTableAnnotationComposer,
          $$CheckoutRecordsTableCreateCompanionBuilder,
          $$CheckoutRecordsTableUpdateCompanionBuilder,
          (
            CheckoutRecordRow,
            BaseReferences<
              _$AppDatabase,
              $CheckoutRecordsTable,
              CheckoutRecordRow
            >,
          ),
          CheckoutRecordRow,
          PrefetchHooks Function()
        > {
  $$CheckoutRecordsTableTableManager(
    _$AppDatabase db,
    $CheckoutRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckoutRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckoutRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckoutRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> assignedToPersonId = const Value.absent(),
                Value<String?> assignedToLocationId = const Value.absent(),
                Value<String?> assignedToTargetId = const Value.absent(),
                Value<String?> assignedToText = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> quantityReturned = const Value.absent(),
                Value<String?> sourceLocationId = const Value.absent(),
                Value<String> unitOfMeasureId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> checkedOutAt = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> returnedAt = const Value.absent(),
                Value<String?> checkedOutByUserId = const Value.absent(),
                Value<String?> returnedByUserId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> returnNotes = const Value.absent(),
                Value<String?> conditionOnReturn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CheckoutRecordsCompanion(
                id: id,
                itemId: itemId,
                assignedToPersonId: assignedToPersonId,
                assignedToLocationId: assignedToLocationId,
                assignedToTargetId: assignedToTargetId,
                assignedToText: assignedToText,
                quantity: quantity,
                quantityReturned: quantityReturned,
                sourceLocationId: sourceLocationId,
                unitOfMeasureId: unitOfMeasureId,
                status: status,
                checkedOutAt: checkedOutAt,
                dueAt: dueAt,
                returnedAt: returnedAt,
                checkedOutByUserId: checkedOutByUserId,
                returnedByUserId: returnedByUserId,
                notes: notes,
                returnNotes: returnNotes,
                conditionOnReturn: conditionOnReturn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                Value<String?> assignedToPersonId = const Value.absent(),
                Value<String?> assignedToLocationId = const Value.absent(),
                Value<String?> assignedToTargetId = const Value.absent(),
                Value<String?> assignedToText = const Value.absent(),
                required double quantity,
                Value<double> quantityReturned = const Value.absent(),
                Value<String?> sourceLocationId = const Value.absent(),
                required String unitOfMeasureId,
                required String status,
                required DateTime checkedOutAt,
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> returnedAt = const Value.absent(),
                Value<String?> checkedOutByUserId = const Value.absent(),
                Value<String?> returnedByUserId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> returnNotes = const Value.absent(),
                Value<String?> conditionOnReturn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CheckoutRecordsCompanion.insert(
                id: id,
                itemId: itemId,
                assignedToPersonId: assignedToPersonId,
                assignedToLocationId: assignedToLocationId,
                assignedToTargetId: assignedToTargetId,
                assignedToText: assignedToText,
                quantity: quantity,
                quantityReturned: quantityReturned,
                sourceLocationId: sourceLocationId,
                unitOfMeasureId: unitOfMeasureId,
                status: status,
                checkedOutAt: checkedOutAt,
                dueAt: dueAt,
                returnedAt: returnedAt,
                checkedOutByUserId: checkedOutByUserId,
                returnedByUserId: returnedByUserId,
                notes: notes,
                returnNotes: returnNotes,
                conditionOnReturn: conditionOnReturn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CheckoutRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckoutRecordsTable,
      CheckoutRecordRow,
      $$CheckoutRecordsTableFilterComposer,
      $$CheckoutRecordsTableOrderingComposer,
      $$CheckoutRecordsTableAnnotationComposer,
      $$CheckoutRecordsTableCreateCompanionBuilder,
      $$CheckoutRecordsTableUpdateCompanionBuilder,
      (
        CheckoutRecordRow,
        BaseReferences<_$AppDatabase, $CheckoutRecordsTable, CheckoutRecordRow>,
      ),
      CheckoutRecordRow,
      PrefetchHooks Function()
    >;
typedef $$AssignmentTargetsTableCreateCompanionBuilder =
    AssignmentTargetsCompanion Function({
      required String id,
      required String name,
      required String targetType,
      Value<String?> code,
      Value<String?> description,
      Value<String?> locationId,
      required bool isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AssignmentTargetsTableUpdateCompanionBuilder =
    AssignmentTargetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> targetType,
      Value<String?> code,
      Value<String?> description,
      Value<String?> locationId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AssignmentTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $AssignmentTargetsTable> {
  $$AssignmentTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssignmentTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssignmentTargetsTable> {
  $$AssignmentTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssignmentTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssignmentTargetsTable> {
  $$AssignmentTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AssignmentTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssignmentTargetsTable,
          AssignmentTargetRecord,
          $$AssignmentTargetsTableFilterComposer,
          $$AssignmentTargetsTableOrderingComposer,
          $$AssignmentTargetsTableAnnotationComposer,
          $$AssignmentTargetsTableCreateCompanionBuilder,
          $$AssignmentTargetsTableUpdateCompanionBuilder,
          (
            AssignmentTargetRecord,
            BaseReferences<
              _$AppDatabase,
              $AssignmentTargetsTable,
              AssignmentTargetRecord
            >,
          ),
          AssignmentTargetRecord,
          PrefetchHooks Function()
        > {
  $$AssignmentTargetsTableTableManager(
    _$AppDatabase db,
    $AssignmentTargetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssignmentTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssignmentTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssignmentTargetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> locationId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssignmentTargetsCompanion(
                id: id,
                name: name,
                targetType: targetType,
                code: code,
                description: description,
                locationId: locationId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String targetType,
                Value<String?> code = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> locationId = const Value.absent(),
                required bool isActive,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AssignmentTargetsCompanion.insert(
                id: id,
                name: name,
                targetType: targetType,
                code: code,
                description: description,
                locationId: locationId,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssignmentTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssignmentTargetsTable,
      AssignmentTargetRecord,
      $$AssignmentTargetsTableFilterComposer,
      $$AssignmentTargetsTableOrderingComposer,
      $$AssignmentTargetsTableAnnotationComposer,
      $$AssignmentTargetsTableCreateCompanionBuilder,
      $$AssignmentTargetsTableUpdateCompanionBuilder,
      (
        AssignmentTargetRecord,
        BaseReferences<
          _$AppDatabase,
          $AssignmentTargetsTable,
          AssignmentTargetRecord
        >,
      ),
      AssignmentTargetRecord,
      PrefetchHooks Function()
    >;
typedef $$CycleCountSessionsTableCreateCompanionBuilder =
    CycleCountSessionsCompanion Function({
      required String id,
      required String name,
      required String status,
      Value<String?> assignedToUserId,
      required bool blindCount,
      Value<DateTime?> dueAt,
      required DateTime createdAt,
      Value<DateTime?> submittedAt,
      Value<DateTime?> approvedAt,
      Value<int> rowid,
    });
typedef $$CycleCountSessionsTableUpdateCompanionBuilder =
    CycleCountSessionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> status,
      Value<String?> assignedToUserId,
      Value<bool> blindCount,
      Value<DateTime?> dueAt,
      Value<DateTime> createdAt,
      Value<DateTime?> submittedAt,
      Value<DateTime?> approvedAt,
      Value<int> rowid,
    });

class $$CycleCountSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $CycleCountSessionsTable> {
  $$CycleCountSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedToUserId => $composableBuilder(
    column: $table.assignedToUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get blindCount => $composableBuilder(
    column: $table.blindCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get approvedAt => $composableBuilder(
    column: $table.approvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CycleCountSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CycleCountSessionsTable> {
  $$CycleCountSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedToUserId => $composableBuilder(
    column: $table.assignedToUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get blindCount => $composableBuilder(
    column: $table.blindCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get approvedAt => $composableBuilder(
    column: $table.approvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CycleCountSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CycleCountSessionsTable> {
  $$CycleCountSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get assignedToUserId => $composableBuilder(
    column: $table.assignedToUserId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get blindCount => $composableBuilder(
    column: $table.blindCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get approvedAt => $composableBuilder(
    column: $table.approvedAt,
    builder: (column) => column,
  );
}

class $$CycleCountSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CycleCountSessionsTable,
          CycleCountSessionRecord,
          $$CycleCountSessionsTableFilterComposer,
          $$CycleCountSessionsTableOrderingComposer,
          $$CycleCountSessionsTableAnnotationComposer,
          $$CycleCountSessionsTableCreateCompanionBuilder,
          $$CycleCountSessionsTableUpdateCompanionBuilder,
          (
            CycleCountSessionRecord,
            BaseReferences<
              _$AppDatabase,
              $CycleCountSessionsTable,
              CycleCountSessionRecord
            >,
          ),
          CycleCountSessionRecord,
          PrefetchHooks Function()
        > {
  $$CycleCountSessionsTableTableManager(
    _$AppDatabase db,
    $CycleCountSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CycleCountSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CycleCountSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CycleCountSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> assignedToUserId = const Value.absent(),
                Value<bool> blindCount = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<DateTime?> approvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CycleCountSessionsCompanion(
                id: id,
                name: name,
                status: status,
                assignedToUserId: assignedToUserId,
                blindCount: blindCount,
                dueAt: dueAt,
                createdAt: createdAt,
                submittedAt: submittedAt,
                approvedAt: approvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String status,
                Value<String?> assignedToUserId = const Value.absent(),
                required bool blindCount,
                Value<DateTime?> dueAt = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<DateTime?> approvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CycleCountSessionsCompanion.insert(
                id: id,
                name: name,
                status: status,
                assignedToUserId: assignedToUserId,
                blindCount: blindCount,
                dueAt: dueAt,
                createdAt: createdAt,
                submittedAt: submittedAt,
                approvedAt: approvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CycleCountSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CycleCountSessionsTable,
      CycleCountSessionRecord,
      $$CycleCountSessionsTableFilterComposer,
      $$CycleCountSessionsTableOrderingComposer,
      $$CycleCountSessionsTableAnnotationComposer,
      $$CycleCountSessionsTableCreateCompanionBuilder,
      $$CycleCountSessionsTableUpdateCompanionBuilder,
      (
        CycleCountSessionRecord,
        BaseReferences<
          _$AppDatabase,
          $CycleCountSessionsTable,
          CycleCountSessionRecord
        >,
      ),
      CycleCountSessionRecord,
      PrefetchHooks Function()
    >;
typedef $$CycleCountLinesTableCreateCompanionBuilder =
    CycleCountLinesCompanion Function({
      required String id,
      required String sessionId,
      required String itemId,
      required String locationId,
      required double expectedQuantity,
      Value<double?> countedQuantity,
      Value<double?> varianceQuantity,
      required String unitOfMeasureId,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$CycleCountLinesTableUpdateCompanionBuilder =
    CycleCountLinesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> itemId,
      Value<String> locationId,
      Value<double> expectedQuantity,
      Value<double?> countedQuantity,
      Value<double?> varianceQuantity,
      Value<String> unitOfMeasureId,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$CycleCountLinesTableFilterComposer
    extends Composer<_$AppDatabase, $CycleCountLinesTable> {
  $$CycleCountLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expectedQuantity => $composableBuilder(
    column: $table.expectedQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get countedQuantity => $composableBuilder(
    column: $table.countedQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get varianceQuantity => $composableBuilder(
    column: $table.varianceQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CycleCountLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $CycleCountLinesTable> {
  $$CycleCountLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expectedQuantity => $composableBuilder(
    column: $table.expectedQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get countedQuantity => $composableBuilder(
    column: $table.countedQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get varianceQuantity => $composableBuilder(
    column: $table.varianceQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CycleCountLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CycleCountLinesTable> {
  $$CycleCountLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get expectedQuantity => $composableBuilder(
    column: $table.expectedQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get countedQuantity => $composableBuilder(
    column: $table.countedQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get varianceQuantity => $composableBuilder(
    column: $table.varianceQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitOfMeasureId => $composableBuilder(
    column: $table.unitOfMeasureId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$CycleCountLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CycleCountLinesTable,
          CycleCountLineRecord,
          $$CycleCountLinesTableFilterComposer,
          $$CycleCountLinesTableOrderingComposer,
          $$CycleCountLinesTableAnnotationComposer,
          $$CycleCountLinesTableCreateCompanionBuilder,
          $$CycleCountLinesTableUpdateCompanionBuilder,
          (
            CycleCountLineRecord,
            BaseReferences<
              _$AppDatabase,
              $CycleCountLinesTable,
              CycleCountLineRecord
            >,
          ),
          CycleCountLineRecord,
          PrefetchHooks Function()
        > {
  $$CycleCountLinesTableTableManager(
    _$AppDatabase db,
    $CycleCountLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CycleCountLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CycleCountLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CycleCountLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> locationId = const Value.absent(),
                Value<double> expectedQuantity = const Value.absent(),
                Value<double?> countedQuantity = const Value.absent(),
                Value<double?> varianceQuantity = const Value.absent(),
                Value<String> unitOfMeasureId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CycleCountLinesCompanion(
                id: id,
                sessionId: sessionId,
                itemId: itemId,
                locationId: locationId,
                expectedQuantity: expectedQuantity,
                countedQuantity: countedQuantity,
                varianceQuantity: varianceQuantity,
                unitOfMeasureId: unitOfMeasureId,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String itemId,
                required String locationId,
                required double expectedQuantity,
                Value<double?> countedQuantity = const Value.absent(),
                Value<double?> varianceQuantity = const Value.absent(),
                required String unitOfMeasureId,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CycleCountLinesCompanion.insert(
                id: id,
                sessionId: sessionId,
                itemId: itemId,
                locationId: locationId,
                expectedQuantity: expectedQuantity,
                countedQuantity: countedQuantity,
                varianceQuantity: varianceQuantity,
                unitOfMeasureId: unitOfMeasureId,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CycleCountLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CycleCountLinesTable,
      CycleCountLineRecord,
      $$CycleCountLinesTableFilterComposer,
      $$CycleCountLinesTableOrderingComposer,
      $$CycleCountLinesTableAnnotationComposer,
      $$CycleCountLinesTableCreateCompanionBuilder,
      $$CycleCountLinesTableUpdateCompanionBuilder,
      (
        CycleCountLineRecord,
        BaseReferences<
          _$AppDatabase,
          $CycleCountLinesTable,
          CycleCountLineRecord
        >,
      ),
      CycleCountLineRecord,
      PrefetchHooks Function()
    >;
typedef $$CustomFieldDefinitionsTableCreateCompanionBuilder =
    CustomFieldDefinitionsCompanion Function({
      required String id,
      required String entityType,
      required String name,
      required String fieldType,
      required bool isRequired,
      required String optionsJson,
      Value<String?> appliesToItemType,
      Value<String?> appliesToCategory,
      Value<int> sortOrder,
      required bool isActive,
      Value<int> rowid,
    });
typedef $$CustomFieldDefinitionsTableUpdateCompanionBuilder =
    CustomFieldDefinitionsCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> name,
      Value<String> fieldType,
      Value<bool> isRequired,
      Value<String> optionsJson,
      Value<String?> appliesToItemType,
      Value<String?> appliesToCategory,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$CustomFieldDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomFieldDefinitionsTable> {
  $$CustomFieldDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldType => $composableBuilder(
    column: $table.fieldType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliesToItemType => $composableBuilder(
    column: $table.appliesToItemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliesToCategory => $composableBuilder(
    column: $table.appliesToCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomFieldDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomFieldDefinitionsTable> {
  $$CustomFieldDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldType => $composableBuilder(
    column: $table.fieldType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliesToItemType => $composableBuilder(
    column: $table.appliesToItemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliesToCategory => $composableBuilder(
    column: $table.appliesToCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomFieldDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomFieldDefinitionsTable> {
  $$CustomFieldDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fieldType =>
      $composableBuilder(column: $table.fieldType, builder: (column) => column);

  GeneratedColumn<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => column,
  );

  GeneratedColumn<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appliesToItemType => $composableBuilder(
    column: $table.appliesToItemType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appliesToCategory => $composableBuilder(
    column: $table.appliesToCategory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$CustomFieldDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomFieldDefinitionsTable,
          CustomFieldDefinitionRecord,
          $$CustomFieldDefinitionsTableFilterComposer,
          $$CustomFieldDefinitionsTableOrderingComposer,
          $$CustomFieldDefinitionsTableAnnotationComposer,
          $$CustomFieldDefinitionsTableCreateCompanionBuilder,
          $$CustomFieldDefinitionsTableUpdateCompanionBuilder,
          (
            CustomFieldDefinitionRecord,
            BaseReferences<
              _$AppDatabase,
              $CustomFieldDefinitionsTable,
              CustomFieldDefinitionRecord
            >,
          ),
          CustomFieldDefinitionRecord,
          PrefetchHooks Function()
        > {
  $$CustomFieldDefinitionsTableTableManager(
    _$AppDatabase db,
    $CustomFieldDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFieldDefinitionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CustomFieldDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomFieldDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fieldType = const Value.absent(),
                Value<bool> isRequired = const Value.absent(),
                Value<String> optionsJson = const Value.absent(),
                Value<String?> appliesToItemType = const Value.absent(),
                Value<String?> appliesToCategory = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomFieldDefinitionsCompanion(
                id: id,
                entityType: entityType,
                name: name,
                fieldType: fieldType,
                isRequired: isRequired,
                optionsJson: optionsJson,
                appliesToItemType: appliesToItemType,
                appliesToCategory: appliesToCategory,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String name,
                required String fieldType,
                required bool isRequired,
                required String optionsJson,
                Value<String?> appliesToItemType = const Value.absent(),
                Value<String?> appliesToCategory = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required bool isActive,
                Value<int> rowid = const Value.absent(),
              }) => CustomFieldDefinitionsCompanion.insert(
                id: id,
                entityType: entityType,
                name: name,
                fieldType: fieldType,
                isRequired: isRequired,
                optionsJson: optionsJson,
                appliesToItemType: appliesToItemType,
                appliesToCategory: appliesToCategory,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomFieldDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomFieldDefinitionsTable,
      CustomFieldDefinitionRecord,
      $$CustomFieldDefinitionsTableFilterComposer,
      $$CustomFieldDefinitionsTableOrderingComposer,
      $$CustomFieldDefinitionsTableAnnotationComposer,
      $$CustomFieldDefinitionsTableCreateCompanionBuilder,
      $$CustomFieldDefinitionsTableUpdateCompanionBuilder,
      (
        CustomFieldDefinitionRecord,
        BaseReferences<
          _$AppDatabase,
          $CustomFieldDefinitionsTable,
          CustomFieldDefinitionRecord
        >,
      ),
      CustomFieldDefinitionRecord,
      PrefetchHooks Function()
    >;
typedef $$CustomFieldValuesTableCreateCompanionBuilder =
    CustomFieldValuesCompanion Function({
      required String id,
      required String definitionId,
      required String entityId,
      Value<String?> textValue,
      Value<double?> numberValue,
      Value<DateTime?> dateValue,
      Value<bool?> booleanValue,
      Value<String?> selectedOption,
      Value<int> rowid,
    });
typedef $$CustomFieldValuesTableUpdateCompanionBuilder =
    CustomFieldValuesCompanion Function({
      Value<String> id,
      Value<String> definitionId,
      Value<String> entityId,
      Value<String?> textValue,
      Value<double?> numberValue,
      Value<DateTime?> dateValue,
      Value<bool?> booleanValue,
      Value<String?> selectedOption,
      Value<int> rowid,
    });

class $$CustomFieldValuesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomFieldValuesTable> {
  $$CustomFieldValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definitionId => $composableBuilder(
    column: $table.definitionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get numberValue => $composableBuilder(
    column: $table.numberValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateValue => $composableBuilder(
    column: $table.dateValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get booleanValue => $composableBuilder(
    column: $table.booleanValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedOption => $composableBuilder(
    column: $table.selectedOption,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomFieldValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomFieldValuesTable> {
  $$CustomFieldValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definitionId => $composableBuilder(
    column: $table.definitionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get numberValue => $composableBuilder(
    column: $table.numberValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateValue => $composableBuilder(
    column: $table.dateValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get booleanValue => $composableBuilder(
    column: $table.booleanValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedOption => $composableBuilder(
    column: $table.selectedOption,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomFieldValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomFieldValuesTable> {
  $$CustomFieldValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get definitionId => $composableBuilder(
    column: $table.definitionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  GeneratedColumn<double> get numberValue => $composableBuilder(
    column: $table.numberValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateValue =>
      $composableBuilder(column: $table.dateValue, builder: (column) => column);

  GeneratedColumn<bool> get booleanValue => $composableBuilder(
    column: $table.booleanValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedOption => $composableBuilder(
    column: $table.selectedOption,
    builder: (column) => column,
  );
}

class $$CustomFieldValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomFieldValuesTable,
          CustomFieldValueRecord,
          $$CustomFieldValuesTableFilterComposer,
          $$CustomFieldValuesTableOrderingComposer,
          $$CustomFieldValuesTableAnnotationComposer,
          $$CustomFieldValuesTableCreateCompanionBuilder,
          $$CustomFieldValuesTableUpdateCompanionBuilder,
          (
            CustomFieldValueRecord,
            BaseReferences<
              _$AppDatabase,
              $CustomFieldValuesTable,
              CustomFieldValueRecord
            >,
          ),
          CustomFieldValueRecord,
          PrefetchHooks Function()
        > {
  $$CustomFieldValuesTableTableManager(
    _$AppDatabase db,
    $CustomFieldValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFieldValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomFieldValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomFieldValuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> definitionId = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String?> textValue = const Value.absent(),
                Value<double?> numberValue = const Value.absent(),
                Value<DateTime?> dateValue = const Value.absent(),
                Value<bool?> booleanValue = const Value.absent(),
                Value<String?> selectedOption = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomFieldValuesCompanion(
                id: id,
                definitionId: definitionId,
                entityId: entityId,
                textValue: textValue,
                numberValue: numberValue,
                dateValue: dateValue,
                booleanValue: booleanValue,
                selectedOption: selectedOption,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String definitionId,
                required String entityId,
                Value<String?> textValue = const Value.absent(),
                Value<double?> numberValue = const Value.absent(),
                Value<DateTime?> dateValue = const Value.absent(),
                Value<bool?> booleanValue = const Value.absent(),
                Value<String?> selectedOption = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomFieldValuesCompanion.insert(
                id: id,
                definitionId: definitionId,
                entityId: entityId,
                textValue: textValue,
                numberValue: numberValue,
                dateValue: dateValue,
                booleanValue: booleanValue,
                selectedOption: selectedOption,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomFieldValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomFieldValuesTable,
      CustomFieldValueRecord,
      $$CustomFieldValuesTableFilterComposer,
      $$CustomFieldValuesTableOrderingComposer,
      $$CustomFieldValuesTableAnnotationComposer,
      $$CustomFieldValuesTableCreateCompanionBuilder,
      $$CustomFieldValuesTableUpdateCompanionBuilder,
      (
        CustomFieldValueRecord,
        BaseReferences<
          _$AppDatabase,
          $CustomFieldValuesTable,
          CustomFieldValueRecord
        >,
      ),
      CustomFieldValueRecord,
      PrefetchHooks Function()
    >;
typedef $$PlansTableCreateCompanionBuilder =
    PlansCompanion Function({
      required String code,
      required String name,
      required int itemLimit,
      required int userLimit,
      required int locationLimit,
      required int photoLimit,
      required int labelExportLimit,
      Value<int> rowid,
    });
typedef $$PlansTableUpdateCompanionBuilder =
    PlansCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<int> itemLimit,
      Value<int> userLimit,
      Value<int> locationLimit,
      Value<int> photoLimit,
      Value<int> labelExportLimit,
      Value<int> rowid,
    });

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemLimit => $composableBuilder(
    column: $table.itemLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userLimit => $composableBuilder(
    column: $table.userLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get locationLimit => $composableBuilder(
    column: $table.locationLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get photoLimit => $composableBuilder(
    column: $table.photoLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get labelExportLimit => $composableBuilder(
    column: $table.labelExportLimit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemLimit => $composableBuilder(
    column: $table.itemLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userLimit => $composableBuilder(
    column: $table.userLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get locationLimit => $composableBuilder(
    column: $table.locationLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get photoLimit => $composableBuilder(
    column: $table.photoLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get labelExportLimit => $composableBuilder(
    column: $table.labelExportLimit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get itemLimit =>
      $composableBuilder(column: $table.itemLimit, builder: (column) => column);

  GeneratedColumn<int> get userLimit =>
      $composableBuilder(column: $table.userLimit, builder: (column) => column);

  GeneratedColumn<int> get locationLimit => $composableBuilder(
    column: $table.locationLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get photoLimit => $composableBuilder(
    column: $table.photoLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get labelExportLimit => $composableBuilder(
    column: $table.labelExportLimit,
    builder: (column) => column,
  );
}

class $$PlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlansTable,
          PlanRecord,
          $$PlansTableFilterComposer,
          $$PlansTableOrderingComposer,
          $$PlansTableAnnotationComposer,
          $$PlansTableCreateCompanionBuilder,
          $$PlansTableUpdateCompanionBuilder,
          (PlanRecord, BaseReferences<_$AppDatabase, $PlansTable, PlanRecord>),
          PlanRecord,
          PrefetchHooks Function()
        > {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> itemLimit = const Value.absent(),
                Value<int> userLimit = const Value.absent(),
                Value<int> locationLimit = const Value.absent(),
                Value<int> photoLimit = const Value.absent(),
                Value<int> labelExportLimit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion(
                code: code,
                name: name,
                itemLimit: itemLimit,
                userLimit: userLimit,
                locationLimit: locationLimit,
                photoLimit: photoLimit,
                labelExportLimit: labelExportLimit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required int itemLimit,
                required int userLimit,
                required int locationLimit,
                required int photoLimit,
                required int labelExportLimit,
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion.insert(
                code: code,
                name: name,
                itemLimit: itemLimit,
                userLimit: userLimit,
                locationLimit: locationLimit,
                photoLimit: photoLimit,
                labelExportLimit: labelExportLimit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlansTable,
      PlanRecord,
      $$PlansTableFilterComposer,
      $$PlansTableOrderingComposer,
      $$PlansTableAnnotationComposer,
      $$PlansTableCreateCompanionBuilder,
      $$PlansTableUpdateCompanionBuilder,
      (PlanRecord, BaseReferences<_$AppDatabase, $PlansTable, PlanRecord>),
      PlanRecord,
      PrefetchHooks Function()
    >;
typedef $$CompanyUsagesTableCreateCompanionBuilder =
    CompanyUsagesCompanion Function({
      required String id,
      required int activeItemCount,
      required int userCount,
      required int locationCount,
      required int photoCount,
      required int labelExportCount,
      Value<int> rowid,
    });
typedef $$CompanyUsagesTableUpdateCompanionBuilder =
    CompanyUsagesCompanion Function({
      Value<String> id,
      Value<int> activeItemCount,
      Value<int> userCount,
      Value<int> locationCount,
      Value<int> photoCount,
      Value<int> labelExportCount,
      Value<int> rowid,
    });

class $$CompanyUsagesTableFilterComposer
    extends Composer<_$AppDatabase, $CompanyUsagesTable> {
  $$CompanyUsagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeItemCount => $composableBuilder(
    column: $table.activeItemCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userCount => $composableBuilder(
    column: $table.userCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get locationCount => $composableBuilder(
    column: $table.locationCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get photoCount => $composableBuilder(
    column: $table.photoCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get labelExportCount => $composableBuilder(
    column: $table.labelExportCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompanyUsagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompanyUsagesTable> {
  $$CompanyUsagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeItemCount => $composableBuilder(
    column: $table.activeItemCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userCount => $composableBuilder(
    column: $table.userCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get locationCount => $composableBuilder(
    column: $table.locationCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get photoCount => $composableBuilder(
    column: $table.photoCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get labelExportCount => $composableBuilder(
    column: $table.labelExportCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompanyUsagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompanyUsagesTable> {
  $$CompanyUsagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get activeItemCount => $composableBuilder(
    column: $table.activeItemCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userCount =>
      $composableBuilder(column: $table.userCount, builder: (column) => column);

  GeneratedColumn<int> get locationCount => $composableBuilder(
    column: $table.locationCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get photoCount => $composableBuilder(
    column: $table.photoCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get labelExportCount => $composableBuilder(
    column: $table.labelExportCount,
    builder: (column) => column,
  );
}

class $$CompanyUsagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompanyUsagesTable,
          CompanyUsageRecord,
          $$CompanyUsagesTableFilterComposer,
          $$CompanyUsagesTableOrderingComposer,
          $$CompanyUsagesTableAnnotationComposer,
          $$CompanyUsagesTableCreateCompanionBuilder,
          $$CompanyUsagesTableUpdateCompanionBuilder,
          (
            CompanyUsageRecord,
            BaseReferences<
              _$AppDatabase,
              $CompanyUsagesTable,
              CompanyUsageRecord
            >,
          ),
          CompanyUsageRecord,
          PrefetchHooks Function()
        > {
  $$CompanyUsagesTableTableManager(_$AppDatabase db, $CompanyUsagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompanyUsagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompanyUsagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompanyUsagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> activeItemCount = const Value.absent(),
                Value<int> userCount = const Value.absent(),
                Value<int> locationCount = const Value.absent(),
                Value<int> photoCount = const Value.absent(),
                Value<int> labelExportCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanyUsagesCompanion(
                id: id,
                activeItemCount: activeItemCount,
                userCount: userCount,
                locationCount: locationCount,
                photoCount: photoCount,
                labelExportCount: labelExportCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int activeItemCount,
                required int userCount,
                required int locationCount,
                required int photoCount,
                required int labelExportCount,
                Value<int> rowid = const Value.absent(),
              }) => CompanyUsagesCompanion.insert(
                id: id,
                activeItemCount: activeItemCount,
                userCount: userCount,
                locationCount: locationCount,
                photoCount: photoCount,
                labelExportCount: labelExportCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompanyUsagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompanyUsagesTable,
      CompanyUsageRecord,
      $$CompanyUsagesTableFilterComposer,
      $$CompanyUsagesTableOrderingComposer,
      $$CompanyUsagesTableAnnotationComposer,
      $$CompanyUsagesTableCreateCompanionBuilder,
      $$CompanyUsagesTableUpdateCompanionBuilder,
      (
        CompanyUsageRecord,
        BaseReferences<_$AppDatabase, $CompanyUsagesTable, CompanyUsageRecord>,
      ),
      CompanyUsageRecord,
      PrefetchHooks Function()
    >;
typedef $$CompaniesTableCreateCompanionBuilder =
    CompaniesCompanion Function({
      required String id,
      required String name,
      Value<String?> industry,
      required DateTime createdAt,
      required DateTime updatedAt,
      required bool setupCompleted,
      Value<int> rowid,
    });
typedef $$CompaniesTableUpdateCompanionBuilder =
    CompaniesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> industry,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> setupCompleted,
      Value<int> rowid,
    });

class $$CompaniesTableFilterComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get industry => $composableBuilder(
    column: $table.industry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get setupCompleted => $composableBuilder(
    column: $table.setupCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompaniesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get industry => $composableBuilder(
    column: $table.industry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get setupCompleted => $composableBuilder(
    column: $table.setupCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompaniesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get industry =>
      $composableBuilder(column: $table.industry, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get setupCompleted => $composableBuilder(
    column: $table.setupCompleted,
    builder: (column) => column,
  );
}

class $$CompaniesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompaniesTable,
          CompanyRecord,
          $$CompaniesTableFilterComposer,
          $$CompaniesTableOrderingComposer,
          $$CompaniesTableAnnotationComposer,
          $$CompaniesTableCreateCompanionBuilder,
          $$CompaniesTableUpdateCompanionBuilder,
          (
            CompanyRecord,
            BaseReferences<_$AppDatabase, $CompaniesTable, CompanyRecord>,
          ),
          CompanyRecord,
          PrefetchHooks Function()
        > {
  $$CompaniesTableTableManager(_$AppDatabase db, $CompaniesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompaniesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompaniesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> industry = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> setupCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCompanion(
                id: id,
                name: name,
                industry: industry,
                createdAt: createdAt,
                updatedAt: updatedAt,
                setupCompleted: setupCompleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> industry = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required bool setupCompleted,
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCompanion.insert(
                id: id,
                name: name,
                industry: industry,
                createdAt: createdAt,
                updatedAt: updatedAt,
                setupCompleted: setupCompleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompaniesTable,
      CompanyRecord,
      $$CompaniesTableFilterComposer,
      $$CompaniesTableOrderingComposer,
      $$CompaniesTableAnnotationComposer,
      $$CompaniesTableCreateCompanionBuilder,
      $$CompaniesTableUpdateCompanionBuilder,
      (
        CompanyRecord,
        BaseReferences<_$AppDatabase, $CompaniesTable, CompanyRecord>,
      ),
      CompanyRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$UnitsOfMeasureTableTableManager get unitsOfMeasure =>
      $$UnitsOfMeasureTableTableManager(_db, _db.unitsOfMeasure);
  $$LocationsTableTableManager get locations =>
      $$LocationsTableTableManager(_db, _db.locations);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db, _db.appUsers);
  $$InventoryTransactionsTableTableManager get inventoryTransactions =>
      $$InventoryTransactionsTableTableManager(_db, _db.inventoryTransactions);
  $$ItemLocationBalancesTableTableManager get itemLocationBalances =>
      $$ItemLocationBalancesTableTableManager(_db, _db.itemLocationBalances);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$ReorderRequestsTableTableManager get reorderRequests =>
      $$ReorderRequestsTableTableManager(_db, _db.reorderRequests);
  $$CheckoutRecordsTableTableManager get checkoutRecords =>
      $$CheckoutRecordsTableTableManager(_db, _db.checkoutRecords);
  $$AssignmentTargetsTableTableManager get assignmentTargets =>
      $$AssignmentTargetsTableTableManager(_db, _db.assignmentTargets);
  $$CycleCountSessionsTableTableManager get cycleCountSessions =>
      $$CycleCountSessionsTableTableManager(_db, _db.cycleCountSessions);
  $$CycleCountLinesTableTableManager get cycleCountLines =>
      $$CycleCountLinesTableTableManager(_db, _db.cycleCountLines);
  $$CustomFieldDefinitionsTableTableManager get customFieldDefinitions =>
      $$CustomFieldDefinitionsTableTableManager(
        _db,
        _db.customFieldDefinitions,
      );
  $$CustomFieldValuesTableTableManager get customFieldValues =>
      $$CustomFieldValuesTableTableManager(_db, _db.customFieldValues);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$CompanyUsagesTableTableManager get companyUsages =>
      $$CompanyUsagesTableTableManager(_db, _db.companyUsages);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db, _db.companies);
}
