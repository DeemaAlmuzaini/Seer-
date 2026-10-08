import 'package:cloud_firestore/cloud_firestore.dart';

import 'order.dart';

/// Summary of the service provider assigned to an order (#26).
class AssignedProvider {
  /// Creates a provider summary.
  ///
  /// Parameters: the provider's [fullName], vehicle details
  /// ([vehicleTitle], [vehicleColor], [plateNumber], [plateNumberLatin]) and
  /// an optional [rating].
  const AssignedProvider({
    required this.fullName,
    required this.vehicleTitle,
    required this.vehicleColor,
    required this.plateNumber,
    this.plateNumberLatin = '',
    this.rating,
  });

  final String fullName;
  final String vehicleTitle;
  final String vehicleColor;
  final String plateNumber;

  /// The same plate with Latin letters, e.g. "4821 RSE".
  final String plateNumberLatin;

  /// Average rating, or null when the provider has not been rated yet.
  final num? rating;

  /// Builds a summary from a provider document.
  ///
  /// Parameters: [map] is the raw data of a document in `providers`.
  /// Returns: an [AssignedProvider]; missing text fields become empty strings.
  factory AssignedProvider.fromMap(Map<String, dynamic> map) {
    String read(String key) => (map[key] ?? '').toString().trim();

    final vehicleParts = [
      read('vehicleBrand'),
      read('vehicleModel'),
      read('vehicleYear'),
    ].where((part) => part.isNotEmpty);

    return AssignedProvider(
      fullName: '${read('firstName')} ${read('lastName')}'.trim(),
      vehicleTitle: vehicleParts.join(' '),
      vehicleColor: read('vehicleColor'),
      plateNumber: read('plateNumberArabic'),
      plateNumberLatin: read('plateNumberLatin'),
      rating: map['rating'] as num?,
    );
  }
}

/// MODEL: reads a customer's orders and their assigned providers.
class CustomerOrdersModel {
  /// Creates the model.
  ///
  /// Parameters: [firestore] can be injected in tests; the default
  /// Firestore instance is used otherwise.
  CustomerOrdersModel({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  static const _ordersCollection = 'orders';
  static const _providersCollection = 'providers';
  static const _customerIdField = 'customerId';

  /// Returns the injected Firestore instance, or the default one.
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  /// Streams every order placed by one customer, newest first.
  ///
  /// Sorting is done here rather than in the query so Firestore does not
  /// need a composite index.
  ///
  /// Parameters: [customerId] is the customer's user id.
  /// Returns: a stream that emits the full, sorted list on every change.
  Stream<List<ServiceOrder>> watchCustomerOrders(String customerId) {
    return _firestore
        .collection(_ordersCollection)
        .where(_customerIdField, isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => ServiceOrder.fromMap(doc.id, doc.data()))
          .toList();
      orders.sort(_newestFirst);
      return orders;
    });
  }

  /// Streams a single order so its details stay up to date.
  ///
  /// Parameters: [orderId] is the order document id.
  /// Returns: a stream of the order, or null once it no longer exists.
  Stream<ServiceOrder?> watchOrder(String orderId) {
    return _firestore
        .collection(_ordersCollection)
        .doc(orderId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      return data == null ? null : ServiceOrder.fromMap(doc.id, data);
    });
  }

  /// Loads the provider assigned to an order.
  ///
  /// Parameters: [providerId] is the provider's user id.
  /// Returns: the provider summary, or null if the document does not exist.
  Future<AssignedProvider?> getAssignedProvider(String providerId) async {
    final doc =
        await _firestore.collection(_providersCollection).doc(providerId).get();
    final data = doc.data();
    return data == null ? null : AssignedProvider.fromMap(data);
  }

  /// Compares two orders by creation time, newest first.
  ///
  /// Orders still waiting for their server timestamp are placed first.
  ///
  /// Parameters: the two orders [a] and [b] being compared.
  /// Returns: a negative number when [a] should come before [b].
  static int _newestFirst(ServiceOrder a, ServiceOrder b) {
    final aTime = a.createdAt;
    final bTime = b.createdAt;
    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return -1;
    if (bTime == null) return 1;
    return bTime.compareTo(aTime);
  }
}
