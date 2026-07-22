import '../models/inventory_models.dart';

String itemTypeLabel(ItemType type) => switch (type) {
  ItemType.consumable => 'Consumable',
  ItemType.returnable => 'Returnable',
  ItemType.asset => 'Asset',
};

String itemTypeShortDescription(ItemType type) => switch (type) {
  ItemType.consumable => 'Used up and not expected back.',
  ItemType.returnable => 'Loaned out and expected back.',
  ItemType.asset => 'Track one specific item.',
};

String itemTypeExamples(ItemType type) => switch (type) {
  ItemType.consumable => 'Examples: gloves, bolts, tape, drill bits.',
  ItemType.returnable => 'Examples: tools, ladders, radios, meters.',
  ItemType.asset =>
    'Examples: Tablet #12, Generator G-15, Torque Wrench TW-007.',
};

String itemTypeBehaviorDescription(ItemType type) => switch (type) {
  ItemType.consumable => 'Stock goes down when issued.',
  ItemType.returnable => 'Creates a checkout so you know who has it.',
  ItemType.asset =>
    'Use when serial number, condition, or service history matters.',
};

String itemTypeDetailDescription(ItemType type) => switch (type) {
  ItemType.consumable => 'Used up when issued',
  ItemType.returnable => 'Expected back after checkout',
  ItemType.asset => 'Tracked as an individual item',
};

String itemTypeSimpleRule(ItemType type) => switch (type) {
  ItemType.consumable => 'Consumable = used up',
  ItemType.returnable => 'Returnable = should come back',
  ItemType.asset => 'Asset = exact item matters',
};

const itemTypeChoiceHelp =
    'Choose the option that matches what happens when this item is issued.';
