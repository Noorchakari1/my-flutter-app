import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/providers/qibla_provider.dart';
import '../widgets/compass_widget.dart';
import '../widgets/qibla_indicator.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    final language = ref.read(themeNotifierProvider).currentLanguage;
    
    String getText(String key) {
      Map<String, String> textMap;
      switch (language) {
        case 'pashto':
          textMap = AppConstants.pashtoText;
          break;
        case 'persian':
          textMap = AppConstants.persianText;
          break;
        default:
          textMap = AppConstants.englishText;
      }
      return textMap[key] ?? key;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(getText('locationPermissionRequired')),
        content: Text(getText('enableLocationServices')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(getText('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final notifier = ref.read(qiblaNotifierProvider.notifier);
              await notifier.requestLocationPermission();
            },
            child: Text(getText('enableLocationServices')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(themeNotifierProvider).currentLanguage;
    final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

    // Helper function to get localized text
    String getText(String key) {
      Map<String, String> textMap;
      switch (language) {
        case 'pashto':
          textMap = AppConstants.pashtoText;
          break;
        case 'persian':
          textMap = AppConstants.persianText;
          break;
        default:
          textMap = AppConstants.englishText;
      }
      return textMap[key] ?? key;
    }

    return Scaffold(
      backgroundColor: isDarkMode 
          ? const Color(0xFF121212) 
          : AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: getText('qiblaCompass'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(qiblaNotifierProvider.notifier).refreshLocation();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Compass Widget
            const Center(
              child: CompassWidget(),
            ),
            
            const SizedBox(height: 20),
            
            // Qibla Information
            const QiblaIndicator(),
            
            const SizedBox(height: 20),
            
            // Calibration Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCalibrationDialog(),
                  icon: const Icon(Icons.tune),
                  label: Text(getText('calibrateCompass')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCalibrationDialog() {
    final language = ref.read(themeNotifierProvider).currentLanguage;
    
    String getText(String key) {
      Map<String, String> textMap;
      switch (language) {
        case 'pashto':
          textMap = AppConstants.pashtoText;
          break;
        case 'persian':
          textMap = AppConstants.persianText;
          break;
        default:
          textMap = AppConstants.englishText;
      }
      return textMap[key] ?? key;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(getText('calibrateCompass')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.phone_android,
              size: 64,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              getText('calibrationInstructions'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Animation or illustration could be added here
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '∞',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(getText('back')),
          ),
        ],
      ),
    );
  }
}
