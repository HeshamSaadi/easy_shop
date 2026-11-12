import 'package:easy_shop/core/location/picked_location.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_empty.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/client/checkout/presentation/constants/checkout_strings.dart';
import 'package:easy_shop/features/client/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:easy_shop/features/client/checkout/presentation/cubit/checkout_state.dart';
import 'package:easy_shop/features/client/checkout/presentation/widgets/checkout_items_card.dart';
import 'package:easy_shop/features/client/checkout/presentation/widgets/checkout_summary_card.dart';
import 'package:easy_shop/features/client/checkout/presentation/widgets/delivery_address_card.dart';
import 'package:easy_shop/features/client/checkout/presentation/widgets/payment_section.dart';
import 'package:easy_shop/features/client/orders/domain/entities/order_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens the map picker. [current] is the point to start from, if any.
typedef PickDeliveryLocation = Future<PickedLocation?> Function(
  PickedLocation? current,
);

/// Needs a [CheckoutCubit] above it in the tree.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({
    super.key,
    required this.onPickLocation,
    required this.onOrderPlaced,
  });

  final PickDeliveryLocation onPickLocation;
  final ValueChanged<OrderEntity> onOrderPlaced;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: CheckoutStrings.title, showBack: true),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listenWhen: (_, current) =>
            current is CheckoutPlaced ||
            (current is CheckoutReady && current.actionError != null),
        listener: (context, state) {
          if (state is CheckoutPlaced) {
            onOrderPlaced(state.order);
            return;
          }
          if (state is! CheckoutReady) return;
          final message = state.actionError;
          if (message == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
          return switch (state) {
            CheckoutInitial() ||
            CheckoutLoading() ||
            CheckoutPlaced() => const AppLoading(),
            CheckoutError(:final message) => AppError(
              message: message,
              onRetry: () => context.read<CheckoutCubit>().load(),
            ),
            CheckoutReady(:final items) when items.isEmpty => const AppEmpty(
              message: CheckoutStrings.emptyCart,
              icon: Icons.shopping_cart_outlined,
            ),
            final CheckoutReady ready => PopScope(
              // Do not leave while the order request is running.
              canPop: !ready.isPlacing,
              child: _CheckoutContent(
                state: ready,
                onPickLocation: onPickLocation,
              ),
            ),
          };
        },
      ),
    );
  }
}

class _CheckoutContent extends StatelessWidget {
  const _CheckoutContent({required this.state, required this.onPickLocation});

  final CheckoutReady state;
  final PickDeliveryLocation onPickLocation;

  Future<void> _changeLocation(BuildContext context) async {
    final cubit = context.read<CheckoutCubit>();
    final picked = await onPickLocation(state.location);
    if (picked != null) cubit.setLocation(picked);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const _SectionTitle(CheckoutStrings.deliveryAddress),
              DeliveryAddressCard(
                address: state.deliveryAddress,
                hasLocation: state.hasLocation,
                enabled: !state.isPlacing,
                onChange: () => _changeLocation(context),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const _SectionTitle(CheckoutStrings.orderItems),
              CheckoutItemsCard(items: state.items),
              const SizedBox(height: AppSpacing.xxl),
              const _SectionTitle(CheckoutStrings.paymentMethod),
              const PaymentSection(),
              const SizedBox(height: AppSpacing.xxl),
              const _SectionTitle(CheckoutStrings.orderSummary),
              CheckoutSummaryCard(
                itemCount: state.items.length,
                total: state.total,
              ),
            ],
          ),
        ),
        _PlaceOrderBar(
          hasProblems: state.hasProblems,
          isPlacing: state.isPlacing,
          onPlaceOrder: state.canPlace ? cubit.placeOrder : null,
        ),
      ],
    );
  }
}

class _PlaceOrderBar extends StatelessWidget {
  const _PlaceOrderBar({
    required this.hasProblems,
    required this.isPlacing,
    required this.onPlaceOrder,
  });

  final bool hasProblems;
  final bool isPlacing;

  /// Null while the order cannot be placed (the button is disabled).
  final VoidCallback? onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasProblems)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  CheckoutStrings.fixItems,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            AppButton(
              text: CheckoutStrings.placeOrder,
              isLoading: isPlacing,
              onPressed: onPlaceOrder,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
