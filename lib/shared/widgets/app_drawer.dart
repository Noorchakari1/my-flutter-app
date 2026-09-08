import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/routes.dart';
import '../../core/providers/theme_provider.dart';
import '../../shared/constants/app_constants.dart';

/// The application navigation menu shown from the upper-left menu button.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  String _homeRoute(String language) => switch (language) {
        'pashto' => AppConstants.pashtoRoute,
        'persian' => AppConstants.persianRoute,
        _ => AppConstants.englishRoute,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final isGolden = themeState.isGolden;
    final primary = isGolden ? const Color(0xFF15120E) : AppConstants.primaryColor;
    final accent = isGolden ? const Color(0xFFB08D57) : Colors.white;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                color: primary,
                child: Row(
                  children: [
                    Image.asset(AppConstants.logoPath, width: 46, height: 46, color: Colors.white),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'AOP',
                        style: TextStyle(color: accent, fontSize: 21, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _item(context, Icons.home_outlined, 'Home', _homeRoute(themeState.currentLanguage)),
                    _item(context, Icons.newspaper_outlined, 'News', Routes.news),
                    _item(context, Icons.work_outline, 'Job opportunities', Routes.jobOpportunities),
                    _item(context, Icons.account_balance_outlined, 'Ministries', Routes.ministries),
                    _item(context, Icons.business_outlined, 'Independent directorates', Routes.independentDirectorates),
                    _item(context, Icons.location_city_outlined, 'Provinces', Routes.provinces),
                    _item(context, Icons.explore_outlined, 'Qibla compass', Routes.qibla),
                    _item(context, Icons.cloud_outlined, 'Weather', Routes.weather),
                    const Divider(height: 24),
                    _item(context, Icons.bookmark_outline, 'Saved news', Routes.savedNews),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.of(context).pushNamed(route);
        }
      },
    );
  }
}
