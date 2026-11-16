import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// The - / quantity / + control. While [isBusy] it shows a loader and both
/// buttons are disabled, so a fast double tap cannot send two requests.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.isBusy,
    required this.onIncrease,
    required this.onDecrease,
  });

  static const double _valueMinWidth = 32;

  final int quantity;
  final int maxQuantity;
  final bool isBusy;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    final canIncrease = !isBusy && quantity < maxQuantity;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(icon: Icons.remove, onPressed: isBusy ? null : onDecrease),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: _valueMinWidth),
          child: Center(child: _value(context)),
        ),
        _StepButton(
          icon: Icons.add,
          onPressed: canIncrease ? onIncrease : null,
        ),
      ],
    );
  }

  Widget _value(BuildContext context) {
    if (isBusy) {
      return const SizedBox(
        width: AppSizes.loaderSm,
        height: AppSizes.loaderSm,
        child: CircularProgressIndicator(strokeWidth: AppSizes.loaderStroke),
      );
    }
    return Text('$quantity', style: Theme.of(context).textTheme.titleMedium);
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: AppSizes.iconSm),
    );
  }
}
