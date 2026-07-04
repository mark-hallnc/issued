import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/app_store.dart';
import '../core/labels/label_service.dart';
import '../core/models/models.dart';
import '../core/photos/item_photo_service.dart';
import 'plan_screens.dart';
import 'settings_detail_screens.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.item});

  final Item item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final _photoService = ItemPhotoService();
  late Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final permissions = store.permissions;
    final unit = _unitById(store, _item.unitOfMeasureId);
    final location = _locationById(store, _item.locationId);
    final showReturnableActions =
        _item.itemType == ItemType.returnable ||
        _item.itemType == ItemType.asset;
    final openCheckouts = store.openCheckoutRecordsForItem(_item.id);
    final checkedOutPerson = _checkedOutPerson(store);
    final recentTransactions = _recentTransactions(store);

    return Scaffold(
      appBar: AppBar(title: const Text('Item Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _item.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF17212F),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(label: _itemTypeLabel(_item.itemType)),
                      _InfoPill(label: _item.isActive ? 'Active' : 'Inactive'),
                      if (checkedOutPerson != null)
                        _InfoPill(label: 'Checked out to $checkedOutPerson'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ItemPhotoCard(
            item: _item,
            canManagePhoto: permissions.canManageItems,
            onAddOrReplace: _showPhotoSourcePicker,
            onRemove: _removePhoto,
          ),
          const SizedBox(height: 12),
          if (openCheckouts.isNotEmpty) ...[
            _CurrentCheckoutsCard(
              records: openCheckouts,
              store: store,
              onReturn: _returnCheckout,
              onMarkLost: _markCheckoutLost,
              onMarkDamaged: _markCheckoutDamaged,
            ),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'On hand',
                    value:
                        '${_formatQuantity(_item.quantityOnHand)} ${unit?.abbreviation ?? ''}',
                  ),
                  _DetailRow(
                    label: 'Minimum',
                    value:
                        '${_formatQuantity(_item.minimumQuantity)} ${unit?.abbreviation ?? ''}',
                  ),
                  _DetailRow(
                    label: 'Location',
                    value: location?.name ?? 'Unknown location',
                  ),
                  _DetailRow(label: 'Category', value: _item.category),
                  if (_item.sku != null)
                    _DetailRow(label: 'SKU', value: _item.sku!),
                  if (_item.barcode != null)
                    _DetailRow(label: 'Barcode', value: _item.barcode!),
                  if (_item.supplier != null)
                    _DetailRow(label: 'Supplier', value: _item.supplier!),
                  if (_item.unitCost != null && permissions.canViewCosts)
                    _DetailRow(
                      label: 'Unit cost',
                      value: '\$${_item.unitCost!.toStringAsFixed(2)}',
                    ),
                  if (_item.unitCost != null && !permissions.canViewCosts)
                    const _DetailRow(
                      label: 'Unit cost',
                      value: 'Hidden by role',
                    ),
                  _DetailRow(
                    label: 'Status',
                    value: checkedOutPerson == null
                        ? (_item.isActive ? 'Active' : 'Inactive')
                        : 'Checked out',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QR Label',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF17212F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.white,
                      child: QrImageView(
                        data: itemQrValue(_item),
                        version: QrVersions.auto,
                        size: 176,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    itemQrValue(_item),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF394554),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (permissions.canImportExport) ...[
                        OutlinedButton.icon(
                          onPressed: _shareLabel,
                          icon: const Icon(Icons.ios_share),
                          label: const Text('Share Label'),
                        ),
                        FilledButton.icon(
                          onPressed: _printLabel,
                          icon: const Icon(Icons.print),
                          label: const Text('Print/Export Label'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF17212F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (permissions.canIssueItems)
                        _ActionButton(
                          label: 'Issue',
                          icon: Icons.call_made,
                          onPressed: _issueItem,
                        ),
                      if (permissions.canReceiveStock)
                        _ActionButton(
                          label: 'Receive',
                          icon: Icons.add_box,
                          onPressed: _receiveStock,
                        ),
                      if (permissions.canTransferStock)
                        _ActionButton(
                          label: 'Transfer',
                          icon: Icons.swap_horiz,
                          onPressed: _transferItem,
                        ),
                      if (permissions.canAdjustQuantity)
                        _ActionButton(
                          label: 'Adjust',
                          icon: Icons.tune,
                          onPressed: _adjustQuantity,
                        ),
                      if (showReturnableActions) ...[
                        if (permissions.canIssueItems)
                          _ActionButton(
                            label: 'Check Out',
                            icon: Icons.assignment_ind,
                            onPressed: _checkOutItem,
                          ),
                        if (permissions.canIssueItems)
                          _ActionButton(
                            label: 'Return',
                            icon: Icons.assignment_return,
                            onPressed: _returnItem,
                          ),
                        if (permissions.canAdjustQuantity)
                          _ActionButton(
                            label: 'Mark Lost/Damaged',
                            icon: Icons.report_problem_outlined,
                            onPressed: _markLostOrDamaged,
                          ),
                      ],
                      if (permissions.canArchiveItems)
                        _ActionButton(
                          label: _item.isActive ? 'Archive' : 'Unarchive',
                          icon: _item.isActive
                              ? Icons.archive_outlined
                              : Icons.unarchive_outlined,
                          onPressed: _toggleArchive,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF17212F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (recentTransactions.isEmpty)
                    Text(
                      'No activity yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5C6672),
                      ),
                    )
                  else
                    for (final transaction in recentTransactions)
                      _TransactionRow(transaction: transaction),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareLabel() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canImportExport) {
      _showPermissionDenied();
      return;
    }

    if (!store.canExportLabel) {
      await _showLabelLimitReached(store);
      return;
    }

    final bytes = await buildSingleItemLabelPdf(_labelItem(store));
    final didShare = await Printing.sharePdf(
      bytes: bytes,
      filename: safeLabelFileName(_item),
    );

    if (didShare && mounted) {
      store.recordLabelExport();
    }
  }

  Future<void> _printLabel() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canImportExport) {
      _showPermissionDenied();
      return;
    }

    if (!store.canExportLabel) {
      await _showLabelLimitReached(store);
      return;
    }

    final labelItem = _labelItem(store);
    final didPrint = await Printing.layoutPdf(
      name: safeLabelFileName(_item),
      onLayout: (_) => buildSingleItemLabelPdf(labelItem),
    );

    if (didPrint && mounted) {
      store.recordLabelExport();
    }
  }

  Future<void> _showLabelLimitReached(AppStore store) async {
    final action = await showPlanLimitDialog(
      context,
      title: 'Label export limit reached',
      message:
          'Your ${store.currentPlan.name} plan includes ${store.currentPlan.labelExportLimit} label exports per month.',
      recommendedPlanCode: store
          .getLimitWarningForLabels()
          ?.recommendedPlanCode,
    );

    if (!mounted || action != PlanLimitDialogAction.upgrade) {
      return;
    }

    await openComparePlans(
      context,
      recommendedPlanCode: store
          .getLimitWarningForLabels()
          ?.recommendedPlanCode,
    );
  }

  Future<void> _showPhotoSourcePicker() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageItems) {
      _showPermissionDenied();
      return;
    }

    final hasPhoto = _item.photoPath?.trim().isNotEmpty ?? false;
    if (!hasPhoto && !store.canAddPhoto) {
      await _showPhotoLimitReached(store);
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose From Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) {
      return;
    }

    try {
      final pickedPhoto = await _photoService.pickPhoto(source);
      if (pickedPhoto == null) {
        return;
      }

      final savedPath = await _photoService.saveItemPhoto(
        itemId: _item.id,
        pickedFile: pickedPhoto,
      );
      _applyItemUpdate(
        _item.copyWith(photoPath: savedPath, updatedAt: DateTime.now()),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the item photo.')),
      );
    }
  }

  Future<void> _showPhotoLimitReached(AppStore store) async {
    final action = await showDialog<_PhotoLimitAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo limit reached'),
        content: Text(
          'Your current plan includes up to ${store.currentPlan.photoLimit} item photos.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_PhotoLimitAction.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_PhotoLimitAction.viewPlan),
            child: const Text('View Plan'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(_PhotoLimitAction.upgrade),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );

    if (!mounted) {
      return;
    }

    switch (action) {
      case _PhotoLimitAction.viewPlan:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const PlanUsageSettingsScreen(),
          ),
        );
      case _PhotoLimitAction.upgrade:
        await openComparePlans(
          context,
          recommendedPlanCode: store
              .getLimitWarningForPhotos()
              ?.recommendedPlanCode,
        );
      case _PhotoLimitAction.cancel || null:
        return;
    }
  }

  void _removePhoto() {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageItems) {
      _showPermissionDenied();
      return;
    }

    _applyItemUpdate(
      _item.copyWith(clearPhotoPath: true, updatedAt: DateTime.now()),
    );
  }

  Future<void> _receiveStock() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canReceiveStock) {
      _showPermissionDenied();
      return;
    }

    final result = await _showQuantityNotesDialog(
      title: 'Receive Stock',
      quantityLabel: 'Quantity received',
    );

    if (result == null) {
      return;
    }

    _applyItemUpdate(
      _item.copyWith(
        quantityOnHand: _item.quantityOnHand + result.quantity,
        updatedAt: DateTime.now(),
      ),
    );
    _appendTransaction(
      InventoryTransactionType.receive,
      result.quantity,
      notes: result.notes,
      toLocationId: _item.locationId,
    );
  }

  Future<void> _issueItem() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canIssueItems) {
      _showPermissionDenied();
      return;
    }

    final person = _defaultPerson(store);
    final result = await _showQuantityNotesDialog(
      title: _item.itemType == ItemType.consumable
          ? 'Issue Consumable'
          : 'Issue Item',
      quantityLabel: 'Quantity issued',
    );

    if (result == null) {
      return;
    }

    _applyItemUpdate(
      _item.copyWith(
        quantityOnHand: _item.quantityOnHand - result.quantity,
        updatedAt: DateTime.now(),
      ),
    );
    _appendTransaction(
      InventoryTransactionType.issue,
      -result.quantity,
      notes: result.notes,
      fromLocationId: _item.locationId,
      assignedToPersonId: person?.id,
    );
  }

  Future<void> _checkOutItem() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canIssueItems) {
      _showPermissionDenied();
      return;
    }

    final result = await showDialog<_CheckoutDialogResult>(
      context: context,
      builder: (context) =>
          _CheckoutDialog(store: AppStoreScope.of(context), initialQuantity: 1),
    );

    if (result == null) {
      return;
    }

    final checkedOut = store.checkOutItem(
      itemId: _item.id,
      quantity: result.quantity,
      assignedToPersonId: result.assignedToPersonId,
      assignedToLocationId: result.assignedToLocationId,
      assignedToText: result.assignedToText,
      dueAt: result.dueAt,
      notes: result.notes,
    );

    if (!checkedOut) {
      _showMessage('Could not check out this item.');
      return;
    }

    _syncCurrentItem(store);
    _showMessage('Item checked out.');
  }

  Future<void> _returnItem() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canIssueItems) {
      _showPermissionDenied();
      return;
    }

    final openCheckouts = store.openCheckoutRecordsForItem(_item.id);
    if (openCheckouts.isEmpty) {
      _showMessage('This item is not currently checked out.');
      return;
    }

    if (openCheckouts.length == 1) {
      await _returnCheckout(openCheckouts.first);
      return;
    }

    final selectedRecord = await showDialog<CheckoutRecord>(
      context: context,
      builder: (context) => _SelectCheckoutDialog(
        records: openCheckouts,
        store: AppStoreScope.of(context),
      ),
    );
    if (selectedRecord == null) {
      return;
    }

    await _returnCheckout(selectedRecord);
  }

  Future<void> _returnCheckout(CheckoutRecord record) async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canIssueItems) {
      _showPermissionDenied();
      return;
    }

    final result = await _showQuantityNotesDialog(
      title: 'Return Checked Out Item',
      quantityLabel: 'Quantity returned',
      initialQuantity: record.quantity,
    );

    if (result == null) {
      return;
    }

    if (result.quantity != record.quantity) {
      _showMessage('Partial returns are not supported yet.');
      return;
    }

    final returned = store.returnCheckout(
      checkoutRecordId: record.id,
      returnedQuantity: result.quantity,
      notes: result.notes,
    );

    if (!returned) {
      _showMessage('Could not return this item.');
      return;
    }

    _syncCurrentItem(store);
    _showMessage('Item returned.');
  }

  Future<void> _transferItem() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canTransferStock) {
      _showPermissionDenied();
      return;
    }

    final result = await showDialog<_TransferResult>(
      context: context,
      builder: (context) => _TransferDialog(
        currentLocationId: _item.locationId,
        store: AppStoreScope.of(context),
      ),
    );

    if (result == null) {
      return;
    }

    final fromLocationId = _item.locationId;
    _applyItemUpdate(
      _item.copyWith(
        locationId: result.toLocationId,
        updatedAt: DateTime.now(),
      ),
    );
    _appendTransaction(
      InventoryTransactionType.transfer,
      0,
      notes: result.notes,
      fromLocationId: fromLocationId,
      toLocationId: result.toLocationId,
    );
  }

  Future<void> _adjustQuantity() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canAdjustQuantity) {
      _showPermissionDenied();
      return;
    }

    final result = await _showQuantityNotesDialog(
      title: 'Set Quantity On Hand',
      quantityLabel: 'New quantity on hand',
      initialQuantity: _item.quantityOnHand,
    );

    if (result == null) {
      return;
    }

    final delta = result.quantity - _item.quantityOnHand;
    _applyItemUpdate(
      _item.copyWith(
        quantityOnHand: result.quantity,
        updatedAt: DateTime.now(),
      ),
    );
    _appendTransaction(
      InventoryTransactionType.adjustment,
      delta,
      notes: result.notes,
      toLocationId: _item.locationId,
    );
  }

  Future<void> _markLostOrDamaged() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canAdjustQuantity) {
      _showPermissionDenied();
      return;
    }

    final openCheckouts = store.openCheckoutRecordsForItem(_item.id);
    if (openCheckouts.isNotEmpty) {
      await _markCheckoutDamaged(openCheckouts.first);
      return;
    }

    final result = await _showQuantityNotesDialog(
      title: 'Mark Lost/Damaged',
      quantityLabel: 'Quantity lost/damaged',
      initialQuantity: 1,
    );

    if (result == null) {
      return;
    }

    _applyItemUpdate(
      _item.copyWith(
        quantityOnHand: _item.quantityOnHand - result.quantity,
        updatedAt: DateTime.now(),
      ),
    );
    _appendTransaction(
      InventoryTransactionType.markDamaged,
      -result.quantity,
      notes: result.notes,
      fromLocationId: _item.locationId,
    );
  }

  Future<void> _markCheckoutLost(CheckoutRecord record) async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canAdjustQuantity) {
      _showPermissionDenied();
      return;
    }

    if (!store.markCheckoutLost(record.id, null)) {
      _showMessage('Could not mark this checkout lost.');
      return;
    }

    setState(() {});
    _showMessage('Marked lost.');
  }

  Future<void> _markCheckoutDamaged(CheckoutRecord record) async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canAdjustQuantity) {
      _showPermissionDenied();
      return;
    }

    if (!store.markCheckoutDamaged(record.id, null)) {
      _showMessage('Could not mark this checkout damaged.');
      return;
    }

    setState(() {});
    _showMessage('Marked damaged.');
  }

  Future<void> _toggleArchive() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canArchiveItems) {
      _showPermissionDenied();
      return;
    }

    if (_item.isActive) {
      _applyItemUpdate(
        _item.copyWith(isActive: false, updatedAt: DateTime.now()),
      );
      return;
    }

    if (!store.canAddItem) {
      final action = await showPlanLimitDialog(
        context,
        title: 'Item limit reached',
        message:
            'Your ${store.currentPlan.name} plan includes up to ${store.currentPlan.itemLimit} active items.',
        recommendedPlanCode: store
            .getLimitWarningForItems()
            ?.recommendedPlanCode,
        showArchiveItems: true,
      );

      if (!mounted || action != PlanLimitDialogAction.upgrade) {
        return;
      }

      await openComparePlans(
        context,
        recommendedPlanCode: store
            .getLimitWarningForItems()
            ?.recommendedPlanCode,
      );
      return;
    }

    _applyItemUpdate(_item.copyWith(isActive: true, updatedAt: DateTime.now()));
  }

  Future<_QuantityNotesResult?> _showQuantityNotesDialog({
    required String title,
    required String quantityLabel,
    double initialQuantity = 1,
    String? helperText,
  }) {
    return showDialog<_QuantityNotesResult>(
      context: context,
      builder: (context) => _QuantityNotesDialog(
        title: title,
        quantityLabel: quantityLabel,
        initialQuantity: initialQuantity,
        helperText: helperText,
      ),
    );
  }

  void _applyItemUpdate(Item updatedItem) {
    final store = AppStoreScope.of(context);
    store.updateItem(updatedItem);

    setState(() {
      _item = updatedItem;
    });
  }

  void _syncCurrentItem(AppStore store) {
    for (final item in store.items) {
      if (item.id == _item.id) {
        setState(() {
          _item = item;
        });
        return;
      }
    }

    setState(() {});
  }

  void _appendTransaction(
    InventoryTransactionType type,
    double quantityDelta, {
    String? notes,
    String? fromLocationId,
    String? toLocationId,
    String? assignedToPersonId,
  }) {
    final store = AppStoreScope.of(context);
    store.addTransaction(
      InventoryTransaction(
        id: 'txn-${DateTime.now().microsecondsSinceEpoch}',
        itemId: _item.id,
        transactionType: type,
        quantityDelta: quantityDelta,
        unitOfMeasureId: _item.unitOfMeasureId,
        fromLocationId: fromLocationId,
        toLocationId: toLocationId,
        assignedToPersonId: assignedToPersonId,
        performedByUserId: store.users.isEmpty ? null : store.users.first.id,
        notes: notes,
        createdAt: DateTime.now(),
      ),
    );

    setState(() {});
  }

  void _showPermissionDenied() {
    _showMessage('Your current role does not allow this action.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<InventoryTransaction> _recentTransactions(AppStore store) {
    final transactions = store.transactions
        .where((transaction) => transaction.itemId == _item.id)
        .toList();

    transactions.sort(
      (left, right) => right.createdAt.compareTo(left.createdAt),
    );
    return transactions.take(5).toList();
  }

  String? _checkedOutPerson(AppStore store) {
    final openCheckouts = store.openCheckoutRecordsForItem(_item.id);
    if (openCheckouts.isEmpty) {
      return null;
    }

    final personId = openCheckouts.first.assignedToPersonId;
    if (personId == null) {
      return 'assigned person';
    }

    return _personById(store, personId)?.displayName ?? 'assigned person';
  }

  Person? _personById(AppStore store, String personId) {
    for (final person in store.people) {
      if (person.id == personId) {
        return person;
      }
    }

    return null;
  }

  Person? _defaultPerson(AppStore store) {
    return store.people.isEmpty ? null : store.people.last;
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

  LabelItem _labelItem(AppStore store) {
    final unit = _unitById(store, _item.unitOfMeasureId);
    final location = _locationById(store, _item.locationId);

    return LabelItem(
      item: _item,
      codeValue: itemQrValue(_item),
      itemType: _itemTypeLabel(_item.itemType),
      quantityText:
          '${_formatQuantity(_item.quantityOnHand)} ${unit?.abbreviation ?? ''}'
              .trim(),
      locationName: location?.name,
    );
  }

  String _itemTypeLabel(ItemType type) {
    return switch (type) {
      ItemType.consumable => 'Consumable',
      ItemType.returnable => 'Returnable',
      ItemType.asset => 'Asset',
    };
  }
}

class _ItemPhotoCard extends StatelessWidget {
  const _ItemPhotoCard({
    required this.item,
    required this.canManagePhoto,
    required this.onAddOrReplace,
    required this.onRemove,
  });

  final Item item;
  final bool canManagePhoto;
  final VoidCallback onAddOrReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final photoPath = item.photoPath?.trim();
    final hasPhotoPath = photoPath != null && photoPath.isNotEmpty;
    final photoFile = hasPhotoPath ? File(photoPath) : null;
    final photoExists = photoFile?.existsSync() ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item Photo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF17212F),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: photoExists
                    ? Image.file(photoFile!, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFFF4F6F8),
                        child: const Center(
                          child: Icon(
                            Icons.photo_camera_outlined,
                            size: 48,
                            color: Color(0xFF5C6672),
                          ),
                        ),
                      ),
              ),
            ),
            if (hasPhotoPath && !photoExists && canManagePhoto) ...[
              const SizedBox(height: 8),
              Text(
                'Photo file is missing. Replace or remove it.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF7A4B00)),
              ),
            ],
            if (canManagePhoto) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: onAddOrReplace,
                    icon: Icon(
                      hasPhotoPath ? Icons.refresh : Icons.add_a_photo,
                    ),
                    label: Text(hasPhotoPath ? 'Replace Photo' : 'Add Photo'),
                  ),
                  if (hasPhotoPath)
                    OutlinedButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove Photo'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CurrentCheckoutsCard extends StatelessWidget {
  const _CurrentCheckoutsCard({
    required this.records,
    required this.store,
    required this.onReturn,
    required this.onMarkLost,
    required this.onMarkDamaged,
  });

  final List<CheckoutRecord> records;
  final AppStore store;
  final Future<void> Function(CheckoutRecord record) onReturn;
  final Future<void> Function(CheckoutRecord record) onMarkLost;
  final Future<void> Function(CheckoutRecord record) onMarkDamaged;

  @override
  Widget build(BuildContext context) {
    final permissions = store.permissions;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Currently checked out',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF17212F),
              ),
            ),
            const SizedBox(height: 10),
            for (final record in records) ...[
              _CurrentCheckoutRow(
                record: record,
                store: store,
                canReturn: permissions.canIssueItems,
                canMarkLostDamaged: permissions.canAdjustQuantity,
                onReturn: () => onReturn(record),
                onMarkLost: () => onMarkLost(record),
                onMarkDamaged: () => onMarkDamaged(record),
              ),
              if (record != records.last) const Divider(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _CurrentCheckoutRow extends StatelessWidget {
  const _CurrentCheckoutRow({
    required this.record,
    required this.store,
    required this.canReturn,
    required this.canMarkLostDamaged,
    required this.onReturn,
    required this.onMarkLost,
    required this.onMarkDamaged,
  });

  final CheckoutRecord record;
  final AppStore store;
  final bool canReturn;
  final bool canMarkLostDamaged;
  final VoidCallback onReturn;
  final VoidCallback onMarkLost;
  final VoidCallback onMarkDamaged;

  @override
  Widget build(BuildContext context) {
    final unit = _unitById(store, record.unitOfMeasureId);
    final overdue = _isOverdue(record);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${_formatQuantity(record.quantity)} ${unit?.abbreviation ?? ''}',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (overdue) const Chip(label: Text('Overdue')),
          ],
        ),
        const SizedBox(height: 4),
        Text('Assigned to: ${_assignedToText(store, record)}'),
        Text('Checked out: ${_formatDate(record.checkedOutAt)}'),
        if (record.dueAt != null) Text('Due: ${_formatDate(record.dueAt!)}'),
        if ((record.notes ?? '').trim().isNotEmpty)
          Text('Notes: ${record.notes}'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: canReturn ? onReturn : null,
              child: const Text('Return'),
            ),
            OutlinedButton(
              onPressed: canMarkLostDamaged ? onMarkLost : null,
              child: const Text('Mark Lost'),
            ),
            OutlinedButton(
              onPressed: canMarkLostDamaged ? onMarkDamaged : null,
              child: const Text('Mark Damaged'),
            ),
          ],
        ),
      ],
    );
  }
}

