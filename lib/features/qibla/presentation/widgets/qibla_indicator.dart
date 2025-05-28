import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../data/providers/qibla_provider.dart';

class QiblaIndicator extends ConsumerWidget {
  const QiblaIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaState = ref.watch(qiblaNotifierProvider);
    final isPointingToQibla = ref.watch(isPointingToQiblaProvider);
    final distance = ref.watch(distanceToKaabaProvider);
    final userLocation = ref.watch(userLocationProvider);
    final language = ref.watch(themeNotifierProvider).currentLanguage;

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

    return qiblaState.when(
      data: (qiblaModel) {
        if (qiblaModel == null) {
          return _buildErrorCard(getText('compassNotAvailable'));
        }

        if (!qiblaModel.isLocationAvailable) {
          return _buildErrorCard(getText('locationPermissionRequired'));
        }

        if (!qiblaModel.isCompassAvailable) {
          return _buildErrorCard(getText('compassNotAvailable'));
        }

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPointingToQibla ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPointingToQibla 
                          ? getText('qiblaDirection')
                          : getText('qiblaDirection'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPointingToQibla ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Qibla angle
                _buildInfoRow(
                  getText('qiblaAngle'),
                  '${qiblaModel.qiblaAngle.toStringAsFixed(1)}°',
                  Icons.explore,
                ),
                
                const SizedBox(height: 12),
                
                // Distance to Kaaba
                _buildInfoRow(
                  getText('distanceToKaaba'),
                  '${distance.toStringAsFixed(0)} ${getText('kilometers')}',
                  Icons.straighten,
                ),
                
                const SizedBox(height: 12),
                
                // User location
                _buildInfoRow(
                  getText('yourLocation'),
                  userLocation,
                  Icons.location_on,
                ),
                
                const SizedBox(height: 20),
                
                // Calibration instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          getText('calibrationInstructions'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => _buildLoadingCard(),
      error: (error, _) => _buildErrorCard(getText('generalError')),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppConstants.primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppConstants.primaryColor,
              ),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
