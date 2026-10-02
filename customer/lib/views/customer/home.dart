import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../models/service_catalog.dart';
import 'request_service_page.dart';

/// VIEW: the customer home page.
/// Shows the AI assistant card (#11, not built yet) and the services menu
/// (#12). Tapping a service opens the request page, where the customer picks
/// the service option (#13) and the vehicle (#14).
class Home extends StatelessWidget {
  const Home({super.key, required this.uid});

  final String uid;

  static const _icons = <String, IconData>{
    'battery': Icons.battery_charging_full,
    'fuel': Icons.local_gas_station,
    'tires': Icons.tire_repair,
    'towing': Icons.local_shipping_outlined,
  };

  Future<void> _openService(BuildContext context, String categoryId) async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => RequestServicePage(uid: uid, categoryId: categoryId),
      ),
    );
    if (message == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _aiCard(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Text(
              'اطلب خدمة',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _servicesGrid(context),
        ],
      ),
    );
  }

  /// The AI assistant card (#11), as written in the original home page.
  /// The AI assistant card (#11), as written in the original home page.
  Widget _aiCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'مو متأكد وش المشكلة؟',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'صف المشكلة لمساعد Seer الذكي',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(color: AppColors.cardBorder, fontSize: 15),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textSecondary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                const Expanded(
                  child: Text(
                    'صف المشكلة...',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: AppColors.cardBorder),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.accent),
                  onPressed: () {
                    // Later: open the AI page (#11)
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  /// The services menu (#12).
  Widget _servicesGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: ServiceCatalog.categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        final category = ServiceCatalog.categories[index];

        return Material(
          color: AppColors.cardFill,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _openService(context, category.id),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _icons[category.id] ?? Icons.build_outlined,
                  size: 36,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 8),
                Text(
                  category.shortLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
