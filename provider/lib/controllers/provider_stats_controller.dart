import 'package:firebase_auth/firebase_auth.dart';

import '../models/order.dart';

/// The numbers shown under "quick statistics" on the home page (#36).
class ProviderStats {
  const ProviderStats({required this.completed, required this.completedToday});

  /// All orders this provider has completed.
  final int completed;

  /// Orders this provider completed today.
  final int completedToday;
}

/// CONTROLLER: loads the provider's quick statistics (#36).
class ProviderStatsController {
  ProviderStatsController({OrderModel? model, FirebaseAuth? auth})
      : _model = model ?? OrderModel(),
        _auth = auth ?? FirebaseAuth.instance;

  final OrderModel _model;
  final FirebaseAuth _auth;

  /// Returns null when the user is signed out or the numbers cannot be
  /// read, so the home page simply keeps showing 0.
  Future<ProviderStats?> load() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final results = await Future.wait([
        _model.countCompleted(uid),
        _model.countCompletedToday(uid),
      ]);
      return ProviderStats(completed: results[0], completedToday: results[1]);
    } catch (_) {
      return null;
    }
  }
}
