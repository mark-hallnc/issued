import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';

class EditItemScreen extends StatefulWidget {
  const EditItemScreen({super.key, required this.item});

  final Item item;

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _minimumQuantityController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _supplierController;
  late final TextEditingController _unitCostController;
  late final TextEditingController _purchaseConversionController;

  final Map<String, TextEditingController> _customTextControllers = {};
  final Map<String, bool> _customBoolValues = {};
  final Map<String, DateTime?> _customDateValues = {};
  final Map<String, String?> _customSelectValues = {};

  late ItemType _itemType;
  late UnitOfMeasure _stockUom;
  UnitOfMeasure? _purchaseUom;
  late Location _location;
  late bool _allowFractionalQuantity;
  bool _dirty = false;
  bool _customInitialized = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item.name);
    _descriptionController = TextEditingController(text: item.description);
    _categoryController = TextEditingController(text: item.category);
    _minimumQuantityController = TextEditingController(
      text: _formatQuantity(item.minimumQuantity),
    );
    _skuController = TextEditingController(text: item.sku ?? '');
    _barcodeController = TextEditingController(text: item.barcode ?? '');
    _supplierController = TextEditingController(text: item.supplier ?? '');
    _unitCostController = TextEditingController(
      text: item.unitCost == null ? '' : item.unitCost.toString(),
    );
    _purchaseConversionController = TextEditingController(
      text: item.purchaseToStockConversionFactor == null
          ? ''
          : _formatQuantity(item.purchaseToStockConversionFactor!),
    );
    _itemType = item.itemType;
    _allowFractionalQuantity = item.allowFractionalQuantity;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = AppStoreScope.of(context);
    _stockUom = _unitById(store, widget.item.unitOfMeasureId) ??
        store.unitsOfMeasure.first;
    _purchaseUom = widget.item.purchaseUnitOfMeasureId == null
        ? null
        : _unitById(store, widget.item.purchaseUnitOfMeasureId!);
    _location =
        _locationById(store, widget.item.locationId) ?? store.locations.first;
    if (!_customInitialized) {
      _initializeCustomFields(store);
      _customInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _minimumQuantityController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _supplierController.dispose();
    _unitCostController.dispose();
    _purchaseConversionController.dispose();
    for (final controller in _customTextControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageItems) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Item')),
        body: const Center(
          child: Text('Your current role does not allow this action.'),
        ),
      );
    }

    final customFields = store.activeCustomFieldsForItem(_draftItem(store));

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !_dirty) {
          return;
        }
        final discard = await _confirmDiscard();
        if (discard && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Item')),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionCard(title: 'Basics', children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Item name'),
                  validator: _required,
                  onChanged: (_) => _markDirty(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  onChanged: (_) => _markDirty(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ItemType>(
                  initialValue: _itemType,
                  decoration: const InputDecoration(labelText: 'Item type'),
                  items: ItemType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_itemTypeLabel(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _itemType = value;
                      _dirty = true;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  onChanged: (_) => setState(() => _dirty = true),
                ),
              ]),
              _SectionCard(title: 'Stocking', children: [
                TextFormField(
                  controller: _minimumQuantityController,
                  decoration: const InputDecoration(labelText: 'Minimum quantity'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _requiredNumber,
                  onChanged: (_) => _markDirty(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UnitOfMeasure>(
                  initialValue: _stockUom,
                  decoration: const InputDecoration(labelText: 'Stocking UOM'),
                  items: store.unitsOfMeasure
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text('${unit.name} (${unit.abbreviation})'),
                        ),
                      )
                      .toList(),
                  onChanged: (unit) {
                    if (unit == null) {
                      return;
                    }
                    setState(() {
                      _stockUom = unit;
                      _dirty = true;
                    });
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Allow fractional quantity'),
                  value: _allowFractionalQuantity,
                  onChanged: (value) {
                    setState(() {
                      _allowFractionalQuantity = value ?? false;
                      _dirty = true;
                    });
                  },
                ),
                DropdownButtonFormField<Location>(
                  initialValue: _location,
                  decoration: const InputDecoration(labelText: 'Default location'),
                  items: store.locations
                      .map(
                        (location) => DropdownMenuItem(
                          value: location,
                          child: Text(location.name),
                        ),
                      )
                      .toList(),
                  onChanged: (location) {
                    if (location == null) {
                      return;
                    }
                    setState(() {
                      _location = location;
                      _dirty = true;
                    });
                  },
                ),
              ]),
              _QuantitySummaryCard(item: widget.item, store: store),
              _SectionCard(title: 'Purchasing / Receiving', children: [
                DropdownButtonFormField<UnitOfMeasure?>(
                  initialValue: _purchaseUom,
                  decoration: const InputDecoration(labelText: 'Purchase UOM'),
                  items: [
                    const DropdownMenuItem<UnitOfMeasure?>(
                      value: null,
                      child: Text('No purchase UOM'),
                    ),
                    for (final unit in store.unitsOfMeasure)
                      DropdownMenuItem<UnitOfMeasure?>(
                        value: unit,
                        child: Text('${unit.name} (${unit.abbreviation})'),
                      ),
                  ],
                  onChanged: (unit) {
                    setState(() {
                      _purchaseUom = unit;
                      _dirty = true;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _purchaseConversionController,
                  decoration: InputDecoration(
                    labelText: 'Stocking units per purchase unit',
                    helperText: _purchasePreview().isEmpty
                        ? 'Example: 1 case = 12 each, enter 12.'
                        : _purchasePreview(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _purchaseConversionValidator,
                  onChanged: (_) => setState(() => _dirty = true),
                ),
              ]),
              _SectionCard(title: 'Identification', children: [
                TextFormField(
                  controller: _skuController,
                  decoration: const InputDecoration(labelText: 'SKU/part number'),
                  onChanged: (_) => _markDirty(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(labelText: 'Barcode'),
                  onChanged: (_) => _markDirty(),
                ),
              ]),
              _SectionCard(title: 'Supplier & Cost', children: [
                TextFormField(
                  controller: _supplierController,
                  decoration: const InputDecoration(labelText: 'Supplier'),
                  onChanged: (_) => _markDirty(),
                ),
                if (store.permissions.canViewCosts) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _unitCostController,
                    decoration: const InputDecoration(labelText: 'Unit cost'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _optionalNumber,
                    onChanged: (_) => _markDirty(),
                  ),
                ],
              ]),
              _CustomFieldsEditor(
                fields: customFields,
                textControllers: _customTextControllers,
                boolValues: _customBoolValues,
                dateValues: _customDateValues,
                selectValues: _customSelectValues,
                onChanged: () => setState(() => _dirty = true),
              ),
              _SectionCard(title: 'Photo', children: const [
                Text('Manage photo on Item Detail.'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _initializeCustomFields(AppStore store) {
    for (final field in store.customFieldDefinitions) {
      final value = store.getCustomFieldValue(field.id, widget.item.id);
      switch (field.fieldType) {
        case CustomFieldType.text:
          _customTextControllers[field.id] = TextEditingController(
            text: value?.textValue ?? '',
          );
        case CustomFieldType.number:
          _customTextControllers[field.id] = TextEditingController(
            text: value?.numberValue?.toString() ?? '',
          );
        case CustomFieldType.date:
          _customDateValues[field.id] = value?.dateValue;
        case CustomFieldType.boolean:
          _customBoolValues[field.id] = value?.booleanValue ?? false;
        case CustomFieldType.select:
          _customSelectValues[field.id] = value?.selectedOption;
      }
    }
  }

  Future<void> _save() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageItems) {
      _showMessage('Your current role does not allow this action.');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final barcode = _emptyToNull(_barcodeController.text);
    if (barcode != null &&
        store.isBarcodeInUse(barcode, excludingItemId: widget.item.id)) {
      _showMessage('Another item already uses this barcode.');
      return;
    }
    final sku = _emptyToNull(_skuController.text);
    if (sku != null && store.isSkuInUse(sku, excludingItemId: widget.item.id)) {
      _showMessage('Another item already uses this SKU.');
      return;
    }

    if (_itemType != widget.item.itemType) {
      if (_itemType == ItemType.consumable &&
          store.hasOpenCheckoutsForItem(widget.item.id)) {
        _showMessage(
          'This item has open checkouts. Return or close them before changing to Consumable.',
        );
        return;
      }
      final confirmed = await _confirm(
        'Changing item type can affect checkout, issue, and reporting behavior.',
      );
      if (!confirmed) {
        return;
      }
    }

    var activityNote = '';
    if (_stockUom.id != widget.item.unitOfMeasureId) {
      if (widget.item.quantityOnHand != 0 ||
          store.hasTransactionsForItem(widget.item.id)) {
        final confirmed = await _confirm(
          'Changing the stocking UOM does not convert existing quantities. Continue only if this item was set up with the wrong unit.',
        );
        if (!confirmed) {
          return;
        }
      }
      final oldUom =
          store.getStockUom(widget.item)?.abbreviation ?? widget.item.unitOfMeasureId;
      activityNote =
          'Item stocking UOM changed from $oldUom to ${_stockUom.abbreviation}.';
    }

    final updatedItem = Item(
      id: widget.item.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      itemType: _itemType,
      category: _categoryController.text.trim(),
      locationId: _location.id,
      quantityOnHand: widget.item.quantityOnHand,
      minimumQuantity: double.parse(_minimumQuantityController.text.trim()),
      unitOfMeasureId: _stockUom.id,
      purchaseUnitOfMeasureId: _normalizedPurchaseUnitId(),
      purchaseToStockConversionFactor: _normalizedPurchaseFactor(),
      purchaseUnitLabel: null,
      barcode: barcode,
      sku: sku,
      supplier: _emptyToNull(_supplierController.text),
      unitCost: store.permissions.canViewCosts
          ? _optionalDouble(_unitCostController.text)
          : widget.item.unitCost,
      photoPath: widget.item.photoPath,
      isActive: widget.item.isActive,
      allowFractionalQuantity: _allowFractionalQuantity,
      createdAt: widget.item.createdAt,
      updatedAt: DateTime.now(),
    );

    final customValues = _customValuesForFields(
      store.activeCustomFieldsForItem(updatedItem),
      widget.item.id,
    );
    final saved = store.updateItemDetails(
      updatedItem,
      customFieldValues: customValues,
      activityNote: activityNote,
    );
    if (!saved) {
      _showMessage('Could not update item.');
      return;
    }

    _dirty = false;
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item updated.')),
    );
    Navigator.of(context).pop(true);
  }

  List<CustomFieldValue> _customValuesForFields(
    List<CustomFieldDefinition> fields,
    String itemId,
  ) {
    return fields.map((field) {
      final id = 'cfv-${field.id}-$itemId';
      return switch (field.fieldType) {
        CustomFieldType.text => CustomFieldValue(
          id: id,
          definitionId: field.id,
          entityId: itemId,
          textValue: _emptyToNull(_customTextControllers[field.id]?.text ?? ''),
          numberValue: null,
          dateValue: null,
          booleanValue: null,
          selectedOption: null,
        ),
        CustomFieldType.number => CustomFieldValue(
          id: id,
          definitionId: field.id,
          entityId: itemId,
          textValue: null,
          numberValue: _optionalDouble(_customTextControllers[field.id]?.text ?? ''),
          dateValue: null,
          booleanValue: null,
          selectedOption: null,
        ),
        CustomFieldType.date => CustomFieldValue(
          id: id,
          definitionId: field.id,
          entityId: itemId,
          textValue: null,
          numberValue: null,
          dateValue: _customDateValues[field.id],
          booleanValue: null,
          selectedOption: null,
        ),
        CustomFieldType.boolean => CustomFieldValue(
          id: id,
          definitionId: field.id,
          entityId: itemId,
          textValue: null,
          numberValue: null,
          dateValue: null,
          booleanValue: _customBoolValues[field.id] ?? false,
          selectedOption: null,
        ),
        CustomFieldType.select => CustomFieldValue(
          id: id,
          definitionId: field.id,
          entityId: itemId,
          textValue: null,
          numberValue: null,
          dateValue: null,
          booleanValue: null,
          selectedOption: _customSelectValues[field.id],
        ),
      };
    }).toList();
  }

  Item _draftItem(AppStore store) {
    return Item(
      id: widget.item.id,
      name: _nameController.text,
      description: _descriptionController.text,
      itemType: _itemType,
      category: _categoryController.text.trim(),
      locationId: _location.id,
      quantityOnHand: widget.item.quantityOnHand,
      minimumQuantity:
          double.tryParse(_minimumQuantityController.text.trim()) ??
          widget.item.minimumQuantity,
      unitOfMeasureId: _stockUom.id,
      purchaseUnitOfMeasureId: _normalizedPurchaseUnitId(),
      purchaseToStockConversionFactor: _normalizedPurchaseFactor(),
      purchaseUnitLabel: null,
      barcode: _emptyToNull(_barcodeController.text),
      sku: _emptyToNull(_skuController.text),
      supplier: _emptyToNull(_supplierController.text),
      unitCost: widget.item.unitCost,
      photoPath: widget.item.photoPath,
      isActive: widget.item.isActive,
      allowFractionalQuantity: _allowFractionalQuantity,
      createdAt: widget.item.createdAt,
      updatedAt: widget.item.updatedAt,
    );
  }

  String? _normalizedPurchaseUnitId() {
    if (_purchaseUom == null || _purchaseUom!.id == _stockUom.id) {
      return null;
    }
    return _purchaseUom!.id;
  }

  double? _normalizedPurchaseFactor() {
    if (_normalizedPurchaseUnitId() == null) {
      return null;
    }
    return double.tryParse(_purchaseConversionController.text.trim());
  }

  String _purchasePreview() {
    final factor = double.tryParse(_purchaseConversionController.text.trim());
    if (_purchaseUom == null ||
        _purchaseUom!.id == _stockUom.id ||
        factor == null ||
        factor <= 0) {
      return '';
    }
    return '1 ${_purchaseUom!.abbreviation} = ${_formatQuantity(factor)} ${_stockUom.abbreviation}';
  }

  String? _purchaseConversionValidator(String? value) {
    if (_purchaseUom == null || _purchaseUom!.id == _stockUom.id) {
      if (value == null || value.trim().isEmpty) {
        return null;
      }
    }
    if (_purchaseUom != null && _purchaseUom!.id != _stockUom.id) {
      if (value == null || value.trim().isEmpty) {
        return 'Enter a conversion factor.';
      }
    }
    final factor = double.tryParse(value?.trim() ?? '');
    if (factor == null) {
      return 'Enter a valid number.';
    }
    if (factor <= 0) {
      return 'Enter a number greater than 0.';
    }
    return null;
  }

  Future<bool> _confirm(String message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Change'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Unsaved item changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() {
        _dirty = true;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _requiredNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }
    return null;
  }

  String? _optionalNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }
    return null;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _QuantitySummaryCard extends StatelessWidget {
  const _QuantitySummaryCard({required this.item, required this.store});

  final Item item;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final balances = store.itemBalancesForItem(item.id);
    return _SectionCard(
      title: 'Read-only Quantity Summary',
      children: [
        Text('Current total: ${store.formatStockQuantity(item, item.quantityOnHand)}'),
        const SizedBox(height: 8),
        for (final balance in balances)
          Text(
            '${store.resolveLocationName(balance.locationId) ?? 'Unknown'}: ${store.formatStockQuantity(item, balance.quantityOnHand)}',
          ),
        const SizedBox(height: 8),
        const Text(
          'Use Receive, Issue, Transfer, Adjust, or Cycle Count to change quantity.',
        ),
      ],
    );
  }
}

class _CustomFieldsEditor extends StatelessWidget {
  const _CustomFieldsEditor({
    required this.fields,
    required this.textControllers,
    required this.boolValues,
    required this.dateValues,
    required this.selectValues,
    required this.onChanged,
  });

  final List<CustomFieldDefinition> fields;
  final Map<String, TextEditingController> textControllers;
  final Map<String, bool> boolValues;
  final Map<String, DateTime?> dateValues;
  final Map<String, String?> selectValues;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) {
      return const SizedBox.shrink();
    }
    return _SectionCard(
      title: 'Custom Fields',
      children: [
        for (final field in fields) ...[
          _field(context, field),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _field(BuildContext context, CustomFieldDefinition field) {
    final label = field.isRequired ? '${field.name} *' : field.name;
    return switch (field.fieldType) {
      CustomFieldType.text => TextFormField(
        controller: _controllerFor(field),
        decoration: InputDecoration(labelText: label),
        validator: (value) => _requiredText(field, value),
        onChanged: (_) => onChanged(),
      ),
      CustomFieldType.number => TextFormField(
        controller: _controllerFor(field),
        decoration: InputDecoration(labelText: label),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          final requiredError = _requiredText(field, value);
          if (requiredError != null) {
            return requiredError;
          }
          if ((value ?? '').trim().isNotEmpty &&
              double.tryParse(value!.trim()) == null) {
            return 'Enter a valid number';
          }
          return null;
        },
        onChanged: (_) => onChanged(),
      ),
      CustomFieldType.date => OutlinedButton.icon(
        onPressed: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: dateValues[field.id] ?? now,
            firstDate: DateTime(now.year - 20),
            lastDate: DateTime(now.year + 20),
          );
          if (picked != null) {
            dateValues[field.id] = picked;
            onChanged();
          }
        },
        icon: const Icon(Icons.event),
        label: Text(
          dateValues[field.id] == null
              ? label
              : '$label: ${_formatDate(dateValues[field.id]!)}',
        ),
      ),
      CustomFieldType.boolean => CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        value: boolValues[field.id] ?? false,
        onChanged: (value) {
          boolValues[field.id] = value ?? false;
          onChanged();
        },
      ),
      CustomFieldType.select => DropdownButtonFormField<String>(
        initialValue: selectValues[field.id],
        decoration: InputDecoration(labelText: label),
        items: field.options
            .map(
              (option) => DropdownMenuItem(value: option, child: Text(option)),
            )
            .toList(),
        validator: (value) {
          if (field.isRequired && (value == null || value.isEmpty)) {
            return 'Required';
          }
          return null;
        },
        onChanged: (value) {
          selectValues[field.id] = value;
          onChanged();
        },
      ),
    };
  }

  TextEditingController _controllerFor(CustomFieldDefinition field) {
    return textControllers.putIfAbsent(field.id, () => TextEditingController());
  }

  String? _requiredText(CustomFieldDefinition field, String? value) {
    if (field.isRequired && (value == null || value.trim().isEmpty)) {
      return 'Required';
    }
    return null;
  }
}

String _itemTypeLabel(ItemType type) {
  return switch (type) {
    ItemType.consumable => 'Consumable',
    ItemType.returnable => 'Returnable',
    ItemType.asset => 'Asset',
  };
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

double? _optionalDouble(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : double.tryParse(trimmed);
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }
  return quantity.toStringAsFixed(2);
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

UnitOfMeasure? _unitById(AppStore store, String unitId) {
  for (final unit in store.unitsOfMeasure) {
    if (unit.id == unitId) {
      return unit;
    }
  }
  return null;
}

Location? _locationById(AppStore store, String locationId) {
  for (final location in store.locations) {
    if (location.id == locationId) {
      return location;
    }
  }
  return null;
}
