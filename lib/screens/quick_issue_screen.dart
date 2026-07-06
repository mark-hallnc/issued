import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import '../core/permissions/app_permissions.dart';
import '../core/scanner/scan_parser.dart';
import 'item_detail_screen.dart';

class QuickIssueScreen extends StatefulWidget {
  const QuickIssueScreen({
    super.key,
    this.initialItemId,
    this.initialSourceLocationId,
    this.initialAssignmentTargetId,
  });

  final String? initialItemId;
  final String? initialSourceLocationId;
  final String? initialAssignmentTargetId;

  @override
  State<QuickIssueScreen> createState() => _QuickIssueScreenState();
}

class _QuickIssueScreenState extends State<QuickIssueScreen> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _assignedTextController = TextEditingController();

  Item? _selectedItem;
  _QuickAction? _selectedAction;
  CheckoutRecord? _selectedCheckout;
  _ReturnCondition _returnCondition = _ReturnCondition.good;
  String? _selectedSourceLocationId;
  String? _selectedDestinationLocationId;
  String? _assignedPersonId;
  String? _assignedLocationId;
  String? _assignedTargetId;
  bool _receiveByPurchaseUnit = false;
  String? _message;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _selectedSourceLocationId = widget.initialSourceLocationId;
    _selectedDestinationLocationId = widget.initialSourceLocationId;
    _assignedTargetId = widget.initialAssignmentTargetId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedItem == null && widget.initialItemId != null) {
      final item = AppStoreScope.of(
        context,
      ).findItemById(widget.initialItemId!);
      if (item != null) {
        _selectedItem = item;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _assignedTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final selectedItem = _selectedItem == null
        ? null
        : store.itemById(_selectedItem!.id) ?? _selectedItem;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _UserStrip(store: store, onSwitchUser: () => store.lockSession()),
          const SizedBox(height: 16),
          if (_successMessage != null)
            _SuccessPanel(
              message: _successMessage!,
              item: selectedItem,
              store: store,
              onScanNext: _resetForNextScan,
            )
          else if (selectedItem == null) ...[
            _ReadyPanel(
              controller: _searchController,
              onScan: _scanItem,
              onSearchChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            if (_message != null) _MessagePanel(message: _message!),
            _SearchResults(
              query: _searchController.text,
              store: store,
              onSelected: _selectItem,
            ),
          ] else ...[
            _ItemActionPanel(
              item: selectedItem,
              store: store,
              selectedAction: _selectedAction,
              onActionSelected: _startAction,
              onViewDetail: () => _openItemDetail(selectedItem),
              onClear: _resetForNextScan,
            ),
            if (_selectedAction != null) ...[
              const SizedBox(height: 16),
              _buildActionForm(store, selectedItem),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _scanItem() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (context) => const _QuickScanRoute()),
    );
    if (!mounted || code == null || code.trim().isEmpty) {
      return;
    }

    await _handleScannedCode(code);
  }

  Future<void> _handleScannedCode(String code) async {
    final store = AppStoreScope.of(context);
    final resolved = const ScanResolver().resolveScan(code, store);
    switch (resolved.resolutionType) {
      case ScanResolutionType.item:
        final item = resolved.item;
        if (item != null) {
          _selectItem(item);
        }
      case ScanResolutionType.multipleItems:
        await _showDuplicateMatches(resolved.itemMatches);
      case ScanResolutionType.location:
        final location = resolved.location;
        setState(() {
          _selectedSourceLocationId = location?.id;
          _selectedDestinationLocationId = location?.id;
          _message = location == null
              ? 'Location label scanned.'
              : 'Using ${location.name} as the source location.';
        });
      case ScanResolutionType.assignmentTarget:
        final target = resolved.assignmentTarget;
        setState(() {
          _assignedPersonId = null;
          _assignedLocationId = null;
          _assignedTargetId = target?.id;
          _assignedTextController.clear();
          _message = target == null
              ? 'Assignment target label scanned.'
              : 'Assigning to ${target.name}.';
        });
      case ScanResolutionType.malformed:
        setState(() {
          _selectedItem = null;
          _selectedAction = null;
          _message = 'This Issued label could not be read.';
          _searchController.text = code.trim();
        });
      case ScanResolutionType.checkout:
      case ScanResolutionType.reorder:
      case ScanResolutionType.notFound:
        setState(() {
          _selectedItem = null;
          _selectedAction = null;
          _message = 'No item found for this code.';
          _searchController.text = code.trim();
        });
    }
  }

  Future<void> _showDuplicateMatches(List<Item> matches) async {
    final selected = await showModalBottomSheet<Item>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Choose matching item')),
            for (final item in matches)
              ListTile(
                title: Text(item.name),
                subtitle: Text(_itemSubtitle(item)),
                onTap: () => Navigator.of(context).pop(item),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      _selectItem(selected);
    }
  }

  void _selectItem(Item item) {
    setState(() {
      _selectedItem = item;
      _selectedAction = null;
      _selectedCheckout = null;
      _message = null;
      _successMessage = null;
      _searchController.clear();
      _resetFormFields(preserveScanContext: true);
    });
  }

  void _startAction(_QuickAction action) {
    final item = _selectedItem;
    if (item == null) {
      return;
    }
    final store = AppStoreScope.of(context);
    if (!_canStartAction(store, action)) {
      _showPermissionMessage();
      return;
    }
    if (store.isLocked) {
      _showMessage('Unlock Issued to continue.');
      return;
    }
    setState(() {
      _selectedAction = action;
      _message = null;
      _resetFormFields(preserveScanContext: true);
      _seedDefaults(store, item, action);
    });
  }

  bool _canStartAction(AppStore store, _QuickAction action) {
    return switch (action) {
      _QuickAction.issue ||
      _QuickAction.checkOut ||
      _QuickAction.returnItem => store.permissions.canIssueItems,
      _QuickAction.receive => store.permissions.canReceiveStock,
    };
  }

  void _seedDefaults(AppStore store, Item item, _QuickAction action) {
    final stockLocations = _stockLocations(store, item);
    final activeLocations = _activeLocations(store);
    switch (action) {
      case _QuickAction.issue:
        _quantityController.text = '1';
        _selectedSourceLocationId ??= stockLocations.isNotEmpty
            ? stockLocations.first.locationId
            : null;
      case _QuickAction.checkOut:
        _quantityController.text = '1';
        _selectedSourceLocationId ??= stockLocations.isNotEmpty
            ? stockLocations.first.locationId
            : null;
      case _QuickAction.returnItem:
        final open = store.openCheckoutRecordsForItem(item.id);
        _selectedCheckout = open.isNotEmpty ? open.first : null;
        _quantityController.text = _selectedCheckout == null
            ? ''
            : _formatQuantity(_selectedCheckout!.quantityOpen);
        _selectedDestinationLocationId ??= activeLocations.isNotEmpty
            ? activeLocations.first.id
            : null;
      case _QuickAction.receive:
        _quantityController.text = '1';
        _selectedDestinationLocationId ??= activeLocations.isNotEmpty
            ? activeLocations.first.id
            : null;
        _receiveByPurchaseUnit = store.hasPurchaseConversion(item);
    }
  }

  Widget _buildActionForm(AppStore store, Item item) {
    final action = _selectedAction;
    if (action == null) {
      return const SizedBox.shrink();
    }
    if (action == _QuickAction.returnItem &&
        store.openCheckoutRecordsForItem(item.id).isEmpty) {
      return _NoOpenCheckoutsPanel(onViewDetail: () => _openItemDetail(item));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _actionTitle(action),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (action == _QuickAction.issue ||
                  action == _QuickAction.checkOut)
                _sourceLocationField(store, item),
              if (action == _QuickAction.receive ||
                  action == _QuickAction.returnItem)
                _destinationLocationField(store),
              if (action == _QuickAction.returnItem) ...[
                _checkoutField(store, item),
                const SizedBox(height: 12),
                _returnConditionField(store),
              ],
              const SizedBox(height: 12),
              if (action == _QuickAction.receive &&
                  store.hasPurchaseConversion(item))
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Receive by ${store.getPurchaseUom(item)?.abbreviation ?? item.purchaseUnitLabel ?? 'purchase unit'}',
                  ),
                  value: _receiveByPurchaseUnit,
                  onChanged: (value) {
                    setState(() {
                      _receiveByPurchaseUnit = value;
                    });
                  },
                ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: _quantityLabel(store, item, action),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => _validateQuantity(store, item, action),
              ),
              if (action == _QuickAction.receive &&
                  _receiveByPurchaseUnit &&
                  store.purchaseConversionPreview(item) != null) ...[
                const SizedBox(height: 8),
                Text(store.purchaseConversionPreview(item)!),
              ],
              if (action == _QuickAction.issue ||
                  action == _QuickAction.checkOut) ...[
                const SizedBox(height: 12),
                _assignmentFields(store, action),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes optional',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                _MessagePanel(message: _message!),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _saveAction(store, item, action),
                child: Text(_saveLabel(action)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceLocationField(AppStore store, Item item) {
    final locations = _stockLocations(store, item);
    return DropdownButtonFormField<String>(
      initialValue: _selectedSourceLocationId,
      decoration: const InputDecoration(
        labelText: 'Source location',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final balance in locations)
          DropdownMenuItem(
            value: balance.locationId,
            child: Text(
              '${store.resolveLocationName(balance.locationId) ?? 'Unknown'} (${store.formatStockQuantity(item, balance.quantityOnHand)})',
            ),
          ),
      ],
      onChanged: (value) => setState(() => _selectedSourceLocationId = value),
      validator: (value) => value == null ? 'Choose a source location.' : null,
    );
  }

  Widget _destinationLocationField(AppStore store) {
    final locations = _activeLocations(store);
    return DropdownButtonFormField<String>(
      initialValue: _selectedDestinationLocationId,
      decoration: const InputDecoration(
        labelText: 'Destination location',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final location in locations)
          DropdownMenuItem(value: location.id, child: Text(location.name)),
      ],
      onChanged: (value) =>
          setState(() => _selectedDestinationLocationId = value),
      validator: (value) =>
          value == null ? 'Choose a destination location.' : null,
    );
  }

  Widget _checkoutField(AppStore store, Item item) {
    final records = store.openCheckoutRecordsForItem(item.id);
    return DropdownButtonFormField<String>(
      initialValue: _selectedCheckout?.id,
      decoration: const InputDecoration(
        labelText: 'Open checkout',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final record in records)
          DropdownMenuItem(
            value: record.id,
            child: Text(_checkoutLabel(store, record)),
          ),
      ],
      onChanged: (value) {
        final record = records
            .where((record) => record.id == value)
            .firstOrNull;
        setState(() {
          _selectedCheckout = record;
          if (record != null) {
            _quantityController.text = _formatQuantity(record.quantityOpen);
          }
        });
      },
      validator: (value) => value == null ? 'Choose an open checkout.' : null,
    );
  }

  Widget _returnConditionField(AppStore store) {
    return DropdownButtonFormField<_ReturnCondition>(
      initialValue: _returnCondition,
      decoration: const InputDecoration(
        labelText: 'Condition',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final condition in _ReturnCondition.values)
          DropdownMenuItem(value: condition, child: Text(condition.label)),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _returnCondition = value;
        });
      },
    );
  }

  Widget _assignmentFields(AppStore store, _QuickAction action) {
    final people = store.people.where((person) => person.isActive).toList();
    final locations = _activeLocations(store);
    final targets = store.activeAssignmentTargets.toList();
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _assignedPersonId,
          decoration: const InputDecoration(
            labelText: 'Assign to person optional',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(value: '', child: Text('No person')),
            for (final person in people)
              DropdownMenuItem(
                value: person.id,
                child: Text(person.displayName),
              ),
          ],
          onChanged: (value) {
            setState(() {
              _assignedPersonId = _emptyToNull(value);
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _assignedLocationId,
          decoration: InputDecoration(
            labelText: action == _QuickAction.checkOut
                ? 'Assign to location optional'
                : 'Assign location optional',
            border: const OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(value: '', child: Text('No location')),
            for (final location in locations)
              DropdownMenuItem(value: location.id, child: Text(location.name)),
          ],
          onChanged: (value) {
            setState(() {
              _assignedLocationId = _emptyToNull(value);
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _assignedTargetId,
          decoration: const InputDecoration(
            labelText: 'Assign to job/truck optional',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(value: '', child: Text('No job or truck')),
            for (final target in targets)
              DropdownMenuItem(
                value: target.id,
                child: Text(
                  '${target.name} (${assignmentTargetTypeLabel(target.targetType)})',
                ),
              ),
          ],
          onChanged: (value) {
            setState(() {
              _assignedTargetId = _emptyToNull(value);
            });
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _assignedTextController,
          decoration: const InputDecoration(
            labelText: 'Free text assignment optional',
            border: OutlineInputBorder(),
          ),
          validator: (_) {
            if (action != _QuickAction.checkOut) {
              return null;
            }
            final hasAssignee =
                _assignedPersonId != null ||
                _assignedLocationId != null ||
                _assignedTargetId != null ||
                _assignedTextController.text.trim().isNotEmpty;
            return hasAssignee ? null : 'Choose or enter an assignee.';
          },
        ),
      ],
    );
  }

  Future<void> _saveAction(
    AppStore store,
    Item item,
    _QuickAction action,
  ) async {
    if (store.isLocked) {
      _showMessage('Unlock Issued to continue.');
      return;
    }
    if (!_canStartAction(store, action)) {
      _showPermissionMessage();
      return;
    }
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final quantity = double.parse(_quantityController.text.trim());
    final notes = _notesController.text.trim();
    var success = false;
    var successMessage = '';

    switch (action) {
      case _QuickAction.issue:
        success = store.issueItemFromLocation(
          itemId: item.id,
          locationId: _selectedSourceLocationId!,
          quantity: quantity,
          assignedToPersonId: _assignedPersonId,
          assignedToLocationId: _assignedLocationId,
          assignedToTargetId: _assignedTargetId,
          assignedToText: _emptyToNull(_assignedTextController.text),
          notes: notes,
        );
        successMessage = 'Stock issued.';
      case _QuickAction.checkOut:
        success = store.checkOutItem(
          itemId: item.id,
          quantity: quantity,
          sourceLocationId: _selectedSourceLocationId!,
          assignedToPersonId: _assignedPersonId,
          assignedToLocationId: _assignedLocationId,
          assignedToTargetId: _assignedTargetId,
          assignedToText: _emptyToNull(_assignedTextController.text),
          notes: notes,
        );
        successMessage = 'Item checked out.';
      case _QuickAction.returnItem:
        success = _returnCheckout(store, quantity, notes);
        successMessage = _returnCondition.successMessage;
      case _QuickAction.receive:
        final stockQuantity = _receiveByPurchaseUnit
            ? store.convertPurchaseToStock(item, quantity)
            : quantity;
        success = store.receiveItemToLocation(
          itemId: item.id,
          locationId: _selectedDestinationLocationId!,
          quantity: stockQuantity,
          notes: notes,
        );
        successMessage = 'Stock received.';
    }

    if (!success) {
      _showMessage(_failureMessage(action));
      return;
    }

    final updated = store.itemById(item.id) ?? item;
    setState(() {
      _selectedItem = updated;
      _selectedAction = null;
      _message = null;
      _successMessage =
          '$successMessage Remaining: ${store.formatStockQuantity(updated, updated.quantityOnHand)}.';
      _resetFormFields();
    });
  }

  bool _returnCheckout(AppStore store, double quantity, String notes) {
    final record = _selectedCheckout;
    if (record == null) {
      return false;
    }
    if (quantity > record.quantityOpen) {
      _showMessage('Return quantity cannot exceed open quantity.');
      return false;
    }

    return switch (_returnCondition) {
      _ReturnCondition.good => store.returnCheckout(
        checkoutRecordId: record.id,
        returnedQuantity: quantity,
        returnToLocationId: _selectedDestinationLocationId!,
        notes: notes,
      ),
      _ReturnCondition.damaged => store.returnCheckout(
        checkoutRecordId: record.id,
        returnedQuantity: quantity,
        returnToLocationId: _selectedDestinationLocationId!,
        notes: notes,
        condition: CheckoutReturnCondition.damaged,
        returnDamagedToStock: false,
      ),
      _ReturnCondition.lost => store.returnCheckout(
        checkoutRecordId: record.id,
        returnedQuantity: quantity,
        returnToLocationId: _selectedDestinationLocationId!,
        notes: notes,
        condition: CheckoutReturnCondition.lost,
      ),
    };
  }

  String? _validateQuantity(AppStore store, Item item, _QuickAction action) {
    final raw = _quantityController.text.trim();
    final quantity = double.tryParse(raw);
    if (quantity == null || quantity <= 0) {
      return 'Enter a quantity greater than 0.';
    }

    if (action == _QuickAction.receive && _receiveByPurchaseUnit) {
      return store.validatePurchaseReceiveQuantity(item, quantity);
    }

    final stockUom = store.getStockUom(item);
    if (!item.allowFractionalQuantity &&
        stockUom?.allowsDecimal != true &&
        quantity != quantity.roundToDouble()) {
      return 'Quantity must be a whole number.';
    }

    if (action == _QuickAction.issue || action == _QuickAction.checkOut) {
      final locationId = _selectedSourceLocationId;
      if (locationId == null) {
        return null;
      }
      final available = _quantityAt(store, item.id, locationId);
      if (quantity > available) {
        return 'Not enough stock at this location.';
      }
    }

    if (action == _QuickAction.returnItem && _selectedCheckout != null) {
      if (quantity > _selectedCheckout!.quantityOpen) {
        return 'Return quantity cannot exceed open quantity.';
      }
      if (_returnCondition != _ReturnCondition.good &&
          !store.permissions.canAdjustQuantity) {
        return 'Your current role does not allow this action.';
      }
    }

    return null;
  }

  List<ItemLocationBalance> _stockLocations(AppStore store, Item item) {
    return store
        .itemBalancesForItem(item.id)
        .where((balance) => balance.quantityOnHand > 0)
        .toList();
  }

  List<Location> _activeLocations(AppStore store) {
    return store.locations.where((location) => location.isActive).toList();
  }

  double _quantityAt(AppStore store, String itemId, String locationId) {
    for (final balance in store.itemBalancesForItem(itemId)) {
      if (balance.locationId == locationId) {
        return balance.quantityOnHand;
      }
    }
    return 0;
  }

  void _openItemDetail(Item item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ItemDetailScreen(item: item),
      ),
    );
  }

  void _resetForNextScan() {
    setState(() {
      _selectedItem = null;
      _selectedAction = null;
      _selectedCheckout = null;
      _message = null;
      _successMessage = null;
      _searchController.clear();
      _resetFormFields();
    });
  }

  void _resetFormFields({bool preserveScanContext = false}) {
    final sourceLocationId = _selectedSourceLocationId;
    final destinationLocationId = _selectedDestinationLocationId;
    final assignmentTargetId = _assignedTargetId;
    _quantityController.clear();
    _notesController.clear();
    _assignedTextController.clear();
    _selectedSourceLocationId = null;
    _selectedDestinationLocationId = null;
    _assignedPersonId = null;
    _assignedLocationId = null;
    _assignedTargetId = null;
    _selectedCheckout = null;
    _returnCondition = _ReturnCondition.good;
    _receiveByPurchaseUnit = false;
    if (preserveScanContext) {
      _selectedSourceLocationId = sourceLocationId;
      _selectedDestinationLocationId = destinationLocationId;
      _assignedTargetId = assignmentTargetId;
    }
  }

  void _showPermissionMessage() {
    _showMessage('Your current role does not allow this action.');
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }
}

class _UserStrip extends StatelessWidget {
  const _UserStrip({required this.store, required this.onSwitchUser});

  final AppStore store;
  final VoidCallback onSwitchUser;

  @override
  Widget build(BuildContext context) {
    final userName = store.currentPerson?.displayName ?? 'No current user';
    final role = roleLabel(store.currentRole);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.person_pin_circle_outlined, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(role),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onSwitchUser,
              child: const Text('Switch User'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyPanel extends StatelessWidget {
  const _ReadyPanel({
    required this.controller,
    required this.onScan,
    required this.onSearchChanged,
  });

  final TextEditingController controller;
  final VoidCallback onScan;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Scan Item', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Search by name, SKU, barcode, or category',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.store,
    required this.onSelected,
  });

  final String query;
  final AppStore store;
  final ValueChanged<Item> onSelected;

  @override
  Widget build(BuildContext context) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      final recent = store.transactions
          .map((transaction) => store.itemById(transaction.itemId))
          .whereType<Item>()
          .fold<List<Item>>([], (items, item) {
            if (!items.any((stored) => stored.id == item.id)) {
              items.add(item);
            }
            return items;
          })
          .take(5)
          .toList();
      if (recent.isEmpty) {
        return const SizedBox.shrink();
      }
      return _ItemList(
        title: 'Recent Items',
        items: recent,
        onSelected: onSelected,
      );
    }

    final matches = store.items.where((item) {
      final fields = [
        item.name,
        item.category,
        item.barcode,
        item.sku,
      ].whereType<String>();
      return fields.any((value) => value.toLowerCase().contains(normalized));
    }).toList()..sort((left, right) => left.name.compareTo(right.name));

    if (matches.isEmpty) {
      return const _MessagePanel(message: 'No matching items found.');
    }
    return _ItemList(
      title: 'Search Results',
      items: matches,
      onSelected: onSelected,
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({
    required this.title,
    required this.items,
    required this.onSelected,
  });

  final String title;
  final List<Item> items;
  final ValueChanged<Item> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(title: Text(title)),
          for (final item in items)
            ListTile(
              title: Text(item.name),
              subtitle: Text(_itemSubtitle(item)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onSelected(item),
            ),
        ],
      ),
    );
  }
}