class _CheckoutDialogResult {
  const _CheckoutDialogResult({
    required this.quantity,
    required this.assignedToPersonId,
    required this.assignedToLocationId,
    required this.assignedToText,
    required this.dueAt,
    required this.notes,
  });

  final double quantity;
  final String? assignedToPersonId;
  final String? assignedToLocationId;
  final String? assignedToText;
  final DateTime? dueAt;
  final String? notes;
}

class _CheckoutDialog extends StatefulWidget {
  const _CheckoutDialog({required this.store, required this.initialQuantity});

  final AppStore store;
  final double initialQuantity;

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _assignedTextController;
  late final TextEditingController _notesController;
  String? _assignedToPersonId;
  String? _assignedToLocationId;
  DateTime? _dueAt;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: _formatQuantity(widget.initialQuantity),
    );
    _assignedTextController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _assignedTextController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final people = widget.store.people.where((person) => person.isActive);
    final locations = widget.store.locations.where(
      (location) => location.isActive,
    );

    return AlertDialog(
      title: const Text('Check Out Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final quantity = double.tryParse(value?.trim() ?? '');
                  if (quantity == null || quantity <= 0) {
                    return 'Enter a quantity greater than 0.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _assignedToPersonId,
                decoration: const InputDecoration(labelText: 'Assigned person'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No person'),
                  ),
                  for (final person in people)
                    DropdownMenuItem<String?>(
                      value: person.id,
                      child: Text(person.displayName),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _assignedToPersonId = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _assignedToLocationId,
                decoration: const InputDecoration(
                  labelText: 'Assigned location',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No location'),
                  ),
                  for (final location in locations)
                    DropdownMenuItem<String?>(
                      value: location.id,
                      child: Text(location.name),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _assignedToLocationId = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _assignedTextController,
                decoration: const InputDecoration(
                  labelText: 'Job, truck, or other assignment',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDueDate,
                icon: const Icon(Icons.event),
                label: Text(
                  _dueAt == null
                      ? 'Add Due Date'
                      : 'Due ${_formatDate(_dueAt!)}',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Check Out')),
      ],
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 3650)),
      initialDate: _dueAt ?? DateTime(now.year, now.month, now.day),
    );
    if (date == null) {
      return;
    }

    setState(() {
      _dueAt = date;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final assignedText = _assignedTextController.text.trim();
    final notes = _notesController.text.trim();
    Navigator.of(context).pop(
      _CheckoutDialogResult(
        quantity: double.parse(_quantityController.text.trim()),
        assignedToPersonId: _assignedToPersonId,
        assignedToLocationId: _assignedToLocationId,
        assignedToText: assignedText.isEmpty ? null : assignedText,
        dueAt: _dueAt,
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }
}

class _SelectCheckoutDialog extends StatelessWidget {
  const _SelectCheckoutDialog({required this.records, required this.store});

  final List<CheckoutRecord> records;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Choose Checkout'),
      children: [
        for (final record in records)
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(record),
            child: Text(
              '${_assignedToText(store, record)} - ${_formatQuantity(record.quantity)}',
            ),
          ),
      ],
    );
  }
}

enum _PhotoLimitAction { cancel, viewPlan, upgrade }

class _QuantityNotesDialog extends StatefulWidget {
  const _QuantityNotesDialog({
    required this.title,
    required this.quantityLabel,
    required this.initialQuantity,
    this.helperText,
  });

  final String title;
  final String quantityLabel;
  final double initialQuantity;
  final String? helperText;

  @override
  State<_QuantityNotesDialog> createState() => _QuantityNotesDialogState();
}

class _QuantityNotesDialogState extends State<_QuantityNotesDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: _formatQuantity(widget.initialQuantity),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: widget.quantityLabel,
                  helperText: widget.helperText,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _quantityValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes optional'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  String? _quantityValidator(String? value) {
    final quantity = double.tryParse(value?.trim() ?? '');

    if (quantity == null) {
      return 'Enter a valid number';
    }

    if (quantity < 0) {
      return 'Enter zero or greater';
    }

    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _QuantityNotesResult(
        quantity: double.parse(_quantityController.text.trim()),
        notes: _emptyToNull(_notesController.text),
      ),
    );
  }
}

