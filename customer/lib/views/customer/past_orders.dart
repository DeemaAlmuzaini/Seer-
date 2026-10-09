import 'package:flutter/material.dart';

import '../../controllers/customer_orders_controller.dart';
import '../../widgets/orders_list_view.dart';
import 'order_details_page.dart';
import 'request_service_page.dart';

/// "Past orders" tab: completed, cancelled and rejected orders (#24).
class CustomerPastOrders extends StatelessWidget {
  /// Creates the tab.
  ///
  /// Parameters: [controller] provides the customer's orders.
  const CustomerPastOrders({super.key, required this.controller});

  final CustomerOrdersController controller;

  static const _emptyTitle = 'لا توجد طلبات سابقة';
  static const _emptySubtitle = 'ستظهر هنا الطلبات المكتملة والملغاة';

  /// Builds the list of past orders and rebuilds when they change.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: the orders list or one of its states.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => OrdersListView(
        orders: controller.pastOrders,
        isLoading: controller.isLoading,
        errorMessage: controller.errorMessage,
        emptyIcon: Icons.history_rounded,
        emptyTitle: _emptyTitle,
        emptySubtitle: _emptySubtitle,
        onRetry: controller.start,
        onOrderTap: (order) => OrderDetailsPage.open(
          context,
          controller: controller,
          order: order,
        ),
        // Rejected and auto-cancelled orders can be requested again (#21).
        onOrderReorder: (order) => RequestServicePage.reorder(
          context,
          uid: controller.uid,
          order: order,
        ),
      ),
    );
  }
}
