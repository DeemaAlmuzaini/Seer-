import '../models/customer_orders_model.dart';
import '../models/order.dart';

/// The customer's progress on the loyalty card (#68, #70).
class LoyaltyProgress {
  /// Takes the number of completed services; creates the progress.
  const LoyaltyProgress(this.completed);

  /// Completed services needed for one free car wash (#69).
  static const goal = 5;

  /// Every completed service the customer has ever had.
  final int completed;

  /// Takes no inputs; returns true right after a card was completed.
  bool get justEarned => completed > 0 && completed % goal == 0;

  /// Takes no inputs; returns how many cars on the card are lit. A full
  /// card stays lit (6 / 6) until the next service starts a new one.
  int get filled => justEarned ? goal : completed % goal;

  /// Takes no inputs; returns how many services are left for the next wash.
  int get remaining => goal - filled;

  /// Takes no inputs; returns the card title.
  String get title => justEarned ? 'مبروك! غسيلك المجاني جاهز' : 'مكافأة الولاء';

  /// Takes no inputs; returns the line under the title.
  String get message {
    if (justEarned) return 'أكملت $goal خدمات، استخدم المكافأة الآن';
    if (filled == 0) return 'أكمل $goal خدمات واحصل على غسيل مجاني';
    switch (remaining) {
      case 1:
        return 'باقي خدمة واحدة وتحصل على غسيل مجاني';
      case 2:
        return 'باقي خدمتان وتحصل على غسيل مجاني';
      default:
        return 'باقي $remaining خدمات وتحصل على غسيل مجاني';
    }
  }

  /// Takes no inputs; returns the "3 / 6" counter.
  String get counter => '$filled / $goal';

  /// Takes no inputs; returns the screen reader label for the timeline.
  String get semanticsLabel => 'أكملت $filled من $goal خدمات';
}

/// CONTROLLER: counts completed orders for the loyalty card (#68).
class LoyaltyController {
  /// Takes an optional model for tests; creates the controller.
  LoyaltyController({CustomerOrdersModel? model})
    : _model = model ?? CustomerOrdersModel();

  final CustomerOrdersModel _model;

  /// Takes order statuses; returns how many of them are completed.
  static int countCompleted(Iterable<String> statuses) =>
      statuses.where((status) => status == OrderStatus.completed).length;

  /// Takes the customer id; returns a live stream of their progress.
  Stream<LoyaltyProgress> watch(String uid) => _model
      .watchCustomerOrders(uid)
      .map(
        (orders) => LoyaltyProgress(
          countCompleted(orders.map((order) => order.status)),
        ),
      );
}
