import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import 'plan_screens.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key, this.initialBarcode});

  final String? initialBarcode;

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController(text: '0');
  final _minimumQuantityController = TextEditingController(text: '0');
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _supplierController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _purchaseConversionController = TextEditingController();
  final _notesController = TextEditingController();
  final Map<String, TextEditingController> _customTextControllers = {};
  final Map<String, bool> _customBoolValues = {};
  final Map<String, DateTime?> _customDateValues = {};
  final Map<String, String?> _customSelectValues = {};

  ItemType _itemType = ItemType.consumable;
  UnitOfMeasure? _selectedUnit;
  UnitOfMeasure? _selectedPurchaseUnit;
  Location? _selectedLocation;
  bool _allowFractionalQuantity = false;

  @override
  void initState() {
    super.initState();
    _barcodeController.text = widget.initialBarcode ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _minimumQuantityController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _supplierController.dispose();
    _unitCostController.dispose();
    _purchaseConversionController.dispose();
    _notesController.dispose();
    for (final controller in _customTextControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    _selectedUnit ??= store.unitsOfMeasure.first;
    _selectedLocation ??= store.locations.first;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Add Item')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _saveItem,
            icon: const Icon(Icons.save),
            label: const Text('Save Item'),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ItemType>(
              initialValue: _itemType,
              decoration: const InputDecoration(
                labelText: 'Item type',
                border: OutlineInputBorder(),
              ),
              items: ItemType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(_itemTypeLabel(type)),
                    ),
                  )
                  .toList(),
              onChanged: (type) {
                if (type == null) {
                  return;
                }

                setState(() {
                  _itemType = type;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity on hand',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              validator: _numberValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _minimumQuantityController,
              decoration: const InputDecoration(
                labelText: 'Minimum quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              validator: _numberValidator,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<UnitOfMeasure>(
              initialValue: _selectedUnit,
              decoration: const InputDecoration(
                labelText: 'Unit of measure',
                border: OutlineInputBorder(),
              ),
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
                  _selectedUnit = unit;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Location>(
              initialValue: _selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
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
                  _selectedLocation = location;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU/part number',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Barcode',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _supplierController,
              decoration: const InputDecoration(
                labelText: 'Supplier',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _unitCostController,
              decoration: const InputDecoration(
                labelText: 'Unit cost',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              validator: _optionalNumberValidator,
            ),
            const SizedBox(height: 4),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Allow fractional quantity'),
              value: _allowFractionalQuantity,
              onChanged: (value) {
                setState(() {
                  _allowFractionalQuantity = value ?? false;
                });
              },
            ),
            const SizedBox(height: 8),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text(
                  'Purchasing / Receiving',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                children: [
                  DropdownButtonFormField<UnitOfMeasure?>(
                    initialValue: _selectedPurchaseUnit,
                    decoration: const InputDecoration(
                      labelText: 'Purchase UOM',
                      border: OutlineInputBorder(),
                    ),
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
                        _selectedPurchaseUnit = unit;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _purchaseConversionController,
                    decoration: const InputDecoration(
                      labelText: 'Stocking units per purchase unit',
                      helperText: 'Example: 1 case = 12 each, enter 12.',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _purchaseConversionValidator,
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_purchasePreview().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_purchasePreview()),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _CustomFieldsSection(
              fields: store.activeCustomFieldsForItem(_draftItem(store)),
              textControllers: _customTextControllers,
              boolValues: _customBoolValues,
              dateValues: _customDateValues,
              selectValues: _customSelectValues,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }

    return null;
  }

  String? _optionalNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }

    return null;
  }

  String? _purchaseConversionValidator(String? value) {
    final purchaseUnit = _selectedPurchaseUnit;
    if (purchaseUnit == null || purchaseUnit.id == _selectedUnit?.id) {
      if (value == null || value.trim().isEmpty) {
        return null;
      }
    }

    if (purchaseUnit != null && purchaseUnit.id != _selectedUnit?.id) {
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

  String? _normalizedPurchaseUnitId() {
    if (_selectedPurchaseUnit == null ||
        _selectedPurchaseUnit!.id == _selectedUnit?.id) {
      return null;
    }
    return _selectedPurchaseUnit!.id;
  }

  double? _normalizedPurchaseFactor() {
    if (_normalizedPurchaseUnitId() == null) {
      return null;
    }
    return double.tryParse(_purchaseConversionController.text.trim());
  }

  String _purchasePreview() {
    final purchaseUnit = _selectedPurchaseUnit;
    final stockUnit = _selectedUnit;
    final factor = double.tryParse(_purchaseConversionController.text.trim());
    if (purchaseUnit == null ||
        stockUnit == null ||
        purchaseUnit.id == stockUnit.id ||
        factor == null ||
        factor <= 0) {
      return '';
    }
    return '1 ${purchaseUnit.abbreviation} = ${_formatQuantity(factor)} ${stockUnit.abbreviation}';
  }

  void _saveItem() {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageItems) {
      _showPermissionDenied();
      return;
    }

    if (!store.canAddItem) {
      _showItemLimitReached(store);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final item = Item(
      id: 'item-${now.microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _notesController.text.trim(),
      itemType: _itemType,
      category: _categoryController.text.trim(),
      locationId: _selectedLocation!.id,
      quantityOnHand: double.parse(_quantityController.text.trim()),
      minimumQuantity: double.parse(_minimumQuantityController.text.trim()),
      unitOfMeasureId: _selectedUnit!.id,
      purchaseUnitOfMeasureId: _normalizedPurchaseUnitId(),
      purchaseToStockConversionFactor: _normalizedPurchaseFactor(),
      purchaseUnitLabel: null,
      barcode: _emptyToNull(_barcodeController.text),
      sku: _emptyToNull(_skuController.text),
      supplierId: null,
      supplier: _emptyToNull(_supplierController.text),
      unitCost: _emptyToNull(_unitCostController.text) == null
          ? null
          : double.parse(_unitCostController.text.trim()),
      photoPath: null,
      isActive: true,
      allowFractionalQuantity: _allowFractionalQuantity,
      createdAt: now,
      updatedAt: now,
    );

    final result = store.addItemWithInitialBalance(item, _selectedLocation!.id);
    if (!result.success) {
      _showMessage(result.message ?? 'Could not add item.');
      return;
    }
    for (final field in store.activeCustomFieldsForItem(item)) {
      final value = _customValueForField(field, item.id, now);
      if (value != null) {
        store.setCustomFieldValue(value);
      }
    }
    Navigator.of(context).pop(true);
  }

  Item _draftItem(AppStore store) {
    final now = DateTime.now();
    return Item(
      id: 'draft',
      name: _nameController.text,
      description: _notesController.text,
      itemType: _itemType,
      category: _categoryController.text.trim(),
      locationId: _selectedLocation?.id ?? store.locations.first.id,
      quantityOnHand: 0,
      minimumQuantity: 0,
      unitOfMeasureId: _selectedUnit?.id ?? store.unitsOfMeasure.first.id,
      purchaseUnitOfMeasureId: _normalizedPurchaseUnitId(),
      purchaseToStockConversionFactor: _normalizedPurchaseFactor(),
      purchaseUnitLabel: null,
      barcode: null,
      sku: null,
      supplierId: null,
      supplier: null,
      unitCost: null,
      photoPath: null,
      isActive: true,
      allowFractionalQuantity: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  CustomFieldValue? _customValueForField(
    CustomFieldDefinition field,
    String itemId,
    DateTime now,
  ) {
    final id = 'cfv-${field.id}-$itemId';
    return switch (field.fieldType) {
      CustomFieldType.text =>
        _emptyToNull(_customTextControllers[field.id]?.text ?? '') == null
            ? null
            : CustomFieldValue(
                id: id,
                definitionId: field.id,
                entityId: itemId,
                textValue: _customTextControllers[field.id]!.text.trim(),
                numberValue: null,
                dateValue: null,
                booleanValue: null,
                selectedOption: null,
              ),
      CustomFieldType.number =>
        _emptyToNull(_customTextControllers[field.id]?.text ?? '') == null
            ? null
            : CustomFieldValue(
                id: id,
                definitionId: field.id,
                entityId: itemId,
                textValue: null,
                numberValue: double.parse(
                  _customTextControllers[field.id]!.text.trim(),
                ),
                dateValue: null,
                booleanValue: null,
                selectedOption: null,
              ),
      CustomFieldType.date =>
        _customDateValues[field.id] == null
            ? null
            : CustomFieldValue(
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
      CustomFieldType.select =>
        _customSelectValues[field.id] == null
            ? null
            : CustomFieldValue(
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
  }

  void _showPermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your current role does not allow this action.'),
      ),
    );
  }

  Future<void> _showItemLimitReached(AppStore store) async {
    final action = await showPlanLimitDialog(
      context,
      title: 'Item limit reached',
      message:
          'Your ${store.currentPlan.name} plan includes up to ${store.currentPlan.itemLimit} active items.',
      recommendedPlanCode: store.getLimitWarningForItems()?.recommendedPlanCode,
      showArchiveItems: true,
    );

    if (!mounted) {
      return;
    }

    switch (action) {
      case PlanLimitDialogAction.archiveItems:
        Navigator.of(context).pop(false);
      case PlanLimitDialogAction.upgrade:
        await openComparePlans(
          context,
          recommendedPlanCode: store
              .getLimitWarningForItems()
              ?.recommendedPlanCode,
        );
      case PlanLimitDialogAction.cancel || null:
        return;
    }
  }

  String? _emptyToNull(String value) {
    final trimmedValue = value.trim();
    return trimmedValue.isEmpty ? null : trimmedValue;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _itemTypeLabel(ItemType type) {
    return switch (type) {
      ItemType.consumable => 'Consumable',
      ItemType.returnable => 'Returnable',
      ItemType.asset => 'Asset',
    };
  }
}

class _CustomFieldsSection extends StatelessWidget {
  const _CustomFieldsSection({
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        initiallyExpanded: fields.length <= 4,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: const Text(
          'Custom Fields',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          fields.any((field) => field.isRequired)
              ? 'Required fields are marked with *'
              : '${fields.length} fields available',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        children: [
          for (var index = 0; index < fields.length; index++) ...[
            _fieldControl(context, fields[index]),
            if (index < fields.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _fieldControl(BuildContext context, CustomFieldDefinition field) {
    return switch (field.fieldType) {
      CustomFieldType.text => TextFormField(
        controller: _controllerFor(field),
        decoration: InputDecoration(
          labelText: _label(field),
          border: const OutlineInputBorder(),
        ),
        validator: (value) => _requiredText(field, value),
      ),
      CustomFieldType.number => TextFormField(
        controller: _controllerFor(field),
        decoration: InputDecoration(
          labelText: _label(field),
          border: const OutlineInputBorder(),
        ),
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
      ),
      CustomFieldType.date => FormField<DateTime?>(
        initialValue: dateValues[field.id],
        validator: (_) {
          if (field.isRequired && dateValues[field.id] == null) {
            return 'Required';
          }
          return null;
        },
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputDecorator(
                decoration: InputDecoration(
                  labelText: _label(field),
                  border: const OutlineInputBorder(),
                  errorText: state.errorText,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      final now = DateTime.now();
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(now.year - 20),
                        lastDate: DateTime(now.year + 50),
                        initialDate: dateValues[field.id] ?? now,
                      );
                      if (date == null) {
                        return;
                      }
                      dateValues[field.id] = date;
                      state.didChange(date);
                      onChanged();
                    },
                    icon: const Icon(Icons.event),
                    label: Text(
                      dateValues[field.id] == null
                          ? 'Choose date'
                          : _formatDate(dateValues[field.id]!),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      CustomFieldType.boolean => InputDecorator(
        decoration: InputDecoration(
          labelText: _label(field),
          border: const OutlineInputBorder(),
        ),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enabled'),
          value: boolValues[field.id] ?? false,
          onChanged: (value) {
            boolValues[field.id] = value;
            onChanged();
          },
        ),
      ),
      CustomFieldType.select => DropdownButtonFormField<String>(
        initialValue: selectValues[field.id],
        decoration: InputDecoration(
          labelText: _label(field),
          border: const OutlineInputBorder(),
        ),
        items: field.options
            .map(
              (option) =>
                  DropdownMenuItem<String>(value: option, child: Text(option)),
            )
            .toList(),
        onChanged: (value) {
          selectValues[field.id] = value;
          onChanged();
        },
        validator: (value) {
          if (field.isRequired && (value == null || value.isEmpty)) {
            return 'Required';
          }
          if (value != null && !field.options.contains(value)) {
            return 'Choose a valid option';
          }
          return null;
        },
      ),
    };
  }

  TextEditingController _controllerFor(CustomFieldDefinition field) {
    return textControllers.putIfAbsent(field.id, () => TextEditingController());
  }

  String _label(CustomFieldDefinition field) {
    return field.isRequired ? '${field.name} *' : field.name;
  }

  String? _requiredText(CustomFieldDefinition field, String? value) {
    if (field.isRequired && (value == null || value.trim().isEmpty)) {
      return 'Required';
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }
  return quantity.toStringAsFixed(2);
}
