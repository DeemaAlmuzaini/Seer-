import 'package:flutter/material.dart';

import '../../controllers/customer_orders_controller.dart';
import '../../widgets/orders_list_view.dart';
import 'order_details_page.dart';

/// "Current orders" tab: orders that are waiting or being served (#24).
class CustomerCurrentOrders extends StatelessWidget {
  /// Creates the tab.
  ///
  /// Parameters: [controller] provides the customer's orders.
  const CustomerCurrentOrders({super.key, required this.controller});

  final CustomerOrdersController controller;

  static const _emptyTitle = 'لا توجد طلبات حالية';
  static const _emptySubtitle = 'ستظهر هنا الطلبات قيد الانتظار والتنفيذ';

  /// Builds the list of current orders and rebuilds when they change.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: the orders list or one of its states.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => OrdersListView(
        orders: controller.currentOrders,
        isLoading: controller.isLoading,
        errorMessage: controller.errorMessage,
        emptyIcon: Icons.assignment_outlined,
        emptyTitle: _emptyTitle,
        emptySubtitle: _emptySubtitle,
        onRetry: controller.start,
        onOrderTap: (order) => OrderDetailsPage.open(
          context,
          controller: controller,
          order: order,
        ),
      ),
    );
  }
}