class _TransferDialog extends StatefulWidget {
  const _TransferDialog({required this.currentLocationId, required this.store});

  final String currentLocationId;
  final AppStore store;

  @override
  State<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<_TransferDialog> {
  final _notesController = TextEditingController();
  late String _toLocationId;

  @override
  void initState() {
    super.initState();
    _toLocationId = widget.store.locations
        .firstWhere(
          (location) => location.id != widget.currentLocationId,
          orElse: () => widget.store.locations.first,
        )
        .id;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromLocation = widget.store.locations.firstWhere(
      (location) => location.id == widget.currentLocationId,
      orElse: () => widget.store.locations.first,
    );

    return AlertDialog(
      title: const Text('Transfer Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow(label: 'From', value: fromLocation.name),
            DropdownButtonFormField<String>(
              initialValue: _toLocationId,
              decoration: const InputDecoration(labelText: 'To location'),
              items: widget.store.locations
                  .map(
                    (location) => DropdownMenuItem(
                      value: location.id,
                      child: Text(location.name),
                    ),
                  )
                  .toList(),
              onChanged: (locationId) {
                if (locationId == null) {
                  return;
                }

                setState(() {
                  _toLocationId = locationId;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes optional'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _TransferResult(
                toLocationId: _toLocationId,
                notes: _emptyToNull(_notesController.text),
              ),
            );
          },
          child: const Text('Transfer'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5C6672),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF17212F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final InventoryTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final quantityText = _formatQuantity(transaction.quantityDelta);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_transactionLabel(transaction.transactionType)} ($quantityText)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF17212F),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            transaction.notes?.isEmpty ?? true
                ? _formatDate(transaction.createdAt)
                : '${_formatDate(transaction.createdAt)} - ${transaction.notes}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF5C6672)),
          ),
        ],
      ),
    );
  }

  String _transactionLabel(InventoryTransactionType type) {
    return switch (type) {
      InventoryTransactionType.receive => 'Receive',
      InventoryTransactionType.issue => 'Issue',
      InventoryTransactionType.checkout => 'Check Out',
      InventoryTransactionType.returnItem => 'Return',
      InventoryTransactionType.transfer => 'Transfer',
      InventoryTransactionType.adjustment => 'Adjust',
      InventoryTransactionType.markLost => 'Lost',
      InventoryTransactionType.markDamaged => 'Lost/Damaged',
      InventoryTransactionType.cycleCountAdjustment => 'Cycle Count',
    };
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE1E6EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: const Color(0xFF394554)),
        ),
      ),
    );
  }
}

