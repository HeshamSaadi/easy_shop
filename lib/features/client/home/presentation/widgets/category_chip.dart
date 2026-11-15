import 'package:flutter/material.dart';

/// One category chip. Used by the chips row and by the "See all" sheet,
/// so both look the same.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: primary,
      shape: StadiumBorder(
        side: BorderSide(color: isSelected ? primary : theme.dividerColor),
      ),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: isSelected ? theme.colorScheme.onPrimary : null,
      ),
      onSelected: (_) => onTap(),
    );
  }
}
