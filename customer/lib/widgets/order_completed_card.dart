import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/app_colors.dart';
import 'order_display.dart';

/// Summary shown in the order details once the order is completed (#25).
/// It replaces the step timeline, since every step is already done.
class OrderCompletedCard extends StatelessWidget {
  /// Creates the summary.
  ///
  /// Parameters: [order] is the completed order.
  const OrderCompletedCard({super.key, required this.order});

  final ServiceOrder order;

  static const _completedOn = 'تم الإكمال';
  static const _atTime = 'عند الساعة';
  static const _title = 'تم إكمال الطلب';
  static const _message = 'سعدنا بخدمتك.';
  static const _iconSize = 76.0;

  /// Builds the completion time card above the main summary card.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: a column with both cards.
  @override
  Widget build(BuildContext context) {
    final completedAt = order.completedAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (completedAt != null) ...[
          _timeCard(completedAt),
          const SizedBox(height: 14),
        ],
        _summaryCard(),
      ],
    );
  }

  /// Builds the small card with the completion date and time.
  ///
  /// Parameters: [completedAt] is when the provider finished the order.
  /// Returns: a tinted card.
  Widget _timeCard(DateTime completedAt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppStatusColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_completedOn ${OrderFormat.date(completedAt)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppStatusColors.success,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_atTime ${OrderFormat.time(completedAt)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CustomerColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main card: check mark, full progress bar, title and message.
  ///
  /// Parameters: none.
  /// Returns: a bordered card.
  Widget _summaryCard() {
    final steps = OrderProgress.steps.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CustomerColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: _iconSize + 16,
            height: _iconSize + 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppStatusColors.success.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: Container(
              width: _iconSize,
              height: _iconSize,
              decoration: const BoxDecoration(
                color: AppStatusColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: _iconSize * 0.6,
                color: CustomerColors.background,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              for (var i = 0; i < steps; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppStatusColors.success,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            _title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CustomerColors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            _message,
            style: TextStyle(fontSize: 15, color: CustomerColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
