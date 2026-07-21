import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/app_store.dart';
import '../core/items/item_type_help.dart';
import '../core/labels/label_service.dart';
import '../core/models/models.dart';
import '../core/photos/item_photo_service.dart';
import '../theme/issued_theme.dart';
import '../widgets/issued_status_badge.dart';
import 'activity_screen.dart';
import 'edit_item_screen.dart';
import 'label_center_screen.dart';
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
    final checkedOutQuantity = openCheckouts.fold<double>(
      0,
      (total, record) => total + record.quantityOpen,
    );
    final positiveLocationCount = store
        .itemBalancesForItem(_item.id)
        .where((balance) => balance.quantityOnHand > 0)
        .length;
    final locationCount = positiveLocationCount == 0 && _item.quantityOnHand > 0
        ? 1
        : positiveLocationCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Detail'),
        actions: [
          if (permissions.canManageItems)
            IconButton(
              tooltip: 'Edit item',
              onPressed: _openEditItem,
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
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
                  if ((_item.sku ?? '').isNotEmpty ||
                      (_item.barcode ?? '').isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      [
                        if ((_item.sku ?? '').isNotEmpty) 'SKU ${_item.sku}',
                        if ((_item.barcode ?? '').isNotEmpty)
                          'Barcode ${_item.barcode}',
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      IssuedStatusBadge(
                        label: _itemTypeLabel(_item.itemType),
                        tone: IssuedStatusTone.info,
                      ),
                      _stockStatusBadge(store, openCheckouts),
                      if (checkedOutPerson != null)
                        IssuedStatusBadge(
                          label: 'Checked out to $checkedOutPerson',
                          tone: IssuedStatusTone.warning,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${itemTypeLabel(_item.itemType)} — '
                    '${itemTypeDetailDescription(_item.itemType)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ItemMetrics(
            item: _item,
            unit: unit,
            checkedOutQuantity: checkedOutQuantity,
            locationCount: locationCount,
          ),
          const SizedBox(height: 12),
          _PrimaryActionsCard(
            item: _item,
            showReturnableActions: showReturnableActions,
            canReceive: permissions.canReceiveStock,
            canIssue: permissions.canIssueItems,
            canAdjust: permissions.canAdjustQuantity,
            canEdit: permissions.canManageItems,
            onReceive: _receiveStock,
            onIssue: _issueItem,
            onCheckout: _checkOutItem,
            onReturn: _returnItem,
            onAdjust: _adjustQuantity,
            onEdit: _openEditItem,
          ),
          const SizedBox(height: 12),
          _StockByLocationCard(
            item: _item,
            store: store,
            canReceive: permissions.canReceiveStock,
            onReceive: _receiveStock,
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Item details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                    label: 'Stocking UOM',
                    value: unit == null
                        ? 'Unknown'
                        : '${unit.name} (${unit.abbreviation})',
                  ),
                  if (store.hasPurchaseConversion(_item)) ...[
                    _DetailRow(
                      label: 'Purchase UOM',
                      value:
                          '${store.getPurchaseUom(_item)?.name ?? 'Unknown'} (${store.getPurchaseUom(_item)?.abbreviation ?? _item.purchaseUnitLabel ?? ''})',
                    ),
                    _DetailRow(
                      label: 'Conversion',
                      value:
                          store.purchaseConversionPreview(_item) ?? 'Not set',
                    ),
                  ],
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
          _ItemCustomFieldsCard(
            item: _item,
            store: store,
            canEdit: permissions.canManageItems,
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
                        OutlinedButton.icon(
                          onPressed: _openLabelCenter,
                          icon: const Icon(Icons.qr_code_2),
                          label: const Text('Label Center'),
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
                    'More actions',
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
                      if (permissions.canTransferStock)
                        _ActionButton(
                          label: 'Transfer',
                          icon: Icons.swap_horiz,
                          onPressed: _transferItem,
                        ),
                      if (showReturnableActions) ...[
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.history_toggle_off_outlined),
                          SizedBox(width: 10),
                          Text('No activity yet.'),
                        ],
                      ),
                    )
                  else
                    for (final transaction in recentTransactions)
                      _TransactionRow(transaction: transaction),
                  if (recentTransactions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _openAllActivity,
                      icon: const Icon(Icons.history),
                      label: const Text('View All Activity'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockStatusBadge(AppStore store, List<CheckoutRecord> openCheckouts) {
    if (!_item.isActive) {
      return const IssuedStatusBadge(label: 'Inactive');
    }
    if (openCheckouts.isNotEmpty) {
      return const IssuedStatusBadge(
        label: 'Checked out',
        tone: IssuedStatusTone.warning,
      );
    }
    if (_item.quantityOnHand <= 0) {
      return const IssuedStatusBadge(
        label: 'Out of stock',
        tone: IssuedStatusTone.error,
      );
    }
    if (store.isItemLowStock(_item)) {
      return const IssuedStatusBadge(
        label: 'Low stock',
        tone: IssuedStatusTone.warning,
      );
    }
    return const IssuedStatusBadge(
      label: 'In stock',
      tone: IssuedStatusTone.success,
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

  Future<void> _openLabelCenter() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => LabelCenterScreen(
          initialMode: LabelCenterMode.items,
          initialItemIds: {_item.id},
        ),
      ),
    );
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

    final result = await showDialog<_LocationQuantityResult>(
      context: context,
      builder: (context) => _LocationQuantityDialog(
        title: 'Receive Stock',
        quantityLabel: 'Quantity received',
        store: store,
        item: _item,
        allowPurchaseMode: true,
      ),
    );

    if (result == null) {
      return;
    }

    final received = store.receiveItemToLocation(
      itemId: _item.id,
      locationId: result.locationId,
      quantity: result.quantity,
      notes: result.notes,
    );
    if (!received) {
      _showMessage('Could not receive stock.');
      return;
    }
    _syncCurrentItem(store);
  }

  Future<void> _issueItem() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canIssueItems) {
      _showPermissionDenied();
      return;
    }

    final result = await showDialog<_LocationQuantityResult>(
      context: context,
      builder: (context) => _LocationQuantityDialog(
        title: _item.itemType == ItemType.consumable
            ? 'Issue Stock'
            : 'Issue Item',
        quantityLabel: 'Quantity issued',
        store: store,
        item: _item,
        useStockLocationsOnly: true,
        allowAssignment: true,
      ),
    );

    if (result == null) {
      return;
    }

    final issued = store.issueItemFromLocation(
      itemId: _item.id,
      locationId: result.locationId,
      quantity: result.quantity,
      assignedToPersonId: result.assignedToPersonId,
      assignedToTargetId: result.assignedToTargetId,
      assignedToText: result.assignedToText,
      notes: result.notes,
    );
    if (!issued) {
      _showMessage('Not enough quantity at this location.');
      return;
    }
    _syncCurrentItem(store);
  }

  Future<void> _checkOutItem() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canIssueItems) {
      _showPermissionDenied();
      return;
    }

    final result = await showDialog<_CheckoutDialogResult>(
      context: context,
      builder: (context) => _CheckoutDialog(
        store: AppStoreScope.of(context),
        item: _item,
        initialQuantity: 1,
      ),
    );

    if (result == null) {
      return;
    }

    final checkedOut = store.checkOutItem(
      itemId: _item.id,
      quantity: result.quantity,
      sourceLocationId: result.sourceLocationId,
      assignedToPersonId: result.assignedToPersonId,
      assignedToLocationId: result.assignedToLocationId,
      assignedToTargetId: result.assignedToTargetId,
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

    final result = await showDialog<_LocationQuantityResult>(
      context: context,
      builder: (context) => _LocationQuantityDialog(
        title: 'Return Checked Out Item',
        quantityLabel: 'Quantity returned',
        store: store,
        item: _item,
        initialQuantity: record.quantityOpen,
        initialLocationId: record.assignedToLocationId,
      ),
    );

    if (result == null) {
      return;
    }

    if (result.quantity > record.quantityOpen) {
      _showMessage('Return quantity cannot exceed open quantity.');
      return;
    }

    final returned = store.returnCheckout(
      checkoutRecordId: record.id,
      returnedQuantity: result.quantity,
      returnToLocationId: result.locationId,
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
        item: _item,
        store: AppStoreScope.of(context),
      ),
    );

    if (result == null) {
      return;
    }

    final transferred = store.transferItemBetweenLocations(
      itemId: _item.id,
      fromLocationId: result.fromLocationId,
      toLocationId: result.toLocationId,
      quantity: result.quantity,
      notes: result.notes,
    );
    if (!transferred) {
      _showMessage('Not enough quantity at this location.');
      return;
    }
    _syncCurrentItem(store);
  }

  Future<void> _adjustQuantity() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canAdjustQuantity) {
      _showPermissionDenied();
      return;
    }

    final result = await showDialog<_AdjustLocationResult>(
      context: context,
      builder: (context) => _AdjustLocationDialog(store: store, item: _item),
    );

    if (result == null) {
      return;
    }

    final adjusted = store.adjustItemQuantityAtLocation(
      itemId: _item.id,
      locationId: result.locationId,
      quantity: result.quantity,
      setQuantity: result.setQuantity,
      notes: result.notes,
    );
    if (!adjusted) {
      _showMessage('Could not adjust quantity at this location.');
      return;
    }
    _syncCurrentItem(store);
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

    final result = await showDialog<_LocationQuantityResult>(
      context: context,
      builder: (context) => _LocationQuantityDialog(
        title: 'Mark Lost/Damaged',
        quantityLabel: 'Quantity lost/damaged',
        store: store,
        item: _item,
        initialQuantity: 1,
        useStockLocationsOnly: true,
      ),
    );

    if (result == null) {
      return;
    }

    final marked = store.markItemDamagedAtLocation(
      itemId: _item.id,
      locationId: result.locationId,
      quantity: result.quantity,
      notes: result.notes,
    );
    if (!marked) {
      _showMessage('Not enough quantity at this location.');
      return;
    }
    _syncCurrentItem(store);
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
      final result = store.archiveItem(_item.id);
      if (!result.success) {
        _showMessage(result.message ?? 'Could not archive item.');
        return;
      }
      _syncCurrentItem(store);
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

    final result = store.unarchiveItem(_item.id);
    if (!result.success) {
      _showMessage(result.message ?? 'Could not unarchive item.');
      return;
    }
    _syncCurrentItem(store);
  }

  void _applyItemUpdate(Item updatedItem) {
    final store = AppStoreScope.of(context);
    final result = store.updateItem(updatedItem);
    if (!result.success) {
      _showMessage(result.message ?? 'Could not update item.');
      return;
    }

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

  void _showPermissionDenied() {
    _showMessage('Your current role does not allow this action.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<InventoryTransaction> _recentTransactions(AppStore store) {
    return store.transactionsForItem(_item.id).take(5).toList();
  }

  void _openAllActivity() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ActivityScreen(itemId: _item.id),
      ),
    );
  }

  Future<void> _openEditItem() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageItems) {
      _showPermissionDenied();
      return;
    }

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => EditItemScreen(item: _item),
      ),
    );
    if (changed == true && mounted) {
      _syncCurrentItem(store);
    }
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
    return itemTypeLabel(type);
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
                      style: issuedDestructiveOutlinedButtonStyle(context),
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
    required this.sourceLocationId,
    required this.assignedToPersonId,
    required this.assignedToLocationId,
    required this.assignedToTargetId,
    required this.assignedToText,
    required this.dueAt,
    required this.notes,
  });

  final double quantity;
  final String sourceLocationId;
  final String? assignedToPersonId;
  final String? assignedToLocationId;
  final String? assignedToTargetId;
  final String? assignedToText;
  final DateTime? dueAt;
  final String? notes;
}

