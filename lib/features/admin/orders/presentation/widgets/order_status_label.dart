import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/widgets/app_status_label.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/admin/orders/presentation/utils/order_formatters.dart';
import 'package:flutter/material.dart';

class OrderStatusLabel extends StatelessWidget {
  const OrderStatusLabel({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return AppStatusLabel(
      text: OrderFormatters.status(order.status),
      color: order.isPending ? AppColors.warning : null,
    );
  }
}
