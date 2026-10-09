import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/app_colors.dart';
import 'order_card.dart';

/// List of order cards with loading, error and empty states (#24).
class OrdersListView extends StatelessWidget {
  /// Creates the list.
  ///
  /// Parameters: the [orders] to show, the [isLoading] flag, an optional
  /// [errorMessage], the empty state content ([emptyIcon], [emptyTitle],
  /// [emptySubtitle]), [onOrderTap] for opening an order, [onRetry]
  /// for reloading after an error and an optional [onOrderReorder] for
  /// requesting an order again (#21).
  const OrdersListView({
    super.key,
    required this.orders,
    required this.isLoading,
    required this.errorMessage,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onOrderTap,
    required this.onRetry,
    this.onOrderReorder,
  });

  final List<ServiceOrder> orders;
  final bool isLoading;
  final String? errorMessage;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final ValueChanged<ServiceOrder> onOrderTap;
  final VoidCallback onRetry;

  /// Runs when the re-request button of a card is tapped. The button is
  /// hidden on every card when this is null.
  final ValueChanged<ServiceOrder>? onOrderReorder;

  static const _retryLabel = 'إعادة المحاولة';

  /// Builds the state that matches the current data.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: a spinner, an error message, an empty message or the list.
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: CustomerColors.accent),
      );
    }

    final error = errorMessage;
    if (error != null) {
      return _StateMessage(
        icon: Icons.wifi_off_rounded,
        title: error,
        action: TextButton(
          onPressed: onRetry,
          child: const Text(_retryLabel),
        ),
      );
    }

    if (orders.isEmpty) {
      return _StateMessage(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        final reorder = onOrderReorder;
        return OrderCard(
          order: order,
          onTap: () => onOrderTap(order),
          onReorder: reorder == null ? null : () => reorder(order),
        );
      },
    );
  }
}

/// Centered icon and message used for empty and error states.
class _StateMessage extends StatelessWidget {
  /// Creates the message.
  ///
  /// Parameters: [icon] and [title] are required; [subtitle] and [action]
  /// are optional.
  const _StateMessage({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  /// Builds the message.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: a centered column.
  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;
    final actionWidget = action;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: CustomerColors.secondaryText.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: CustomerColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitleText != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: CustomerColors.secondaryText.withValues(alpha: 0.8),
                ),
              ),
            ],
            if (actionWidget != null) ...[
              const SizedBox(height: 12),
              actionWidget,
            ],
          ],
        ),
      ),
    );
  }
}