class _CheckoutDialog extends StatefulWidget {
  const _CheckoutDialog({
    required this.store,
    required this.item,
    required this.initialQuantity,
  });

  final AppStore store;
  final Item item;
  final double initialQuantity;

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _assignedTextController;
  late final TextEditingController _notesController;
  AssignableDestination? _assignedDestination;
  String? _sourceLocationId;
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
    final sourceLocations = widget.store
        .itemBalancesForItem(widget.item.id)
        .where((balance) => balance.quantityOnHand > 0)
        .toList();
    _sourceLocationId ??= sourceLocations.isNotEmpty
        ? sourceLocations.first.locationId
        : null;

    return AlertDialog(
      title: Text(
        widget.item.itemType == ItemType.asset
            ? 'Check Out Asset'
            : 'Check Out Returnable',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.item.itemType == ItemType.asset
                    ? 'This exact asset will stay assigned until it is returned.'
                    : 'This item is expected to be returned.',
              ),
              const SizedBox(height: 12),
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
              if (sourceLocations.isEmpty)
                const Text('No stock is available to check out.')
              else
                DropdownButtonFormField<String>(
                  initialValue: _sourceLocationId,
                  decoration: const InputDecoration(
                    labelText: 'Source location',
                  ),
                  items: [
                    for (final balance in sourceLocations)
                      DropdownMenuItem<String>(
                        value: balance.locationId,
                        child: Text(
                          '${widget.store.resolveLocationName(balance.locationId) ?? 'Unknown'} (${_formatQuantity(balance.quantityOnHand)})',
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sourceLocationId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Choose a source location.' : null,
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AssignableDestination?>(
                initialValue: _assignedDestination,
                decoration: const InputDecoration(labelText: 'Assign To'),
                items: [
                  const DropdownMenuItem<AssignableDestination?>(
                    value: null,
                    child: Text('No assignment'),
                  ),
                  for (final destination
                      in widget.store.getAssignableDestinations())
                    DropdownMenuItem<AssignableDestination?>(
                      value: destination,
                      child: Text(
                        '${destination.displayName} (${destination.subtitle ?? 'Target'})',
                      ),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _assignedDestination = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _assignedTextController,
                decoration: const InputDecoration(
                  labelText: 'Other assignment optional',
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
    if (_sourceLocationId == null) {
      return;
    }

    final assignedText = _assignedTextController.text.trim();
    final notes = _notesController.text.trim();
    Navigator.of(context).pop(
      _CheckoutDialogResult(
        quantity: double.parse(_quantityController.text.trim()),
        sourceLocationId: _sourceLocationId!,
        assignedToPersonId:
            _assignedDestination?.type == AssignableDestinationType.person
            ? _assignedDestination?.id
            : null,
        assignedToLocationId:
            _assignedDestination?.type == AssignableDestinationType.location
            ? _assignedDestination?.id
            : null,
        assignedToTargetId:
            _assignedDestination?.type ==
                AssignableDestinationType.assignmentTarget
            ? _assignedDestination?.id
            : null,
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

class _ItemMetrics extends StatelessWidget {
  const _ItemMetrics({
    required this.item,
    required this.unit,
    required this.checkedOutQuantity,
    required this.locationCount,
  });

  final Item item;
  final UnitOfMeasure? unit;
  final double checkedOutQuantity;
  final int locationCount;

  @override
  Widget build(BuildContext context) {
    final abbreviation = unit?.abbreviation ?? '';
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MetricTile(
              width: width,
              label: 'On hand',
              value: '${_formatQuantity(item.quantityOnHand)} $abbreviation'
                  .trim(),
              icon: Icons.inventory_2_outlined,
            ),
            _MetricTile(
              width: width,
              label: 'Minimum',
              value: '${_formatQuantity(item.minimumQuantity)} $abbreviation'
                  .trim(),
              icon: Icons.vertical_align_bottom_outlined,
            ),
            if (item.itemType != ItemType.consumable)
              _MetricTile(
                width: width,
                label: 'Checked out',
                value: '${_formatQuantity(checkedOutQuantity)} $abbreviation'
                    .trim(),
                icon: Icons.assignment_ind_outlined,
              ),
            _MetricTile(
              width: width,
              label: 'Stock locations',
              value: '$locationCount',
              icon: Icons.location_on_outlined,
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
  });

  final double width;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionsCard extends StatelessWidget {
  const _PrimaryActionsCard({
    required this.item,
    required this.showReturnableActions,
    required this.canReceive,
    required this.canIssue,
    required this.canAdjust,
    required this.canEdit,
    required this.onReceive,
    required this.onIssue,
    required this.onCheckout,
    required this.onReturn,
    required this.onAdjust,
    required this.onEdit,
  });

  final Item item;
  final bool showReturnableActions;
  final bool canReceive;
  final bool canIssue;
  final bool canAdjust;
  final bool canEdit;
  final VoidCallback onReceive;
  final VoidCallback onIssue;
  final VoidCallback onCheckout;
  final VoidCallback onReturn;
  final VoidCallback onAdjust;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    if (!canReceive && !canIssue && !canAdjust && !canEdit) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Your role can view this item but cannot make changes.'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock actions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (canReceive)
                  FilledButton.icon(
                    onPressed: onReceive,
                    icon: const Icon(Icons.add_box_outlined),
                    label: const Text('Receive stock'),
                  ),
                if (canIssue)
                  OutlinedButton.icon(
                    onPressed: onIssue,
                    icon: const Icon(Icons.call_made),
                    label: Text(
                      item.itemType == ItemType.consumable
                          ? 'Issue stock'
                          : 'Issue item',
                    ),
                  ),
                if (canIssue && showReturnableActions)
                  OutlinedButton.icon(
                    onPressed: onCheckout,
                    icon: const Icon(Icons.assignment_ind_outlined),
                    label: Text(
                      item.itemType == ItemType.asset
                          ? 'Check out asset'
                          : 'Check out',
                    ),
                  ),
                if (canIssue && showReturnableActions)
                  OutlinedButton.icon(
                    onPressed: onReturn,
                    icon: const Icon(Icons.assignment_return_outlined),
                    label: const Text('Return item'),
                  ),
                if (canAdjust)
                  OutlinedButton.icon(
                    onPressed: onAdjust,
                    icon: const Icon(Icons.tune),
                    label: const Text('Adjust'),
                  ),
                if (canEdit)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit item'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StockByLocationCard extends StatelessWidget {
  const _StockByLocationCard({
    required this.item,
    required this.store,
    required this.canReceive,
    required this.onReceive,
  });

  final Item item;
  final AppStore store;
  final bool canReceive;
  final VoidCallback onReceive;

  @override
  Widget build(BuildContext context) {
    final unit = _unitById(store, item.unitOfMeasureId);
    final balances = store.itemBalancesForItem(item.id);
    final rows = balances.isNotEmpty
        ? balances
        : [
            ItemLocationBalance(
              id: 'display-${item.id}-${item.locationId}',
              itemId: item.id,
              locationId: item.locationId,
              quantityOnHand: item.quantityOnHand,
              minimumQuantity: 0,
              updatedAt: item.updatedAt,
            ),
          ];
    final total = store.totalQuantityForItem(item.id);
    final totalQuantity = balances.isEmpty ? item.quantityOnHand : total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Stock by location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF17212F),
                    ),
                  ),
                ),
                Text(
                  '${_formatQuantity(totalQuantity)} ${unit?.abbreviation ?? ''}'
                      .trim(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17212F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (totalQuantity <= 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No stock received yet',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Receive stock to make this item available.'),
                    if (canReceive) ...[
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: onReceive,
                        icon: const Icon(Icons.add_box_outlined),
                        label: const Text('Receive stock'),
                      ),
                    ],
                  ],
                ),
              )
            else
              for (final balance in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.resolveLocationName(balance.locationId) ??
                              'Unknown location',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '${_formatQuantity(balance.quantityOnHand)} ${unit?.abbreviation ?? ''}'
                            .trim(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IssuedStatusBadge(
                        label: balance.quantityOnHand <= 0
                            ? 'Out'
                            : balance.quantityOnHand <= balance.minimumQuantity
                            ? 'Low'
                            : 'Available',
                        tone: balance.quantityOnHand <= 0
                            ? IssuedStatusTone.error
                            : balance.quantityOnHand <= balance.minimumQuantity
                            ? IssuedStatusTone.warning
                            : IssuedStatusTone.success,
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _LocationQuantityResult {
  const _LocationQuantityResult({
    required this.locationId,
    required this.quantity,
    required this.assignedToPersonId,
    required this.assignedToTargetId,
    required this.assignedToText,
    required this.notes,
  });

  final String locationId;
  final double quantity;
  final String? assignedToPersonId;
  final String? assignedToTargetId;
  final String? assignedToText;
  final String? notes;
}

class _LocationQuantityDialog extends StatefulWidget {
  const _LocationQuantityDialog({
    required this.title,
    required this.quantityLabel,
    required this.store,
    required this.item,
    this.initialQuantity = 1,
    this.initialLocationId,
    this.useStockLocationsOnly = false,
    this.allowPurchaseMode = false,
    this.allowAssignment = false,
  });

  final String title;
  final String quantityLabel;
  final AppStore store;
  final Item item;
  final double initialQuantity;
  final String? initialLocationId;
  final bool useStockLocationsOnly;
  final bool allowPurchaseMode;
  final bool allowAssignment;

  @override
  State<_LocationQuantityDialog> createState() =>
      _LocationQuantityDialogState();
}

class _LocationQuantityDialogState extends State<_LocationQuantityDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _assignedTextController;
  late final TextEditingController _notesController;
  String? _locationId;
  AssignableDestination? _assignedDestination;
  bool? _receiveByPurchase;

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
    final locations = _locationOptions();
    final canUsePurchase =
        widget.allowPurchaseMode &&
        widget.store.hasPurchaseConversion(widget.item);
    _receiveByPurchase ??= canUsePurchase;
    if (locations.isNotEmpty &&
        (_locationId == null ||
            !locations.any((location) => location.id == _locationId))) {
      _locationId =
          widget.initialLocationId != null &&
              locations.any(
                (location) => location.id == widget.initialLocationId,
              )
          ? widget.initialLocationId
          : locations.first.id;
    }

    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withAlpha(70),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _actionHelperText(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (locations.isEmpty)
                const Text('Add a location before changing stock.')
              else
                DropdownButtonFormField<String>(
                  initialValue: _locationId,
                  decoration: const InputDecoration(labelText: 'Location'),
                  items: [
                    for (final location in locations)
                      DropdownMenuItem<String>(
                        value: location.id,
                        child: Text(_locationLabel(location.id)),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _locationId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Choose a location.' : null,
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: _quantityLabel(canUsePurchase),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _quantityValidator,
                onChanged: (_) => setState(() {}),
              ),
              if (canUsePurchase) ...[
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text(
                        'Receive by ${widget.store.getStockUom(widget.item)?.abbreviation ?? 'stock'}',
                      ),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text(
                        'Receive by ${widget.store.getPurchaseUom(widget.item)?.abbreviation ?? 'purchase'}',
                      ),
                    ),
                  ],
                  selected: {_receiveByPurchase ?? false},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _receiveByPurchase = selection.first;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_receivePreview()),
                ),
              ],
              if (widget.allowAssignment) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<AssignableDestination?>(
                  initialValue: _assignedDestination,
                  decoration: const InputDecoration(labelText: 'Assign To'),
                  items: [
                    const DropdownMenuItem<AssignableDestination?>(
                      value: null,
                      child: Text('No assignment'),
                    ),
                    for (final destination
                        in widget.store.getAssignableDestinations())
                      DropdownMenuItem<AssignableDestination?>(
                        value: destination,
                        child: Text(
                          '${destination.displayName} (${destination.subtitle ?? 'Target'})',
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() => _assignedDestination = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _assignedTextController,
                  decoration: const InputDecoration(
                    labelText: 'Other assignment optional',
                  ),
                ),
              ],
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
        FilledButton(
          onPressed: locations.isEmpty ? null : _submit,
          child: Text(_actionButtonLabel()),
        ),
      ],
    );
  }

  List<Location> _locationOptions() {
    if (!widget.useStockLocationsOnly) {
      return widget.store.locations
          .where((location) => location.isActive)
          .toList();
    }

    final ids = widget.store
        .itemBalancesForItem(widget.item.id)
        .where((balance) => balance.quantityOnHand > 0)
        .map((balance) => balance.locationId)
        .toSet();
    return widget.store.locations
        .where((location) => location.isActive && ids.contains(location.id))
        .toList();
  }

  String _actionHelperText() {
    final title = widget.title.toLowerCase();
    if (title.contains('receive')) {
      return 'Adds quantity to the selected location.';
    }
    if (title.contains('issue')) {
      return widget.item.itemType == ItemType.consumable
          ? 'Reduces stock. Consumables are not expected back.'
          : 'Reduces stock at the selected location.';
    }
    if (title.contains('adjust')) {
      return 'Use adjustments to correct counts.';
    }
    if (title.contains('return')) {
      return 'Adds the checked-out quantity back to available stock.';
    }
    return 'Update stock at the selected location.';
  }

  String _actionButtonLabel() {
    final title = widget.title.toLowerCase();
    if (title.contains('receive')) return 'Receive stock';
    if (title.contains('issue')) return 'Issue stock';
    if (title.contains('adjust')) return 'Save adjustment';
    if (title.contains('return')) return 'Return item';
    return 'Save';
  }

  String _locationLabel(String locationId) {
    final name =
        widget.store.resolveLocationName(locationId) ?? 'Unknown location';
    ItemLocationBalance? balance;
    for (final itemBalance in widget.store.itemBalancesForItem(
      widget.item.id,
    )) {
      if (itemBalance.locationId == locationId) {
        balance = itemBalance;
        break;
      }
    }
    if (balance == null) {
      return name;
    }
    final unit = widget.store.resolveUomAbbreviation(
      widget.item.unitOfMeasureId,
    );
    return '$name (${_formatQuantity(balance.quantityOnHand)} $unit)'.trim();
  }

  String? _quantityValidator(String? value) {
    final quantity = double.tryParse(value?.trim() ?? '');
    if (quantity == null || quantity <= 0) {
      return 'Enter a quantity greater than 0.';
    }
    if (_receiveByPurchase == true) {
      return widget.store.validatePurchaseReceiveQuantity(
        widget.item,
        quantity,
      );
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _locationId == null) {
      return;
    }

    Navigator.of(context).pop(
      _LocationQuantityResult(
        locationId: _locationId!,
        quantity: _stockQuantity(),
        assignedToPersonId:
            _assignedDestination?.type == AssignableDestinationType.person
            ? _assignedDestination?.id
            : null,
        assignedToTargetId:
            _assignedDestination?.type ==
                AssignableDestinationType.assignmentTarget
            ? _assignedDestination?.id
            : null,
        assignedToText: _assignmentText(),
        notes: _combinedNotes(),
      ),
    );
  }

  String? _assignmentText() {
    final freeText = _emptyToNull(_assignedTextController.text);
    final destination = _assignedDestination;
    if (destination?.type == AssignableDestinationType.location) {
      final locationText = 'Location: ${destination!.displayName}';
      return freeText == null ? locationText : '$locationText / $freeText';
    }
    return freeText;
  }

  String _quantityLabel(bool canUsePurchase) {
    if (canUsePurchase && _receiveByPurchase == true) {
      final unit = widget.store.getPurchaseUom(widget.item);
      return 'Quantity received (${unit?.abbreviation ?? 'purchase UOM'})';
    }
    return widget.quantityLabel;
  }

  double _enteredQuantity() {
    return double.tryParse(_quantityController.text.trim()) ?? 0;
  }

  double _stockQuantity() {
    final quantity = _enteredQuantity();
    if (_receiveByPurchase == true) {
      return widget.store.convertPurchaseToStock(widget.item, quantity);
    }
    return quantity;
  }

  String _receivePreview() {
    final locationName =
        widget.store.resolveLocationName(_locationId) ?? 'selected location';
    final stockQuantity = _stockQuantity();
    return 'This will add ${widget.store.formatStockQuantity(widget.item, stockQuantity)} to $locationName.';
  }

  String? _combinedNotes() {
    final notes = _emptyToNull(_notesController.text);
    if (_receiveByPurchase != true) {
      return notes;
    }
    final conversionNote =
        'Received ${widget.store.formatPurchaseQuantity(widget.item, _enteredQuantity())} = ${widget.store.formatStockQuantity(widget.item, _stockQuantity())}.';
    if (notes == null) {
      return conversionNote;
    }
    return '$conversionNote $notes';
  }
}

class _AdjustLocationResult {
  const _AdjustLocationResult({
    required this.locationId,
    required this.quantity,
    required this.setQuantity,
    required this.notes,
  });

  final String locationId;
  final double quantity;
  final bool setQuantity;
  final String? notes;
}

class _AdjustLocationDialog extends StatefulWidget {
  const _AdjustLocationDialog({required this.store, required this.item});

  final AppStore store;
  final Item item;

  @override
  State<_AdjustLocationDialog> createState() => _AdjustLocationDialogState();
}

class _AdjustLocationDialogState extends State<_AdjustLocationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  String? _locationId;
  bool _setQuantity = true;

  @override
  void initState() {
    super.initState();
    final primary = widget.store.primaryLocationForItem(widget.item.id);
    _locationId = primary?.id ?? widget.item.locationId;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locations = widget.store.locations
        .where((location) => location.isActive)
        .toList();
    if (locations.isNotEmpty &&
        (_locationId == null ||
            !locations.any((location) => location.id == _locationId))) {
      _locationId = locations.first.id;
    }

    return AlertDialog(
      title: const Text('Adjust Quantity'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (locations.isEmpty)
                const Text('Add a location before changing stock.')
              else
                DropdownButtonFormField<String>(
                  initialValue: _locationId,
                  decoration: const InputDecoration(labelText: 'Location'),
                  items: [
                    for (final location in locations)
                      DropdownMenuItem<String>(
                        value: location.id,
                        child: Text(location.name),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _locationId = value;
                    });
                  },
                ),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Set')),
                  ButtonSegment(value: false, label: Text('Add/Subtract')),
                ],
                selected: {_setQuantity},
                onSelectionChanged: (selection) {
                  setState(() {
                    _setQuantity = selection.first;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: _setQuantity
                      ? 'New quantity at location'
                      : 'Quantity change',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (value) {
                  final quantity = double.tryParse(value?.trim() ?? '');
                  if (quantity == null) {
                    return 'Enter a valid number.';
                  }
                  if (_setQuantity && quantity < 0) {
                    return 'Enter zero or greater.';
                  }
                  if (!_setQuantity && quantity == 0) {
                    return 'Enter a non-zero change.';
                  }
                  return null;
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: locations.isEmpty ? null : _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _locationId == null) {
      return;
    }

    Navigator.of(context).pop(
      _AdjustLocationResult(
        locationId: _locationId!,
        quantity: double.parse(_quantityController.text.trim()),
        setQuantity: _setQuantity,
        notes: _emptyToNull(_notesController.text),
      ),
    );
  }
}

enum _PhotoLimitAction { cancel, viewPlan, upgrade }

class _ItemCustomFieldsCard extends StatefulWidget {
  const _ItemCustomFieldsCard({
    required this.item,
    required this.store,
    required this.canEdit,
  });

  final Item item;
  final AppStore store;
  final bool canEdit;

  @override
  State<_ItemCustomFieldsCard> createState() => _ItemCustomFieldsCardState();
}

class _ItemCustomFieldsCardState extends State<_ItemCustomFieldsCard> {
  @override
  Widget build(BuildContext context) {
    final fields = widget.store.activeCustomFieldsForItem(widget.item);
    if (fields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Custom Fields',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF17212F),
                    ),
                  ),
                ),
                if (widget.canEdit)
                  OutlinedButton(
                    onPressed: _editValues,
                    child: const Text('Edit'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (final field in fields)
              _DetailRow(
                label: field.name,
                value: _customValueText(
                  field,
                  widget.store.getCustomFieldValue(field.id, widget.item.id),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editValues() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _EditCustomFieldValuesDialog(item: widget.item, store: widget.store),
    );
    if (changed == true && mounted) {
      setState(() {});
    }
  }
}

class _EditCustomFieldValuesDialog extends StatefulWidget {
  const _EditCustomFieldValuesDialog({required this.item, required this.store});

  final Item item;
  final AppStore store;

  @override
  State<_EditCustomFieldValuesDialog> createState() =>
      _EditCustomFieldValuesDialogState();
}

class _EditCustomFieldValuesDialogState
    extends State<_EditCustomFieldValuesDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, bool> _boolValues = {};
  final Map<String, DateTime?> _dateValues = {};
  final Map<String, String?> _selectValues = {};

  @override
  void initState() {
    super.initState();
    for (final field in widget.store.activeCustomFieldsForItem(widget.item)) {
      final value = widget.store.getCustomFieldValue(field.id, widget.item.id);
      switch (field.fieldType) {
        case CustomFieldType.text:
          _textControllers[field.id] = TextEditingController(
            text: value?.textValue ?? '',
          );
        case CustomFieldType.number:
          _textControllers[field.id] = TextEditingController(
            text: value?.numberValue?.toString() ?? '',
          );
        case CustomFieldType.date:
          _dateValues[field.id] = value?.dateValue;
        case CustomFieldType.boolean:
          _boolValues[field.id] = value?.booleanValue ?? false;
        case CustomFieldType.select:
          _selectValues[field.id] = value?.selectedOption;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.store.activeCustomFieldsForItem(widget.item);
    return AlertDialog(
      title: const Text('Edit Custom Fields'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final field in fields) ...[
                _fieldControl(context, field),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Widget _fieldControl(BuildContext context, CustomFieldDefinition field) {
    return switch (field.fieldType) {
      CustomFieldType.text || CustomFieldType.number => TextFormField(
        controller: _textControllers[field.id],
        decoration: InputDecoration(labelText: field.name),
        keyboardType: field.fieldType == CustomFieldType.number
            ? const TextInputType.numberWithOptions(decimal: true)
            : null,
        validator: (value) {
          if (field.isRequired && (value == null || value.trim().isEmpty)) {
            return 'Required';
          }
          if (field.fieldType == CustomFieldType.number &&
              (value ?? '').trim().isNotEmpty &&
              double.tryParse(value!.trim()) == null) {
            return 'Enter a valid number';
          }
          return null;
        },
      ),
      CustomFieldType.date => OutlinedButton.icon(
        onPressed: () async {
          final now = DateTime.now();
          final date = await showDatePicker(
            context: context,
            firstDate: DateTime(now.year - 20),
            lastDate: DateTime(now.year + 50),
            initialDate: _dateValues[field.id] ?? now,
          );
          if (date == null) {
            return;
          }
          setState(() {
            _dateValues[field.id] = date;
          });
        },
        icon: const Icon(Icons.event),
        label: Text(
          _dateValues[field.id] == null
              ? field.name
              : '${field.name}: ${_formatDate(_dateValues[field.id]!)}',
        ),
      ),
      CustomFieldType.boolean => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(field.name),
        value: _boolValues[field.id] ?? false,
        onChanged: (value) => setState(() => _boolValues[field.id] = value),
      ),
      CustomFieldType.select => DropdownButtonFormField<String>(
        initialValue: _selectValues[field.id],
        decoration: InputDecoration(labelText: field.name),
        items: field.options
            .map(
              (option) => DropdownMenuItem(value: option, child: Text(option)),
            )
            .toList(),
        onChanged: (value) => _selectValues[field.id] = value,
        validator: (value) {
          if (field.isRequired && (value == null || value.isEmpty)) {
            return 'Required';
          }
          return null;
        },
      ),
    };
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final now = DateTime.now();
    for (final field in widget.store.activeCustomFieldsForItem(widget.item)) {
      final value = _valueForField(field, widget.item.id, now);
      final existing = widget.store.getCustomFieldValue(
        field.id,
        widget.item.id,
      );
      if (value == null) {
        if (existing != null) {
          widget.store.deleteCustomFieldValue(existing.id);
        }
      } else {
        widget.store.setCustomFieldValue(value);
      }
    }
    Navigator.of(context).pop(true);
  }

  CustomFieldValue? _valueForField(
    CustomFieldDefinition field,
    String itemId,
    DateTime now,
  ) {
    final id =
        widget.store.getCustomFieldValue(field.id, itemId)?.id ??
        'cfv-${field.id}-$itemId';
    return switch (field.fieldType) {
      CustomFieldType.text =>
        (_textControllers[field.id]?.text.trim() ?? '').isEmpty
            ? null
            : CustomFieldValue(
                id: id,
                definitionId: field.id,
                entityId: itemId,
                textValue: _textControllers[field.id]!.text.trim(),
                numberValue: null,
                dateValue: null,
                booleanValue: null,
                selectedOption: null,
              ),
      CustomFieldType.number =>
        (_textControllers[field.id]?.text.trim() ?? '').isEmpty
            ? null
            : CustomFieldValue(
                id: id,
                definitionId: field.id,
                entityId: itemId,
                textValue: null,
                numberValue: double.parse(
                  _textControllers[field.id]!.text.trim(),
                ),
                dateValue: null,
                booleanValue: null,
                selectedOption: null,
              ),
      CustomFieldType.date =>
        _dateValues[field.id] == null
            ? null
            : CustomFieldValue(
                id: id,
                definitionId: field.id,
                entityId: itemId,
                textValue: null,
                numberValue: null,
                dateValue: _dateValues[field.id],
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
        booleanValue: _boolValues[field.id] ?? false,
        selectedOption: null,
      ),
      CustomFieldType.select =>
        _selectValues[field.id] == null
            ? null
            : CustomFieldValue(
                id: id,
                definitionId: field.id,
                entityId: itemId,
                textValue: null,
                numberValue: null,
                dateValue: null,
                booleanValue: null,
                selectedOption: _selectValues[field.id],
              ),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _TransferDialog extends StatefulWidget {
  const _TransferDialog({
    required this.currentLocationId,
    required this.item,
    required this.store,
  });

  final String currentLocationId;
  final Item item;
  final AppStore store;

  @override
  State<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<_TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  late String _fromLocationId;
  late String _toLocationId;

  @override
  void initState() {
    super.initState();
    final sourceBalances = widget.store
        .itemBalancesForItem(widget.item.id)
        .where((balance) => balance.quantityOnHand > 0)
        .toList();
    _fromLocationId = sourceBalances.isNotEmpty
        ? sourceBalances.first.locationId
        : widget.currentLocationId;
    _toLocationId = _fromLocationId;
    for (final location in widget.store.locations) {
      if (location.id != _fromLocationId) {
        _toLocationId = location.id;
        break;
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockLocationIds = widget.store
        .itemBalancesForItem(widget.item.id)
        .where((balance) => balance.quantityOnHand > 0)
        .map((balance) => balance.locationId)
        .toSet();
    final fromLocations = widget.store.locations
        .where(
          (location) =>
              location.isActive && stockLocationIds.contains(location.id),
        )
        .toList();
    final toLocations = widget.store.locations
        .where((location) => location.isActive)
        .toList();

    return AlertDialog(
      title: const Text('Transfer Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (fromLocations.isEmpty || toLocations.length < 2)
                const Text('Create another location before transferring stock.')
              else ...[
                DropdownButtonFormField<String>(
                  initialValue: _fromLocationId,
                  decoration: const InputDecoration(labelText: 'From location'),
                  items: [
                    for (final location in fromLocations)
                      DropdownMenuItem<String>(
                        value: location.id,
                        child: Text(_transferLocationLabel(location.id)),
                      ),
                  ],
                  onChanged: (locationId) {
                    if (locationId == null) {
                      return;
                    }
                    setState(() {
                      _fromLocationId = locationId;
                      if (_toLocationId == _fromLocationId) {
                        _toLocationId = toLocations
                            .where((location) => location.id != _fromLocationId)
                            .map((location) => location.id)
                            .first;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _toLocationId == _fromLocationId
                      ? null
                      : _toLocationId,
                  decoration: const InputDecoration(labelText: 'To location'),
                  items: [
                    for (final location in toLocations)
                      if (location.id != _fromLocationId)
                        DropdownMenuItem<String>(
                          value: location.id,
                          child: Text(location.name),
                        ),
                  ],
                  onChanged: (locationId) {
                    if (locationId == null) {
                      return;
                    }
                    setState(() {
                      _toLocationId = locationId;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Choose a destination.' : null,
                ),
                const SizedBox(height: 12),
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
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes optional',
                  ),
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: fromLocations.isEmpty || toLocations.length < 2
              ? null
              : _submit,
          child: const Text('Transfer'),
        ),
      ],
    );
  }

  String _transferLocationLabel(String locationId) {
    final name =
        widget.store.resolveLocationName(locationId) ?? 'Unknown location';
    ItemLocationBalance? balance;
    for (final itemBalance in widget.store.itemBalancesForItem(
      widget.item.id,
    )) {
      if (itemBalance.locationId == locationId) {
        balance = itemBalance;
        break;
      }
    }
    final unit = widget.store.resolveUomAbbreviation(
      widget.item.unitOfMeasureId,
    );
    if (balance == null) {
      return name;
    }
    return '$name (${_formatQuantity(balance.quantityOnHand)} $unit)'.trim();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      _TransferResult(
        fromLocationId: _fromLocationId,
        toLocationId: _toLocationId,
        quantity: double.parse(_quantityController.text.trim()),
        notes: _emptyToNull(_notesController.text),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2F6),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                _transactionIcon(transaction.transactionType),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_transactionLabel(transaction.transactionType)} · $quantityText',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF17212F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.notes?.isEmpty ?? true
                      ? _formatDate(transaction.createdAt)
                      : '${_formatDate(transaction.createdAt)} · ${transaction.notes}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5C6672),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _transactionLabel(InventoryTransactionType type) {
    return switch (type) {
      InventoryTransactionType.receive => 'Received',
      InventoryTransactionType.issue => 'Issued',
      InventoryTransactionType.checkout => 'Checked out',
      InventoryTransactionType.returnItem => 'Returned',
      InventoryTransactionType.transfer => 'Transferred',
      InventoryTransactionType.adjustment => 'Adjusted',
      InventoryTransactionType.markLost => 'Lost',
      InventoryTransactionType.markDamaged => 'Lost/Damaged',
      InventoryTransactionType.cycleCountAdjustment => 'Cycle Count',
      InventoryTransactionType.correction => 'Correction',
    };
  }

  IconData _transactionIcon(InventoryTransactionType type) {
    return switch (type) {
      InventoryTransactionType.receive => Icons.add_box_outlined,
      InventoryTransactionType.issue => Icons.call_made,
      InventoryTransactionType.checkout => Icons.assignment_ind_outlined,
      InventoryTransactionType.returnItem => Icons.assignment_return_outlined,
      InventoryTransactionType.transfer => Icons.swap_horiz,
      InventoryTransactionType.adjustment ||
      InventoryTransactionType.cycleCountAdjustment ||
      InventoryTransactionType.correction => Icons.tune,
      InventoryTransactionType.markLost ||
      InventoryTransactionType.markDamaged => Icons.report_problem_outlined,
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

class _TransferResult {
  const _TransferResult({
    required this.fromLocationId,
    required this.toLocationId,
    required this.quantity,
    required this.notes,
  });

  final String fromLocationId;
  final String toLocationId;
  final double quantity;
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

  final targetId = record.assignedToTargetId;
  if (targetId != null) {
    parts.add(store.resolveAssignmentTargetName(targetId) ?? 'Unknown target');
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

String _customValueText(CustomFieldDefinition field, CustomFieldValue? value) {
  if (value == null) {
    return field.isRequired ? 'Not set' : '';
  }
  return switch (field.fieldType) {
    CustomFieldType.text => value.textValue ?? '',
    CustomFieldType.number => value.numberValue?.toString() ?? '',
    CustomFieldType.date =>
      value.dateValue == null
          ? ''
          : '${value.dateValue!.month}/${value.dateValue!.day}/${value.dateValue!.year}',
    CustomFieldType.boolean => value.booleanValue == true ? 'Yes' : 'No',
    CustomFieldType.select => value.selectedOption ?? '',
  };
}
