import '../app_store.dart';
import '../models/models.dart';

enum DataHealthSeverity { info, warning, error }

enum DataHealthRepairAction {
  syncItemQuantityFromBalances,
  createMissingBalanceForItem,
  reassignBalanceToFallbackLocation,
  cancelOrphanReorderRequest,
  removeOrphanCustomFieldValue,
  resetNegativeMinimumQuantity,
  createMissingDefaultSetup,
  clearInvalidLocationParent,
}

class DataHealthIssue {
  const DataHealthIssue({
    required this.id,
    required this.severity,
    required this.title,
    required this.description,
    required this.affectedRecordType,
    required this.affectedRecordId,
    required this.repairAction,
    required this.canRepair,
  });

  final String id;
  final DataHealthSeverity severity;
  final String title;
  final String description;
  final String affectedRecordType;
  final String? affectedRecordId;
  final DataHealthRepairAction? repairAction;
  final bool canRepair;
}

class DataHealthReport {
  const DataHealthReport({required this.generatedAt, required this.issues});

  final DateTime generatedAt;
  final List<DataHealthIssue> issues;

  int get errorCount => issues
      .where((issue) => issue.severity == DataHealthSeverity.error)
      .length;
  int get warningCount => issues
      .where((issue) => issue.severity == DataHealthSeverity.warning)
      .length;
  int get infoCount =>
      issues.where((issue) => issue.severity == DataHealthSeverity.info).length;
  bool get isHealthy => issues.isEmpty;
}

class DataHealthService {
  const DataHealthService();

  static const double _quantityTolerance = 0.0001;

  DataHealthReport run(AppStore store) {
    final issues = <DataHealthIssue>[];
    final itemsById = {for (final item in store.items) item.id: item};
    final locationsById = {
      for (final location in store.locations) location.id: location,
    };
    final activeLocations = store.locations
        .where((location) => location.isActive)
        .toList();
    final uomsById = {for (final unit in store.unitsOfMeasure) unit.id: unit};
    final peopleById = {for (final person in store.people) person.id: person};
    final usersById = {for (final user in store.users) user.id: user};
    final customDefinitionsById = {
      for (final field in store.customFieldDefinitions) field.id: field,
    };
    final targetsById = {
      for (final target in store.assignmentTargets) target.id: target,
    };

    _checkItemBalances(store, issues, locationsById, activeLocations);
    _checkBalanceReferences(store, issues, itemsById, locationsById);
    _checkTransactionReferences(
      store,
      issues,
      itemsById,
      uomsById,
      locationsById,
      peopleById,
      usersById,
      targetsById,
    );
    _checkAssignmentTargets(store, issues);
    _checkLocations(store, issues, locationsById);
    _checkCheckouts(store, issues, itemsById, targetsById);
    _checkReorders(store, issues, itemsById, locationsById);
    _checkCycleCounts(store, issues, itemsById, locationsById);
    _checkCustomFields(store, issues, customDefinitionsById);
    _checkDuplicates(store, issues);
    _checkSetup(store, issues);
    _checkInvalidQuantities(store, issues);

    issues.sort((left, right) {
      final severityCompare = _severityRank(
        right.severity,
      ).compareTo(_severityRank(left.severity));
      if (severityCompare != 0) {
        return severityCompare;
      }
      return left.title.compareTo(right.title);
    });

    return DataHealthReport(generatedAt: DateTime.now(), issues: issues);
  }

  void _checkItemBalances(
    AppStore store,
    List<DataHealthIssue> issues,
    Map<String, Location> locationsById,
    List<Location> activeLocations,
  ) {
    for (final item in store.items) {
      final balances = store.itemBalancesForItem(item.id);
      if (item.isActive && balances.isEmpty) {
        final canRepair =
            locationsById.containsKey(item.locationId) ||
            activeLocations.isNotEmpty;
        issues.add(
          DataHealthIssue(
            id: 'missing-balance-${item.id}',
            severity: DataHealthSeverity.warning,
            title: 'Item has no location balance',
            description:
                '${item.name} has no stock-by-location row. A balance can be created from the item total quantity.',
            affectedRecordType: 'item',
            affectedRecordId: item.id,
            repairAction: DataHealthRepairAction.createMissingBalanceForItem,
            canRepair: canRepair,
          ),
        );
      }

      final balanceTotal = balances.fold<double>(
        0,
        (sum, balance) => sum + balance.quantityOnHand,
      );
      if ((item.quantityOnHand - balanceTotal).abs() > _quantityTolerance) {
        issues.add(
          DataHealthIssue(
            id: 'quantity-mismatch-${item.id}',
            severity: DataHealthSeverity.warning,
            title: 'Item total does not match location balances',
            description:
                '${item.name} shows ${item.quantityOnHand}, but location balances add up to $balanceTotal.',
            affectedRecordType: 'item',
            affectedRecordId: item.id,
            repairAction: DataHealthRepairAction.syncItemQuantityFromBalances,
            canRepair: true,
          ),
        );
      }
    }
  }