class _QuantityNotesResult {
  const _QuantityNotesResult({required this.quantity, required this.notes});

  final double quantity;
  final String? notes;
}

class _TransferResult {
  const _TransferResult({required this.toLocationId, required this.notes});

  final String toLocationId;
  final String? notes;
}

String _assignedToText(AppStore store, CheckoutRecord record) {
  final parts = <String>[];
  final personId = record.assignedToPersonId;
  if (personId != null) {
    parts.add(_personNameById(store, personId) ?? 'Unknown person');
  }

  final locationId = record.assignedToLocationId;
  if (locationId != null) {
    parts.add(_locationNameById(store, locationId) ?? 'Unknown location');
  }

  final assignedText = record.assignedToText?.trim();
  if (assignedText != null && assignedText.isNotEmpty) {
    parts.add(assignedText);
  }

  return parts.isEmpty ? 'Unassigned' : parts.join(' / ');
}

bool _isOverdue(CheckoutRecord record) {
  final dueAt = record.dueAt;
  if (dueAt == null) {
    return false;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return dueAt.isBefore(today);
}

String? _personNameById(AppStore store, String personId) {
  for (final person in store.people) {
    if (person.id == personId) {
      return person.displayName;
    }
  }

  return null;
}

UnitOfMeasure? _unitById(AppStore store, String unitId) {
  for (final unit in store.unitsOfMeasure) {
    if (unit.id == unitId) {
      return unit;
    }
  }

  return null;
}

String? _locationNameById(AppStore store, String locationId) {
  for (final location in store.locations) {
    if (location.id == locationId) {
      return location.name;
    }
  }

  return null;
}

String? _emptyToNull(String value) {
  final trimmedValue = value.trim();
  return trimmedValue.isEmpty ? null : trimmedValue;
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }

  return quantity.toStringAsFixed(2);
}
