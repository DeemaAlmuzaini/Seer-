import 'package:cloud_firestore/cloud_firestore.dart';

/// The status values an order moves through. The provider app updates these
/// in #44, so both apps must use exactly these strings.
class OrderStatus {
  OrderStatus._();

  static const pending = 'pending';     // waiting for a provider (#18)
  static const accepted = 'accepted';   // a provider accepted it (#39)
  static const onTheWay = 'onTheWay';
  static const arrived = 'arrived';
  static const inProgress = 'inProgress';
  static const completed = 'completed';
  static const cancelled = 'cancelled'; // #20
}

/// MODEL: one service request.
///
/// The vehicle and service details are COPIED into the order instead of only
/// keeping ids, so an order still reads correctly later even if the customer
/// edits or deletes that vehicle (#9, #10).
class ServiceOrder {
  const ServiceOrder({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.vehicleTitle,
    required this.vehiclePlateArabic,
    required this.vehiclePlateLatin,
    required this.serviceCategoryId,
    required this.serviceCategoryLabel,
    required this.serviceOptionId,
    required this.serviceOptionLabel,
    required this.serviceBranch,
    required this.note,
    required this.estimatedPrice,
    required this.status,
    this.finalPrice,
    this.createdAt,
    this.pickupLocation,
    this.dropoffLocation,
    this.providerId,
  });

  final String id;
  final String customerId;

  // Vehicle (#14)
  final String vehicleId;
  final String vehicleTitle;        // "تويوتا كامري 2022"
  final String vehiclePlateArabic;
  final String vehiclePlateLatin;

  // Service (#13)
  final String serviceCategoryId;   // 'battery'
  final String serviceCategoryLabel;
  final String serviceOptionId;     // 'activation'
  final String serviceOptionLabel;
  final String serviceBranch;       // what the provider app matches on

  /// The customer's note (#23). Empty when none was written.
  final String note;

  /// What the customer was shown before confirming (#17), in riyals.
  /// null when this service has no price in lookup_data yet.
  final num? estimatedPrice;

  /// TODO(#46): what was actually collected, set by the provider at the end.
  final num? finalPrice;

  final String status;
  final DateTime? createdAt;

  /// TODO(#15): the vehicle's current location, set by the location story.
  /// Expected shape: {'lat': double, 'lng': double, 'address': String}
  final Map<String, dynamic>? pickupLocation;

  /// TODO(#16): the drop-off location, towing only.
  final Map<String, dynamic>? dropoffLocation;

  /// TODO(#18): filled in when a provider is matched / accepts.
  final String? providerId;

  factory ServiceOrder.fromMap(String id, Map<String, dynamic> map) {
    return ServiceOrder(
      id: id,
      customerId: (map['customerId'] ?? '') as String,
      vehicleId: (map['vehicleId'] ?? '') as String,
      vehicleTitle: (map['vehicleTitle'] ?? '') as String,
      vehiclePlateArabic: (map['vehiclePlateArabic'] ?? '') as String,
      vehiclePlateLatin: (map['vehiclePlateLatin'] ?? '') as String,
      serviceCategoryId: (map['serviceCategoryId'] ?? '') as String,
      serviceCategoryLabel: (map['serviceCategoryLabel'] ?? '') as String,
      serviceOptionId: (map['serviceOptionId'] ?? '') as String,
      serviceOptionLabel: (map['serviceOptionLabel'] ?? '') as String,
      serviceBranch: (map['serviceBranch'] ?? '') as String,
      note: (map['note'] ?? '') as String,
      estimatedPrice: map['estimatedPrice'] as num?,
      finalPrice: map['finalPrice'] as num?,
      status: (map['status'] ?? OrderStatus.pending) as String,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      pickupLocation: (map['pickupLocation'] as Map?)?.cast<String, dynamic>(),
      dropoffLocation: (map['dropoffLocation'] as Map?)?.cast<String, dynamic>(),
      providerId: map['providerId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'vehicleId': vehicleId,
      'vehicleTitle': vehicleTitle,
      'vehiclePlateArabic': vehiclePlateArabic,
      'vehiclePlateLatin': vehiclePlateLatin,
      'serviceCategoryId': serviceCategoryId,
      'serviceCategoryLabel': serviceCategoryLabel,
      'serviceOptionId': serviceOptionId,
      'serviceOptionLabel': serviceOptionLabel,
      'serviceBranch': serviceBranch,
      'note': note,
      'estimatedPrice': estimatedPrice,
      'finalPrice': finalPrice,
      'status': status,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'providerId': providerId,
    };
  }
}

/// Talks to the database.
class OrderModel {
  OrderModel({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  /// Creates the order and returns its new id.
  /// createdAt is set by the server, so it does not depend on the phone clock.
  Future<String> createOrder(ServiceOrder order) async {
    final ref = await _orders.add({
      ...order.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