class _ItemActionPanel extends StatelessWidget {
  const _ItemActionPanel({
    required this.item,
    required this.store,
    required this.selectedAction,
    required this.onActionSelected,
    required this.onViewDetail,
    required this.onClear,
  });

  final Item item;
  final AppStore store;
  final _QuickAction? selectedAction;
  final ValueChanged<_QuickAction> onActionSelected;
  final VoidCallback onViewDetail;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final archived = !item.isActive;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_itemTypeLabel(item.itemType)} · ${store.formatStockQuantity(item, item.quantityOnHand)} · ${archived ? 'Archived' : 'Active'}',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Clear',
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StockSummary(item: item, store: store),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!archived && item.itemType == ItemType.consumable)
                  _ActionButton(
                    label: 'Issue',
                    icon: Icons.call_made,
                    selected: selectedAction == _QuickAction.issue,
                    onPressed: () => onActionSelected(_QuickAction.issue),
                  ),
                if (!archived && item.itemType != ItemType.consumable) ...[
                  _ActionButton(
                    label: 'Check Out',
                    icon: Icons.outbond_outlined,
                    selected: selectedAction == _QuickAction.checkOut,
                    onPressed: () => onActionSelected(_QuickAction.checkOut),
                  ),
                  _ActionButton(
                    label: 'Return',
                    icon: Icons.keyboard_return,
                    selected: selectedAction == _QuickAction.returnItem,
                    onPressed: () => onActionSelected(_QuickAction.returnItem),
                  ),
                ],
                if (!archived && store.permissions.canReceiveStock)
                  _ActionButton(
                    label: 'Receive',
                    icon: Icons.add_box_outlined,
                    selected: selectedAction == _QuickAction.receive,
                    onPressed: () => onActionSelected(_QuickAction.receive),
                  ),
                _ActionButton(
                  label: 'View Item Detail',
                  icon: Icons.open_in_new,
                  selected: false,
                  onPressed: onViewDetail,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon), const SizedBox(width: 8), Text(label)],
      ),
    );
    return selected
        ? FilledButton(onPressed: onPressed, child: child)
        : OutlinedButton(onPressed: onPressed, child: child);
  }
}

