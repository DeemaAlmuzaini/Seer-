import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/customer_orders_controller.dart';
import '../models/order.dart';
import '../theme/app_colors.dart';

/// Cancel bar pinned to the bottom of the order details (#20). It is
/// shown while the order is waiting for a provider, and for a short time
/// after a provider accepts it, with a countdown inside the button.
class CancelOrderSection extends StatefulWidget {
  /// Creates the section.
  ///
  /// Parameters: [order] is the order shown on the page; [controller]
  /// checks the cancel window and cancels the order.
  const CancelOrderSection({
    super.key,
    required this.order,
    required this.controller,
  });

  final ServiceOrder order;
  final CustomerOrdersController controller;

  /// Creates the section state.
  ///
  /// Parameters: none. Returns: the state object.
  @override
  State<CancelOrderSection> createState() => _CancelOrderSectionState();
}

class _CancelOrderSectionState extends State<CancelOrderSection> {
  static const _buttonLabel = 'إلغاء الطلب';
  static const _pendingHint = 'يمكنك إلغاء الطلب قبل أن يقبله مزود الخدمة';
  static const _dialogTitle = 'إلغاء الطلب';
  static const _dialogMessage = 'هل أنت متأكد من إلغاء هذا الطلب؟';
  static const _dialogBack = 'تراجع';
  static const _dialogConfirm = 'نعم، إلغاء';
  static const _tick = Duration(seconds: 1);
  static const _height = 54.0;
  static const _radius = 14.0;

  Timer? _timer;
  bool _cancelling = false;

  /// Starts the countdown when the order has a cancel deadline.
  ///
  /// Parameters: none. Returns: nothing.
  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  /// Restarts the countdown when the order changes, for example when a
  /// provider accepts it while the page is open.
  ///
  /// Parameters: [oldWidget] is the previous version of this widget.
  /// Returns: nothing.
  @override
  void didUpdateWidget(CancelOrderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTimer();
  }

  /// Stops the countdown when the page closes.
  ///
  /// Parameters: none. Returns: nothing.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Runs a one-second timer only while there is time left to cancel, so
  /// the countdown updates and the button hides itself when time is up.
  ///
  /// Parameters: none. Returns: nothing.
  void _syncTimer() {
    final hasDeadline =
        widget.controller.canCancel(widget.order) &&
        widget.controller.cancelTimeLeft(widget.order) != null;
    if (hasDeadline && _timer == null) {
      _timer = Timer.periodic(_tick, (_) {
        if (!mounted) return;
        setState(() {});
        if (!widget.controller.canCancel(widget.order)) {
          _timer?.cancel();
          _timer = null;
        }
      });
    } else if (!hasDeadline) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// Builds a bar pinned to the bottom of the page with the red cancel
  /// button and the countdown inside it, or nothing when the order can no
  /// longer be cancelled.
  ///
  /// Parameters: [context] is the build context.
  /// Returns: the bar, or an empty box.
  @override
  Widget build(BuildContext context) {
    if (!widget.controller.canCancel(widget.order)) {
      return const SizedBox.shrink();
    }
    final timeLeft = widget.controller.cancelTimeLeft(widget.order);
    final progress = widget.controller.cancelProgress(widget.order);
    final radius = BorderRadius.circular(_radius);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: const BoxDecoration(
        color: CustomerColors.background,
        border: Border(top: BorderSide(color: CustomerColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: AppStatusColors.error,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _cancelling ? null : _confirmAndCancel,
                child: SizedBox(
                  height: _height,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      if (progress != null)
                        Positioned.fill(
                          child: FractionallySizedBox(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: progress,
                            child: ColoredBox(
                              color: CustomerColors.background.withValues(
                                alpha: 0.18,
                              ),
                            ),
                          ),
                        ),
                      if (timeLeft != null)
                        PositionedDirectional(
                          end: 16,
                          child: Text(
                            _formatDuration(timeLeft),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: CustomerColors.background,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _cancelling
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: CustomerColors.background,
                                    ),
                                  )
                                : const Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                    color: CustomerColors.background,
                                  ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                _buttonLabel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: CustomerColors.background,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (timeLeft == null) ...[
              const SizedBox(height: 8),
              const Text(
                _pendingHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: CustomerColors.secondaryText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Asks the customer to confirm, then cancels the order and shows an
  /// error message when it fails. On success the page updates by itself,
  /// because it listens to the order.
  ///
  /// Parameters: none. Returns: a future that completes when done.
  Future<void> _confirmAndCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: CustomerColors.background,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: CustomerColors.primaryText,
          ),
          contentTextStyle: const TextStyle(
            fontSize: 14,
            color: CustomerColors.secondaryText,
          ),
          title: const Text(_dialogTitle),
          content: const Text(_dialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: CustomerColors.accent,
              ),
              child: const Text(
                _dialogBack,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppStatusColors.error,
                foregroundColor: CustomerColors.background,
                shape: const StadiumBorder(),
              ),
              child: const Text(
                _dialogConfirm,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    final error = await widget.controller.cancelOrder(widget.order.id);
    if (!mounted) return;
    setState(() => _cancelling = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  /// Formats a duration as m:ss.
  ///
  /// Parameters: [value] is the time left.
  /// Returns: the minutes and two-digit seconds.
  static String _formatDuration(Duration value) {
    final minutes = value.inMinutes;
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
