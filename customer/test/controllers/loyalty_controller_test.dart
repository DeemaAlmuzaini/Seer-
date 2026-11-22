import 'package:flutter_test/flutter_test.dart';
import 'package:customer/controllers/loyalty_controller.dart';
import 'package:customer/models/order.dart';

void main() {
  group('LoyaltyController.countCompleted', () {
    test('counts only completed orders', () {
      final count = LoyaltyController.countCompleted([
        OrderStatus.completed,
        OrderStatus.cancelled,
        OrderStatus.completed,
        OrderStatus.pending,
        OrderStatus.autoCancelled,
      ]);
      expect(count, 2);
    });
  });

  group('LoyaltyProgress', () {
    test('a new customer starts with no cars lit', () {
      const progress = LoyaltyProgress(0);
      expect(progress.filled, 0);
      expect(progress.counter, '0 / 5');
      expect(progress.title, 'مكافأة الولاء');
      expect(progress.message, 'أكمل 5 خدمات واحصل على غسيل مجاني');
    });

    test('lights one car per completed service', () {
      const progress = LoyaltyProgress(2);
      expect(progress.filled, 2);
      expect(progress.counter, '2 / 5');
      expect(progress.message, 'باقي 3 خدمات وتحصل على غسيل مجاني');
    });

    test('uses the dual and singular forms', () {
      expect(
        const LoyaltyProgress(3).message,
        'باقي خدمتان وتحصل على غسيل مجاني',
      );
      expect(
        const LoyaltyProgress(4).message,
        'باقي خدمة واحدة وتحصل على غسيل مجاني',
      );
    });

    test('the fifth service earns a wash and keeps the card full', () {
      const progress = LoyaltyProgress(5);
      expect(progress.justEarned, isTrue);
      expect(progress.filled, 5);
      expect(progress.counter, '5 / 5');
      expect(progress.title, 'مبروك! غسيلك المجاني جاهز');
    });

    test('the sixth service starts a new card', () {
      const progress = LoyaltyProgress(6);
      expect(progress.justEarned, isFalse);
      expect(progress.filled, 1);
    });
  });
}