class _StockSummary extends StatelessWidget {
  const _StockSummary({required this.item, required this.store});

  final Item item;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final balances = store.itemBalancesForItem(item.id);
    if (balances.isEmpty) {
      return const Text('No stock by location yet.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final balance in balances.take(4))
          Text(
            '${store.resolveLocationName(balance.locationId) ?? 'Unknown'}: ${store.formatStockQuantity(item, balance.quantityOnHand)}',
          ),
      ],
    );
  }
}

class _SuccessPanel extends StatelessWidget {
  const _SuccessPanel({
    required this.message,
    required this.item,
    required this.store,
    required this.onScanNext,
  });

  final String message;
  final Item? item;
  final AppStore store;
  final VoidCallback onScanNext;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onScanNext,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _NoOpenCheckoutsPanel extends StatelessWidget {
  const _NoOpenCheckoutsPanel({required this.onViewDetail});

  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('No open checkouts found for this item.'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onViewDetail,
              child: const Text('View Item Detail'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickScanRoute extends StatefulWidget {
  const _QuickScanRoute();

  @override
  State<_QuickScanRoute> createState() => _QuickScanRouteState();
}

class _QuickScanRouteState extends State<_QuickScanRoute> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Item')),
      body: MobileScanner(
        controller: _controller,
        onDetect: _handleCapture,
        errorBuilder: (context, error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.errorCode.message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  void _handleCapture(BarcodeCapture capture) {
    if (_handled) {
      return;
    }
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue?.trim();
      if (code != null && code.isNotEmpty) {
        _handled = true;
        Navigator.of(context).pop(code);
        return;
      }
    }
  }
}

enum _QuickAction { issue, checkOut, returnItem, receive }

enum _ReturnCondition {
  good('Good', 'Item returned.'),
  damaged('Damaged', 'Item marked damaged.'),
  lost('Lost', 'Item marked lost.');

  const _ReturnCondition(this.label, this.successMessage);

  final String label;
  final String successMessage;
}

String _actionTitle(_QuickAction action) {
  return switch (action) {
    _QuickAction.issue => 'Issue',
    _QuickAction.checkOut => 'Check Out',
    _QuickAction.returnItem => 'Return',
    _QuickAction.receive => 'Receive',
  };
}

String _saveLabel(_QuickAction action) {
  return switch (action) {
    _QuickAction.issue => 'Issue',
    _QuickAction.checkOut => 'Check Out',
    _QuickAction.returnItem => 'Return',
    _QuickAction.receive => 'Receive',
  };
}

String _failureMessage(_QuickAction action) {
  return switch (action) {
    _QuickAction.issue => 'Could not issue stock.',
    _QuickAction.checkOut => 'Could not check out this item.',
    _QuickAction.returnItem => 'Could not return this item.',
    _QuickAction.receive => 'Could not receive stock.',
  };
}

String _quantityLabel(AppStore store, Item item, _QuickAction action) {
  if (action == _QuickAction.receive &&
      store.hasPurchaseConversion(item) &&
      store.getPurchaseUom(item) != null) {
    return 'Quantity (${store.getPurchaseUom(item)!.abbreviation})';
  }
  return 'Quantity (${store.resolveUomAbbreviation(item.unitOfMeasureId)})';
}

String _itemSubtitle(Item item) {
  final sku = item.sku == null || item.sku!.trim().isEmpty
      ? null
      : 'SKU ${item.sku}';
  return [
    _itemTypeLabel(item.itemType),
    item.category,
    ?sku,
    item.isActive ? 'Active' : 'Archived',
  ].where((part) => part.trim().isNotEmpty).join(' · ');
}

String _itemTypeLabel(ItemType type) {
  return switch (type) {
    ItemType.consumable => 'Consumable',
    ItemType.returnable => 'Returnable',
    ItemType.asset => 'Asset',
  };
}

String _checkoutLabel(AppStore store, CheckoutRecord record) {
  return [
    _assignedToText(store, record),
    '${store.formatStockQuantity(store.itemById(record.itemId)!, record.quantityOpen)} open',
  ].join(' · ');
}

String _assignedToText(AppStore store, CheckoutRecord record) {
  if (record.assignedToPersonId != null) {
    for (final person in store.people) {
      if (person.id == record.assignedToPersonId) {
        return person.displayName;
      }
    }
  }
  if (record.assignedToLocationId != null) {
    return store.resolveLocationName(record.assignedToLocationId) ??
        'Unknown location';
  }
  if (record.assignedToTargetId != null) {
    for (final target in store.assignmentTargets) {
      if (target.id == record.assignedToTargetId) {
        return target.name;
      }
    }
  }
  return record.assignedToText ?? 'Unassigned';
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }
  return quantity.toStringAsFixed(2);
}

String? _emptyToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
