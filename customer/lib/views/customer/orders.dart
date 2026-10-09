import 'package:flutter/material.dart';

import '../../controllers/customer_orders_controller.dart';
import '../../theme/app_colors.dart';
import 'current_orders.dart';
import 'past_orders.dart';

/// Orders tab: switches between current and past orders (#24).
class CustomerOrders extends StatefulWidget {
  /// Creates the orders tab.
  ///
  /// Parameters: [uid] is the signed-in customer's id.
  const CustomerOrders({super.key, required this.uid});

  final String uid;

  /// Creates the tab state.
  ///
  /// Parameters: none. Returns: the state object.
  @override
  State<CustomerOrders> createState() => _CustomerOrdersState();
}

class _CustomerOrdersState extends State<CustomerOrders> {
  late final CustomerOrdersController _controller;

  static const _currentTab = 'الحالية';
  static const _pastTab = 'السابقة';

  /// Creates the controller and starts listening to the orders.
  ///
  /// Parameters: none. Returns: nothing.
  @override
  void initState() {
    super.initState();
    _controller = CustomerOrdersController(uid: widget.uid);
    _controller.start();
  }

  /// Releases the controller when the tab is removed.
  ///
  /// Parameters: none. Returns: nothing.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the underlined tab bar and the two order lists.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: the tab layout.
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TabBar(
                indicatorColor: CustomerColors.darkPanel,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: CustomerColors.cardBorder,
                labelColor: CustomerColors.darkPanel,
                unselectedLabelColor: CustomerColors.secondaryText,
                labelStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(height: 56, text: _currentTab),
                  Tab(height: 56, text: _pastTab),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: TabBarView(
                  children: [
                    CustomerCurrentOrders(controller: _controller),
                    CustomerPastOrders(controller: _controller),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
