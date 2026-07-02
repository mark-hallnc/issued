import 'models/models.dart';

final sampleUnitsOfMeasure = [
  const UnitOfMeasure(
    id: 'uom-each',
    name: 'Each',
    abbreviation: 'ea',
    allowsDecimal: false,
    isActive: true,
  ),
  const UnitOfMeasure(
    id: 'uom-foot',
    name: 'Foot',
    abbreviation: 'ft',
    allowsDecimal: true,
    isActive: true,
  ),
];

final sampleLocations = [
  const Location(
    id: 'loc-main-crib',
    name: 'Main Tool Crib',
    type: 'crib',
    parentLocationId: null,
    isActive: true,
  ),
  const Location(
    id: 'loc-shop-floor',
    name: 'Shop Floor',
    type: 'workArea',
    parentLocationId: null,
    isActive: true,
  ),
];

final samplePeople = [
  const Person(
    id: 'person-alex',
    displayName: 'Alex Morgan',
    email: 'alex@example.com',
    phone: null,
    isActive: true,
    isLoginUser: true,
  ),
  const Person(
    id: 'person-jordan',
    displayName: 'Jordan Lee',
    email: null,
    phone: '555-0104',
    isActive: true,
    isLoginUser: false,
  ),
];

final sampleUsers = [
  AppUser(
    id: 'user-alex',
    personId: 'person-alex',
    email: 'alex@example.com',
    role: UserRole.manager,
    isActive: true,
    createdAt: DateTime(2026, 7, 1),
  ),
];

final sampleItems = [
  Item(
    id: 'item-cutting-disc',
    name: 'Cutting Disc 4.5 in',
    description: 'General purpose metal cutting disc.',
    itemType: ItemType.consumable,
    category: 'Abrasives',
    locationId: 'loc-main-crib',
    quantityOnHand: 18,
    minimumQuantity: 25,
    unitOfMeasureId: 'uom-each',
    barcode: 'ISS-000001',
    sku: 'DISC-45-METAL',
    supplier: 'Industrial Supply Co.',
    unitCost: 2.85,
    photoPath: null,
    isActive: true,
    allowFractionalQuantity: false,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 1),
  ),
  Item(
    id: 'item-torque-wrench',
    name: 'Torque Wrench',
    description: 'Half-inch drive calibrated torque wrench.',
    itemType: ItemType.asset,
    category: 'Tools',
    locationId: 'loc-main-crib',
    quantityOnHand: 4,
    minimumQuantity: 2,
    unitOfMeasureId: 'uom-each',
    barcode: 'ISS-000002',
    sku: 'TW-050',
    supplier: 'Tool House',
    unitCost: 148.00,
    photoPath: null,
    isActive: true,
    allowFractionalQuantity: false,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 1),
  ),
  Item(
    id: 'item-magnetic-drill',
    name: 'Magnetic Drill',
    description: 'Portable magnetic base drill for structural steel work.',
    itemType: ItemType.returnable,
    category: 'Power Tools',
    locationId: 'loc-main-crib',
    quantityOnHand: 2,
    minimumQuantity: 1,
    unitOfMeasureId: 'uom-each',
    barcode: 'ISS-000003',
    sku: 'MAG-DRILL-01',
    supplier: 'Tool House',
    unitCost: 640.00,
    photoPath: null,
    isActive: true,
    allowFractionalQuantity: false,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 1),
  ),
];

final sampleTransactions = [
  InventoryTransaction(
    id: 'txn-issue-disc',
    itemId: 'item-cutting-disc',
    transactionType: InventoryTransactionType.issue,
    quantityDelta: -4,
    unitOfMeasureId: 'uom-each',
    fromLocationId: 'loc-main-crib',
    toLocationId: null,
    assignedToPersonId: 'person-jordan',
    performedByUserId: 'user-alex',
    notes: 'Issued for line repair.',
    createdAt: DateTime(2026, 7, 2, 9, 15),
  ),
  InventoryTransaction(
    id: 'txn-checkout-wrench',
    itemId: 'item-torque-wrench',
    transactionType: InventoryTransactionType.checkout,
    quantityDelta: -1,
    unitOfMeasureId: 'uom-each',
    fromLocationId: 'loc-main-crib',
    toLocationId: 'loc-shop-floor',
    assignedToPersonId: 'person-jordan',
    performedByUserId: 'user-alex',
    notes: null,
    createdAt: DateTime(2026, 7, 2, 10),
  ),
  InventoryTransaction(
    id: 'txn-checkout-drill',
    itemId: 'item-magnetic-drill',
    transactionType: InventoryTransactionType.checkout,
    quantityDelta: -1,
    unitOfMeasureId: 'uom-each',
    fromLocationId: 'loc-main-crib',
    toLocationId: 'loc-shop-floor',
    assignedToPersonId: 'person-jordan',
    performedByUserId: 'user-alex',
    notes: 'Checked out for frame repair.',
    createdAt: DateTime(2026, 7, 2, 11, 30),
  ),
];

final sampleCycleCountSessions = [
  CycleCountSession(
    id: 'count-july-crib',
    name: 'July Tool Crib Count',
    status: CycleCountStatus.assigned,
    assignedToUserId: 'user-alex',
    blindCount: true,
    dueAt: DateTime(2026, 7, 12),
    createdAt: DateTime(2026, 7, 2),
    submittedAt: null,
    approvedAt: null,
  ),
];

final sampleCycleCountLines = [
  const CycleCountLine(
    id: 'count-line-discs',
    sessionId: 'count-july-crib',
    itemId: 'item-cutting-disc',
    locationId: 'loc-main-crib',
    expectedQuantity: 18,
    countedQuantity: null,
    varianceQuantity: null,
    unitOfMeasureId: 'uom-each',
    notes: null,
  ),
];

final sampleCustomFieldDefinitions = [
  const CustomFieldDefinition(
    id: 'field-calibration-required',
    entityType: CustomFieldEntityType.item,
    name: 'Calibration Required',
    fieldType: CustomFieldType.boolean,
    isRequired: false,
    options: [],
    isActive: true,
  ),
  const CustomFieldDefinition(
    id: 'field-tool-condition',
    entityType: CustomFieldEntityType.item,
    name: 'Tool Condition',
    fieldType: CustomFieldType.select,
    isRequired: false,
    options: ['Good', 'Service Due', 'Damaged'],
    isActive: true,
  ),
];

final sampleCustomFieldValues = [
  const CustomFieldValue(
    id: 'value-torque-calibration',
    definitionId: 'field-calibration-required',
    entityId: 'item-torque-wrench',
    textValue: null,
    numberValue: null,
    dateValue: null,
    booleanValue: true,
    selectedOption: null,
  ),
  const CustomFieldValue(
    id: 'value-torque-condition',
    definitionId: 'field-tool-condition',
    entityId: 'item-torque-wrench',
    textValue: null,
    numberValue: null,
    dateValue: null,
    booleanValue: null,
    selectedOption: 'Good',
  ),
];

const samplePlan = Plan(
  code: 'starter',
  name: 'Starter',
  itemLimit: 250,
  userLimit: 5,
  locationLimit: 10,
  photoLimit: 100,
  labelExportLimit: 25,
);

const sampleCompanyUsage = CompanyUsage(
  activeItemCount: 3,
  userCount: 1,
  locationCount: 2,
  photoCount: 0,
  labelExportCount: 0,
);
