import 'package:flutter/material.dart';

import '../core/items/item_type_help.dart';
import '../core/models/inventory_models.dart';

class ItemTypePicker extends StatelessWidget {
  const ItemTypePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ItemType value;
  final ValueChanged<ItemType> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Item type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: () => showItemTypeHelpDialog(context),
              icon: const Icon(Icons.help_outline, size: 18),
              label: const Text('Help me choose'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final type in ItemType.values) ...[
          Semantics(
            selected: value == type,
            button: true,
            label: '${itemTypeLabel(type)}. ${itemTypeShortDescription(type)}',
            child: Card(
              margin: EdgeInsets.zero,
              color: value == type ? colors.secondaryContainer : null,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: value == type ? colors.primary : colors.outlineVariant,
                  width: value == type ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(type),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        value == type
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: value == type ? colors.primary : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemTypeLabel(type),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(itemTypeShortDescription(type)),
                            const SizedBox(height: 3),
                            Text(
                              itemTypeExamples(type),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              itemTypeBehaviorDescription(type),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (type != ItemType.values.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

Future<void> showItemTypeHelpDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Choosing an item type'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(itemTypeChoiceHelp),
            const SizedBox(height: 16),
            for (final type in ItemType.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  itemTypeSimpleRule(type),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}
