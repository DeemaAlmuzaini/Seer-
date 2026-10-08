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

  static const _title = 'طلباتي';
  static const _subtitle = 'تابع حالة طلباتك لحظة بلحظة';
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

  /// Builds the title, the tab switcher and the two order lists.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: the tab layout.
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: CustomerColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: CustomerColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: CustomerColors.fieldFill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: CustomerColors.darkPanel,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: CustomerColors.background,
                  unselectedLabelColor: CustomerColors.secondaryText,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(
                      height: 44,
                      child: _TabLabel(
                        text: _currentTab,
                        count: _controller.isLoading
                            ? 0
                            : _controller.currentOrders.length,
                      ),
                    ),
                    const Tab(height: 44, text: _pastTab),
                  ],
                ),
              ),
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
    );
  }
}

/// Tab text with an optional count badge.
class _TabLabel extends StatelessWidget {
  /// Creates the label.
  ///
  /// Parameters: the tab [text] and the [count] shown in the badge;
  /// no badge is shown when [count] is zero.
  const _TabLabel({required this.text, required this.count});

  final String text;
  final int count;

  /// Builds the text and badge.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: a compact row.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(minWidth: 22),
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CustomerColors.accent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CustomerColors.background,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
