import 'package:flutter/material.dart';

import '../controllers/address_controller.dart';
import '../controllers/provider_requests_controller.dart';
import '../models/order.dart';
import '../theme/order_colors.dart';
import '../widgets/order_display.dart';
import 'request_details_page.dart';

/// Provider's available requests, using the Customer OrderCard presentation.
/// Request loading, expiry, navigation and acceptance logic remain unchanged.
class AvailableRequests extends StatelessWidget {
  const AvailableRequests({
    super.key,
    required this.controller,
    required this.addresses,
    required this.onAccepted,
  });

  final ProviderRequestsController controller;
  final AddressController addresses;
  final VoidCallback onAccepted;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      if (controller.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      final orders = controller.availableRequests;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'الطلبات المتاحة (${orders.length})',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'تحديث الموقع والمسافة',
                  onPressed: controller.locating
                      ? null
                      : controller.refreshLocation,
                  icon: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'لا توجد طلبات متاحة حالياً',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _AvailableRequestCard(
                        key: ValueKey(order.id),
                        order: order,
                        countdown: controller.countdown(order),
                        distance: controller.distanceText(order),
                        onTap: () => _openDetails(context, order.id),
                      );
                    },
                  ),
          ),
        ],
      );
    },
  );

  Future<void> _openDetails(BuildContext context, String orderId) async {
    final accepted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailsPage(
          orderId: orderId,
          controller: controller,
          addresses: addresses,
        ),
      ),
    );
    if (context.mounted && accepted == true) onAccepted();
  }
}

/// Visual-only counterpart of Customer's OrderCard summary and footer.
class _AvailableRequestCard extends StatelessWidget {
  const _AvailableRequestCard({
    super.key,
    required this.order,
    required this.countdown,
    required this.distance,
    required this.onTap,
  });

  final ServiceOrder order;
  final String countdown;
  final String distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Material(
      color: CustomerColors.background,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: CustomerColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ServiceIconTile(
                      categoryId: order.serviceCategoryId,
                      status: order.status,
                      size: 72,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.serviceCategoryLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: CustomerColors.primaryText,
                            ),
                          ),
                          Text(
                            order.serviceOptionLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CustomerColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            OrderStatusStyle.labelOf(order.status),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: OrderStatusStyle.textColorOf(order.status),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _MetaLine(
                            icon: Icons.access_time_rounded,
                            text: '${OrderFormat.date(order.createdAt)}  ·  '
                                '${OrderFormat.time(order.createdAt)}',
                          ),
                          const SizedBox(height: 4),
                          _MetaLine(
                            icon: Icons.receipt_long_outlined,
                            text: 'رقم الطلب ${OrderFormat.reference(order.id)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 56),
                      child: Text(
                        OrderFormat.price(order.estimatedPrice),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: CustomerColors.primaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: CustomerColors.cardBorder),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.near_me_outlined,
                          size: 16,
                          color: CustomerColors.secondaryText,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'المسافة إلى المركبة: $distance',
                            style: const TextStyle(
                              fontSize: 12,
                              color: CustomerColors.secondaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            countdown,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: CustomerColors.accent,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'اضغط لعرض الموقع وتفاصيل الطلب',
                            style: TextStyle(
                              fontSize: 12,
                              color: CustomerColors.secondaryText,
                            ),
                          ),
                        ),
                        Text(
                          'التفاصيل',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CustomerColors.accent,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: CustomerColors.accent,
                        ),
                      ],
                    ),
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

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 15, color: CustomerColors.secondaryText),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: CustomerColors.secondaryText,
          ),
        ),
      ),
    ],
  );
}