  void _checkBalanceReferences(
    AppStore store,
    List<DataHealthIssue> issues,
    Map<String, Item> itemsById,
    Map<String, Location> locationsById,
  ) {
    for (final balance in store.itemLocationBalances) {
      if (!itemsById.containsKey(balance.itemId)) {
        issues.add(
          DataHealthIssue(
            id: 'balance-missing-item-${balance.id}',
            severity: DataHealthSeverity.error,
            title: 'Balance points to a missing item',
            description:
                'Location balance ${balance.id} references item ${balance.itemId}, which is not in local data.',
            affectedRecordType: 'itemLocationBalance',
            affectedRecordId: balance.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }

      if (!locationsById.containsKey(balance.locationId)) {
        issues.add(
          DataHealthIssue(
            id: 'balance-missing-location-${balance.id}',
            severity: DataHealthSeverity.warning,
            title: 'Balance points to a missing location',
            description:
                'A balance for item ${balance.itemId} uses location ${balance.locationId}, which is not in local data.',
            affectedRecordType: 'itemLocationBalance',
            affectedRecordId: balance.id,
            repairAction:
                DataHealthRepairAction.reassignBalanceToFallbackLocation,
            canRepair: store.locations.any((location) => location.isActive),
          ),
        );
      }
    }
  }

  void _checkTransactionReferences(
    AppStore store,
    List<DataHealthIssue> issues,
    Map<String, Item> itemsById,
    Map<String, UnitOfMeasure> uomsById,
    Map<String, Location> locationsById,
    Map<String, Person> peopleById,
    Map<String, AppUser> usersById,
    Map<String, AssignmentTarget> targetsById,
  ) {
    for (final transaction in store.transactions) {
      if (!itemsById.containsKey(transaction.itemId)) {
        issues.add(
          DataHealthIssue(
            id: 'transaction-missing-item-${transaction.id}',
            severity: DataHealthSeverity.warning,
            title: 'Activity references a missing item',
            description:
                'Activity ${transaction.id} references item ${transaction.itemId}, which is not in local data.',
            affectedRecordType: 'inventoryTransaction',
            affectedRecordId: transaction.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
      if (!uomsById.containsKey(transaction.unitOfMeasureId)) {
        _missingLinkIssue(
          issues,
          id: 'transaction-missing-uom-${transaction.id}',
          title: 'Activity references a missing unit',
          description: 'Activity ${transaction.id} uses a missing unit.',
          type: 'inventoryTransaction',
          recordId: transaction.id,
        );
      }
      for (final locationId in [
        transaction.fromLocationId,
        transaction.toLocationId,
        transaction.assignedToLocationId,
      ]) {
        if (locationId != null && !locationsById.containsKey(locationId)) {
          _missingLinkIssue(
            issues,
            id: 'transaction-missing-location-${transaction.id}-$locationId',
            title: 'Activity references a missing location',
            description:
                'Activity ${transaction.id} references location $locationId.',
            type: 'inventoryTransaction',
            recordId: transaction.id,
          );
        }
      }
      final personId = transaction.assignedToPersonId;
      if (personId != null && !peopleById.containsKey(personId)) {
        _missingLinkIssue(
          issues,
          id: 'transaction-missing-person-${transaction.id}',
          title: 'Activity references a missing person',
          description:
              'Activity ${transaction.id} references person $personId.',
          type: 'inventoryTransaction',
          recordId: transaction.id,
        );
      }
      final userId = transaction.performedByUserId;
      if (userId != null && !usersById.containsKey(userId)) {
        _missingLinkIssue(
          issues,
          id: 'transaction-missing-user-${transaction.id}',
          title: 'Activity references a missing user',
          description: 'Activity ${transaction.id} references user $userId.',
          type: 'inventoryTransaction',
          recordId: transaction.id,
        );
      }
      final targetId = transaction.assignedToTargetId;
      if (targetId != null && !targetsById.containsKey(targetId)) {
        _missingLinkIssue(
          issues,
          id: 'transaction-missing-target-${transaction.id}',
          title: 'Activity references a missing assignment target',
          description:
              'Activity ${transaction.id} references assignment target $targetId.',
          type: 'inventoryTransaction',
          recordId: transaction.id,
        );
      }
    }
  }

  void _checkCheckouts(
    AppStore store,
    List<DataHealthIssue> issues,
    Map<String, Item> itemsById,
    Map<String, AssignmentTarget> targetsById,
  ) {
    final peopleById = {for (final person in store.people) person.id: person};
    final locationsById = {
      for (final location in store.locations) location.id: location,
    };
    for (final checkout in store.openCheckoutRecords) {
      if (checkout.quantityReturned > checkout.quantity) {
        issues.add(
          DataHealthIssue(
            id: 'checkout-returned-exceeds-checked-out-${checkout.id}',
            severity: DataHealthSeverity.error,
            title: 'Checkout returned quantity is too high',
            description:
                'Checkout ${checkout.id} has more returned than checked out.',
            affectedRecordType: 'checkoutRecord',
            affectedRecordId: checkout.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
      if (checkout.quantityOpen < 0) {
        issues.add(
          DataHealthIssue(
            id: 'checkout-negative-open-${checkout.id}',
            severity: DataHealthSeverity.error,
            title: 'Checkout has negative open quantity',
            description:
                'Checkout ${checkout.id} has a negative open quantity.',
            affectedRecordType: 'checkoutRecord',
            affectedRecordId: checkout.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
      if (checkout.isOpen && checkout.returnedAt != null) {
        issues.add(
          DataHealthIssue(
            id: 'checkout-open-with-returned-at-${checkout.id}',
            severity: DataHealthSeverity.warning,
            title: 'Open checkout has a returned date',
            description:
                'Checkout ${checkout.id} is still open but has returnedAt set.',
            affectedRecordType: 'checkoutRecord',
            affectedRecordId: checkout.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
      final personId = checkout.assignedToPersonId;
      if (personId != null && !peopleById.containsKey(personId)) {
        _missingLinkIssue(
          issues,
          id: 'checkout-missing-person-${checkout.id}',
          title: 'Checkout references a missing person',
          description: 'Checkout ${checkout.id} references person $personId.',
          type: 'checkoutRecord',
          recordId: checkout.id,
        );
      }
      final assignedLocationId = checkout.assignedToLocationId;
      if (assignedLocationId != null &&
          !locationsById.containsKey(assignedLocationId)) {
        _missingLinkIssue(
          issues,
          id: 'checkout-missing-assigned-location-${checkout.id}',
          title: 'Checkout references a missing assigned location',
          description:
              'Checkout ${checkout.id} references location $assignedLocationId.',
          type: 'checkoutRecord',
          recordId: checkout.id,
        );
      }
      final targetId = checkout.assignedToTargetId;
      if (targetId != null && !targetsById.containsKey(targetId)) {
        _missingLinkIssue(
          issues,
          id: 'checkout-missing-target-${checkout.id}',
          title: 'Checkout references a missing assignment target',
          description:
              'Checkout ${checkout.id} references assignment target $targetId.',
          type: 'checkoutRecord',
          recordId: checkout.id,
        );
      } else if (targetId != null && targetsById[targetId]?.isActive == false) {
        issues.add(
          DataHealthIssue(
            id: 'checkout-archived-target-${checkout.id}',
            severity: DataHealthSeverity.warning,
            title: 'Open checkout is assigned to an archived target',
            description:
                'Checkout ${checkout.id} is assigned to archived assignment target ${targetsById[targetId]!.name}.',
            affectedRecordType: 'checkoutRecord',
            affectedRecordId: checkout.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
      final item = itemsById[checkout.itemId];
      if (item == null) {
        issues.add(
          DataHealthIssue(
            id: 'checkout-missing-item-${checkout.id}',
            severity: DataHealthSeverity.error,
            title: 'Open checkout references a missing item',
            description:
                'Checkout ${checkout.id} references item ${checkout.itemId}, which is not in local data.',
            affectedRecordType: 'checkoutRecord',
            affectedRecordId: checkout.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      } else if (item.itemType == ItemType.consumable) {
        issues.add(
          DataHealthIssue(
            id: 'checkout-consumable-item-${checkout.id}',
            severity: DataHealthSeverity.warning,
            title: 'Consumable item has an open checkout',
            description:
                '${item.name} is a consumable but has an open checkout record.',
            affectedRecordType: 'checkoutRecord',
            affectedRecordId: checkout.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      } else if (checkout.quantityOpen > item.quantityOnHand) {
        issues.add(
          DataHealthIssue(
            id: 'checkout-exceeds-total-${checkout.id}',
            severity: DataHealthSeverity.warning,
            title: 'Checked-out quantity is higher than available total',
            description:
                '${item.name} has ${checkout.quantityOpen} open and ${item.quantityOnHand} available. This can be normal if checked-out stock is not counted as available.',
            affectedRecordType: 'checkoutRecord',
            affectedRecordId: checkout.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
    }
  }

  void _checkAssignmentTargets(AppStore store, List<DataHealthIssue> issues) {
    final seen = <String, AssignmentTarget>{};
    for (final target in store.assignmentTargets.where(
      (target) => target.isActive,
    )) {
      final key =
          '${target.targetType.name}:${target.name.trim().toLowerCase()}';
      final existing = seen[key];
      if (existing == null) {
        seen[key] = target;
        continue;
      }
      issues.add(
        DataHealthIssue(
          id: 'duplicate-assignment-target-${target.id}',
          severity: DataHealthSeverity.warning,
          title: 'Duplicate assignment target',
          description:
              '${target.name} is duplicated for ${assignmentTargetTypeLabel(target.targetType)} targets.',
          affectedRecordType: 'assignmentTarget',
          affectedRecordId: target.id,
          repairAction: null,
          canRepair: false,
        ),
      );
    }
  }

  void _checkLocations(
    AppStore store,
    List<DataHealthIssue> issues,
    Map<String, Location> locationsById,
  ) {
    final activeCodes = <String, Location>{};
    final activeSiblingNames = <String, Location>{};
    for (final location in store.locations) {
      final parentId = location.parentLocationId;
      if (parentId != null && !locationsById.containsKey(parentId)) {
        issues.add(
          DataHealthIssue(
            id: 'location-missing-parent-${location.id}',
            severity: DataHealthSeverity.warning,
            title: 'Location parent is missing',
            description:
                '${location.name} references parent location $parentId, which is not in local data.',
            affectedRecordType: 'location',
            affectedRecordId: location.id,
            repairAction: DataHealthRepairAction.clearInvalidLocationParent,
            canRepair: true,
          ),
        );
      }
      if (store.wouldCreateLocationCycle(location.id, parentId)) {
        issues.add(
          DataHealthIssue(
            id: 'location-parent-cycle-${location.id}',
            severity: DataHealthSeverity.error,
            title: 'Location hierarchy has a cycle',
            description:
                '${location.name} is part of a circular parent location chain.',
            affectedRecordType: 'location',
            affectedRecordId: location.id,
            repairAction: DataHealthRepairAction.clearInvalidLocationParent,
            canRepair: true,
          ),
        );
      }
      if (!location.isActive) {
        final hasStock = store
            .getBalancesAtLocation(location.id)
            .any((balance) => balance.quantityOnHand > 0);
        if (hasStock) {
          issues.add(
            DataHealthIssue(
              id: 'archived-location-stock-${location.id}',
              severity: DataHealthSeverity.warning,
              title: 'Archived location has stock',
              description:
                  '${location.name} is archived but still has positive stock.',
              affectedRecordType: 'location',
              affectedRecordId: location.id,
              repairAction: null,
              canRepair: false,
            ),
          );
        }
      }
      if (!location.isActive) {
        continue;
      }
      final code = location.code?.trim().toLowerCase();
      if (code != null && code.isNotEmpty) {
        final existing = activeCodes[code];
        if (existing == null) {
          activeCodes[code] = location;
        } else {
          issues.add(
            DataHealthIssue(
              id: 'duplicate-location-code-${location.id}',
              severity: DataHealthSeverity.warning,
              title: 'Duplicate active location code',
              description:
                  '${location.name} and ${existing.name} both use code ${location.code}.',
              affectedRecordType: 'location',
              affectedRecordId: location.id,
              repairAction: null,
              canRepair: false,
            ),
          );
        }
      }
      final siblingKey =
          '${location.parentLocationId ?? 'root'}:${location.name.trim().toLowerCase()}';
      final existing = activeSiblingNames[siblingKey];
      if (existing == null) {
        activeSiblingNames[siblingKey] = location;
      } else {
        issues.add(
          DataHealthIssue(
            id: 'duplicate-sibling-location-${location.id}',
            severity: DataHealthSeverity.warning,
            title: 'Duplicate active sibling location name',
            description:
                '${location.name} appears more than once under the same parent.',
            affectedRecordType: 'location',
            affectedRecordId: location.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
    }
  }

  void _checkReorders(
    AppStore store,
    List<DataHealthIssue> issues,
    Map<String, Item> itemsById,
    Map<String, Location> locationsById,
  ) {
    final openByItemId = <String, int>{};
    for (final request in store.reorderRequests) {
      final item = itemsById[request.itemId];
      if (request.isOpen) {
        openByItemId[request.itemId] = (openByItemId[request.itemId] ?? 0) + 1;
      }
      if (item == null) {
        issues.add(
          DataHealthIssue(
            id: 'reorder-missing-item-${request.id}',
            severity: request.isOpen
                ? DataHealthSeverity.warning
                : DataHealthSeverity.info,
            title: 'Reorder request references a missing item',
            description:
                'Reorder request ${request.id} references item ${request.itemId}, which is not in local data.',
            affectedRecordType: 'reorderRequest',
            affectedRecordId: request.id,
            repairAction: DataHealthRepairAction.cancelOrphanReorderRequest,
            canRepair: request.isOpen,
          ),
        );
      } else if (request.isOpen && !item.isActive) {
        issues.add(
          DataHealthIssue(
            id: 'reorder-archived-item-${request.id}',
            severity: DataHealthSeverity.warning,
            title: 'Open reorder is for an archived item',
            description:
                'Reorder request ${request.id} is still open for archived item ${item.name}.',
            affectedRecordType: 'reorderRequest',
            affectedRecordId: request.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
      if (request.requestedQuantity < 0) {
        issues.add(
          DataHealthIssue(
            id: 'reorder-negative-requested-${request.id}',
            severity: DataHealthSeverity.error,
            title: 'Reorder has negative requested quantity',
            description:
                'Reorder request ${request.id} has requested quantity ${request.requestedQuantity}.',
            affectedRecordType: 'reorderRequest',
            affectedRecordId: request.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
      if (request.receivedQuantity < 0) {
        issues.add(
          DataHealthIssue(
            id: 'reorder-negative-received-${request.id}',
            severity: DataHealthSeverity.error,
            title: 'Reorder has negative received quantity',
            description:
                'Reorder request ${request.id} has received quantity ${request.receivedQuantity}.',
            affectedRecordType: 'reorderRequest',
            affectedRecordId: request.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
      if (request.receivedQuantity > request.requestedQuantity) {
        issues.add(
          DataHealthIssue(
            id: 'reorder-over-received-${request.id}',
            severity: DataHealthSeverity.warning,
            title: 'Reorder received more than requested',
            description:
                'Reorder request ${request.id} received ${request.receivedQuantity} against ${request.requestedQuantity} requested.',
            affectedRecordType: 'reorderRequest',
            affectedRecordId: request.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
      if (request.status == ReorderStatus.received &&
          request.receivedQuantity <= 0) {
        issues.add(
          DataHealthIssue(
            id: 'reorder-received-without-quantity-${request.id}',
            severity: DataHealthSeverity.warning,
            title: 'Received reorder has no received quantity',
            description:
                'Reorder request ${request.id} is marked received but has no received quantity.',
            affectedRecordType: 'reorderRequest',
            affectedRecordId: request.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
      if (request.status == ReorderStatus.ordered &&
          request.orderedAt == null) {
        issues.add(
          DataHealthIssue(
            id: 'reorder-ordered-missing-date-${request.id}',
            severity: DataHealthSeverity.warning,
            title: 'Ordered reorder is missing ordered date',
            description:
                'Reorder request ${request.id} is marked ordered but has no ordered date.',
            affectedRecordType: 'reorderRequest',
            affectedRecordId: request.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
      final destinationId = request.destinationLocationId;
      if (destinationId != null && !locationsById.containsKey(destinationId)) {
        _missingLinkIssue(
          issues,
          id: 'reorder-missing-destination-${request.id}',
          title: 'Reorder references a missing destination location',
          description:
              'Reorder request ${request.id} references location $destinationId.',
          type: 'reorderRequest',
          recordId: request.id,
        );
      }
    }
    for (final entry in openByItemId.entries) {
      if (entry.value <= 1) {
        continue;
      }
      final item = itemsById[entry.key];
      issues.add(
        DataHealthIssue(
          id: 'reorder-duplicate-open-${entry.key}',
          severity: DataHealthSeverity.warning,
          title: 'Duplicate open reorder requests',
          description:
              '${item?.name ?? entry.key} has ${entry.value} open reorder requests.',
          affectedRecordType: 'reorderRequest',
          affectedRecordId: entry.key,
          repairAction: null,
          canRepair: false,
        ),
      );
    }
  }

  void _checkCycleCounts(
    AppStore store,
    List<DataHealthIssue> issues,
    Map<String, Item> itemsById,
    Map<String, Location> locationsById,
  ) {
    for (final line in store.cycleCountLines) {
      if (!itemsById.containsKey(line.itemId)) {
        _missingLinkIssue(
          issues,
          id: 'count-line-missing-item-${line.id}',
          title: 'Cycle count line references a missing item',
          description:
              'Cycle count line ${line.id} references item ${line.itemId}.',
          type: 'cycleCountLine',
          recordId: line.id,
        );
      }
      if (line.locationId.isNotEmpty &&
          !locationsById.containsKey(line.locationId)) {
        _missingLinkIssue(
          issues,
          id: 'count-line-missing-location-${line.id}',
          title: 'Cycle count line references a missing location',
          description:
              'Cycle count line ${line.id} references location ${line.locationId}.',
          type: 'cycleCountLine',
          recordId: line.id,
        );
      }
    }
  }

  void _checkCustomFields(
    AppStore store,
    List<DataHealthIssue> issues,
    Map<String, CustomFieldDefinition> customDefinitionsById,
  ) {
    for (final value in store.customFieldValues) {
      if (customDefinitionsById.containsKey(value.definitionId)) {
        continue;
      }
      issues.add(
        DataHealthIssue(
          id: 'custom-value-missing-definition-${value.id}',
          severity: DataHealthSeverity.warning,
          title: 'Custom field value has no definition',
          description:
              'Custom field value ${value.id} references definition ${value.definitionId}, which is not in local data.',
          affectedRecordType: 'customFieldValue',
          affectedRecordId: value.id,
          repairAction: DataHealthRepairAction.removeOrphanCustomFieldValue,
          canRepair: true,
        ),
      );
    }
  }

  void _checkDuplicates(AppStore store, List<DataHealthIssue> issues) {
    _checkDuplicateItemValue(
      store,
      issues,
      title: 'Duplicate active barcode',
      fieldName: 'barcode',
      valueFor: (item) => item.barcode,
      severity: DataHealthSeverity.error,
    );
    _checkDuplicateItemValue(
      store,
      issues,
      title: 'Duplicate active SKU',
      fieldName: 'SKU',
      valueFor: (item) => item.sku,
      severity: DataHealthSeverity.warning,
    );
  }

  void _checkSetup(AppStore store, List<DataHealthIssue> issues) {
    final missingCompany = store.company == null;
    final missingLocation = !store.locations.any(
      (location) => location.isActive,
    );
    final missingUom = store.unitsOfMeasure.isEmpty;
    final missingAdmin = !store.users.any(
      (user) => user.isActive && user.role == UserRole.admin,
    );
    if (missingCompany || missingLocation || missingUom || missingAdmin) {
      issues.add(
        DataHealthIssue(
          id: 'missing-default-setup',
          severity: DataHealthSeverity.warning,
          title: 'Required setup is missing',
          description:
              'Issued needs a company, active location, units of measure, and an admin user.',
          affectedRecordType: 'setup',
          affectedRecordId: null,
          repairAction: DataHealthRepairAction.createMissingDefaultSetup,
          canRepair: true,
        ),
      );
    }

    for (final user in store.users.where((user) => user.isActive)) {
      final needsPin = user.role != UserRole.viewOnly;
      final hasPin =
          (user.pinHash?.isNotEmpty ?? false) &&
          (user.pinSalt?.isNotEmpty ?? false);
      if (needsPin && !hasPin) {
        issues.add(
          DataHealthIssue(
            id: 'active-user-missing-pin-${user.id}',
            severity: DataHealthSeverity.warning,
            title: 'Active user is missing a PIN',
            description:
                '${store.resolveUserName(user.id)} can change inventory but does not have a local PIN set.',
            affectedRecordType: 'appUser',
            affectedRecordId: user.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
    }

    final names = <String, List<String>>{};
    for (final user in store.users) {
      final name = store.resolveUserName(user.id)?.trim().toLowerCase();
      if (name == null || name.isEmpty) {
        continue;
      }
      names.putIfAbsent(name, () => []).add(user.id);
    }
    for (final entry in names.entries) {
      if (entry.value.length > 1) {
        issues.add(
          DataHealthIssue(
            id: 'duplicate-user-name-${entry.key}',
            severity: DataHealthSeverity.info,
            title: 'Duplicate local user names',
            description:
                'More than one local user is named ${store.resolveUserName(entry.value.first)}.',
            affectedRecordType: 'appUser',
            affectedRecordId: entry.value.first,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
    }
  }

  void _checkInvalidQuantities(AppStore store, List<DataHealthIssue> issues) {
    for (final item in store.items) {
      if (item.quantityOnHand < 0) {
        issues.add(
          DataHealthIssue(
            id: 'negative-item-quantity-${item.id}',
            severity: DataHealthSeverity.error,
            title: 'Item has negative quantity',
            description:
                '${item.name} has a negative total quantity. Review stock activity before repairing manually.',
            affectedRecordType: 'item',
            affectedRecordId: item.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
      if (item.minimumQuantity < 0) {
        issues.add(
          DataHealthIssue(
            id: 'negative-item-minimum-${item.id}',
            severity: DataHealthSeverity.warning,
            title: 'Item has negative minimum quantity',
            description: '${item.name} has a minimum quantity below zero.',
            affectedRecordType: 'item',
            affectedRecordId: item.id,
            repairAction: DataHealthRepairAction.resetNegativeMinimumQuantity,
            canRepair: true,
          ),
        );
      }
    }
    for (final balance in store.itemLocationBalances) {
      if (balance.quantityOnHand < 0) {
        issues.add(
          DataHealthIssue(
            id: 'negative-balance-${balance.id}',
            severity: DataHealthSeverity.error,
            title: 'Location balance is negative',
            description:
                'Balance ${balance.id} has a negative quantity. Review stock activity before repairing manually.',
            affectedRecordType: 'itemLocationBalance',
            affectedRecordId: balance.id,
            repairAction: null,
            canRepair: false,
          ),
        );
      }
    }
  }

  void _checkDuplicateItemValue(
    AppStore store,
    List<DataHealthIssue> issues, {
    required String title,
    required String fieldName,
    required String? Function(Item item) valueFor,
    required DataHealthSeverity severity,
  }) {
    final values = <String, List<Item>>{};
    for (final item in store.items.where((item) => item.isActive)) {
      final value = valueFor(item)?.trim().toLowerCase();
      if (value == null || value.isEmpty) {
        continue;
      }
      values.putIfAbsent(value, () => []).add(item);
    }

    for (final entry in values.entries) {
      if (entry.value.length < 2) {
        continue;
      }
      issues.add(
        DataHealthIssue(
          id: 'duplicate-$fieldName-${entry.key}',
          severity: severity,
          title: title,
          description:
              '${entry.value.length} active items use the same $fieldName: ${entry.key}. Edit the items to make lookup values unique.',
          affectedRecordType: 'item',
          affectedRecordId: entry.value.first.id,
          repairAction: null,
          canRepair: false,
        ),
      );
    }
  }

  void _missingLinkIssue(
    List<DataHealthIssue> issues, {
    required String id,
    required String title,
    required String description,
    required String type,
    required String recordId,
  }) {
    issues.add(
      DataHealthIssue(
        id: id,
        severity: DataHealthSeverity.warning,
        title: title,
        description: description,
        affectedRecordType: type,
        affectedRecordId: recordId,
        repairAction: null,
        canRepair: false,
      ),
    );
  }

  int _severityRank(DataHealthSeverity severity) {
    return switch (severity) {
      DataHealthSeverity.info => 0,
      DataHealthSeverity.warning => 1,
      DataHealthSeverity.error => 2,
    };
  }
}
