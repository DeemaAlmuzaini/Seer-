import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/customer_orders_model.dart';
import '../models/order.dart';

/// CONTROLLER for the customer's orders pages (user stories #24-#26).
class CustomerOrdersController extends ChangeNotifier {
  /// Creates the controller.
  ///
  /// Parameters: [uid] is the signed-in customer's id; [model] can be
  /// injected in tests.
  CustomerOrdersController({
    required this.uid,
    CustomerOrdersModel? model,
  }) : _model = model ?? CustomerOrdersModel();

  final String uid;
  final CustomerOrdersModel _model;
  StreamSubscription<List<ServiceOrder>>? _subscription;

  List<ServiceOrder> orders = [];
  bool isLoading = true;
  String? errorMessage;

  static const _loadError =
      'تعذّر تحميل الطلبات. تحقق من اتصالك بالإنترنت ثم حاول مرة أخرى.';

  /// Statuses of orders that are still open (waiting or being served).
  static const currentStatuses = {
    OrderStatus.pending,
    OrderStatus.accepted,
    OrderStatus.onTheWay,
    OrderStatus.arrived,
    OrderStatus.inProgress,
  };

  /// Returns the open orders, newest first.
  List<ServiceOrder> get currentOrders =>
      orders.where((order) => currentStatuses.contains(order.status)).toList();

  /// Returns the completed, cancelled and rejected orders, newest first.
  List<ServiceOrder> get pastOrders =>
      orders.where((order) => !currentStatuses.contains(order.status)).toList();

  /// Starts (or restarts) listening to the customer's orders.
  ///
  /// Parameters: none.
  /// Returns: nothing; listeners are notified whenever the list, the
  /// loading state or the error message changes.
  void start() {
    _subscription?.cancel();
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _subscription = _model.watchCustomerOrders(uid).listen(
      (result) {
        orders = result;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        isLoading = false;
        errorMessage = _loadError;
        notifyListeners();
      },
    );
  }

  /// Streams one order for the details page.
  ///
  /// Parameters: [orderId] is the order document id.
  /// Returns: a stream of the order, or null once it no longer exists.
  Stream<ServiceOrder?> watchOrder(String orderId) =>
      _model.watchOrder(orderId);

  /// Loads the provider assigned to an order.
  ///
  /// Parameters: [providerId] is the provider's user id.
  /// Returns: the provider summary, or null if it cannot be found.
  Future<AssignedProvider?> getAssignedProvider(String providerId) =>
      _model.getAssignedProvider(providerId);

  /// Stops listening to Firestore and releases the controller.
  ///
  /// Parameters: none. Returns: nothing.
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
