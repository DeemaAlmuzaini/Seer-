import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/app_colors.dart';
import 'order_display.dart';

/// Card that summarizes one order in the orders list (#24).
class OrderCard extends StatelessWidget {
  /// Creates the card.
  ///
  /// Parameters: [order] is the order to show; [onTap] runs when the card
  /// is tapped.
  const OrderCard({super.key, required this.order, required this.onTap});

  final ServiceOrder order;
  final VoidCallback onTap;

  static const _searchingMessage = 'نبحث عن أقرب مزود خدمة متاح لك';
  static const _cancelledMessage = 'تم إلغاء هذا الطلب';
  static const _detailsLabel = 'التفاصيل';

  /// Builds the card with the service, status, progress, date and time.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: a tappable bordered card.
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: CustomerColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: 14),
              _middle(),
              const SizedBox(height: 14),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the top row: service icon, service names and status chip.
  ///
  /// Parameters: none.
  /// Returns: a row widget.
  Widget _header() {
    return Row(
      children: [
        ServiceIconTile(
          categoryId: order.serviceCategoryId,
          status: order.status,
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
              const SizedBox(height: 2),
              Text(
                order.serviceOptionLabel,
                style: const TextStyle(
                  fontSize: 13,
                  color: CustomerColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        OrderStatusChip(status: order.status),
      ],
    );
  }

  /// Builds the middle part: a progress bar for accepted orders, or a
  /// short message for waiting and cancelled orders.
  ///
  /// Parameters: none.
  /// Returns: the progress bar or a message box.
  Widget _middle() {
    if (OrderStatusStyle.cancelledStatuses.contains(order.status)) {
      return _MessageBox(
        text: _cancelledMessage,
        dotColor: OrderStatusStyle.colorOf(order.status),
      );
    }
    if (OrderProgress.indexOf(order.status) < 0) {
      return _MessageBox(
        text: _searchingMessage,
        dotColor: OrderStatusStyle.colorOf(order.status),
      );
    }
    return _ProgressBar(status: order.status);
  }

  /// Builds the bottom row: date, time and a details hint.
  ///
  /// Parameters: none.
  /// Returns: a row separated from the content by a top border.
  Widget _footer() {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: CustomerColors.cardBorder)),
      ),
      child: Row(
        children: [
          _InfoItem(
            icon: Icons.calendar_today_outlined,
            text: OrderFormat.date(order.createdAt),
          ),
          const SizedBox(width: 16),
          _InfoItem(
            icon: Icons.access_time_rounded,
            text: OrderFormat.time(order.createdAt),
          ),
          const Spacer(),
          const Text(
            _detailsLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CustomerColors.accent,
            ),
          ),
          const Icon(
            Icons.chevron_left_rounded,
            size: 18,
            color: CustomerColors.accent,
          ),
        ],
      ),
    );
  }
}

/// Five-segment bar that shows how far an accepted order has gone.
class _ProgressBar extends StatelessWidget {
  /// Creates the bar.
  ///
  /// Parameters: [status] is the order's current status.
  const _ProgressBar({required this.status});

  final String status;

  /// Builds the segments and their labels.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: a column with the segments above the step labels.
  @override
  Widget build(BuildContext context) {
    final current = OrderProgress.indexOf(status);
    final activeColor = OrderStatusStyle.colorOf(status);
    final steps = OrderProgress.steps;

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i <= current ? activeColor : CustomerColors.cardBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < steps.length; i++)
              Text(
                OrderProgress.shortLabelOf(steps[i]),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: i == current ? FontWeight.w700 : FontWeight.w500,
                  color: i == current
                      ? activeColor
                      : i < current
                          ? CustomerColors.primaryText
                          : CustomerColors.secondaryText,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Filled box with a colored dot and a short message.
class _MessageBox extends StatelessWidget {
  /// Creates the box.
  ///
  /// Parameters: the [text] to show and the [dotColor] next to it.
  const _MessageBox({required this.text, required this.dotColor});

  final String text;
  final Color dotColor;

  /// Builds the box.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: a rounded container with a dot and the message.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CustomerColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: CustomerColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon followed by a short piece of text.
class _InfoItem extends StatelessWidget {
  /// Creates the item.
  ///
  /// Parameters: [icon] to show and the [text] next to it.
  const _InfoItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  /// Builds the icon and text in a row.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: a compact row.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: CustomerColors.secondaryText),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: CustomerColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
