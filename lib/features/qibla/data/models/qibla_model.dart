import 'dart:math';

/// Model representing Qibla direction and related information
class QiblaModel {
  final double qiblaAngle;
  final double compassAngle;
  final double userLatitude;
  final double userLongitude;
  final double distanceToKaaba;
  final bool isLocationAvailable;
  final bool isCompassAvailable;

  const QiblaModel({
    required this.qiblaAngle,
    required this.compassAngle,
    required this.userLatitude,
    required this.userLongitude,
    required this.distanceToKaaba,
    required this.isLocationAvailable,
    required this.isCompassAvailable,
  });

  /// Kaaba coordinates (Mecca, Saudi Arabia)
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Calculate the bearing from user location to Kaaba
  static double calculateQiblaBearing(double userLat, double userLng) {
    final double lat1Rad = userLat * (pi / 180);
    const double lat2Rad = kaabaLatitude * (pi / 180);
    final double deltaLngRad = (kaabaLongitude - userLng) * (pi / 180);

    final double y = sin(deltaLngRad) * cos(lat2Rad);
    final double x = cos(lat1Rad) * sin(lat2Rad) -
                     sin(lat1Rad) * cos(lat2Rad) * cos(deltaLngRad);

    final double bearingRad = atan2(y, x);
    final double bearingDeg = bearingRad * (180 / pi);

    // Normalize to 0-360 degrees
    return (bearingDeg + 360) % 360;
  }

  /// Calculate distance to Kaaba using Haversine formula
  static double calculateDistanceToKaaba(double userLat, double userLng) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double lat1Rad = userLat * (pi / 180);
    const double lat2Rad = kaabaLatitude * (pi / 180);
    final double deltaLatRad = (kaabaLatitude - userLat) * (pi / 180);
    final double deltaLngRad = (kaabaLongitude - userLng) * (pi / 180);

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
                     cos(lat1Rad) * cos(lat2Rad) *
                     sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Create QiblaModel from user location and compass data
  factory QiblaModel.fromLocationAndCompass({
    required double userLatitude,
    required double userLongitude,
    required double compassAngle,
    required bool isLocationAvailable,
    required bool isCompassAvailable,
  }) {
    final double qiblaAngle = calculateQiblaBearing(userLatitude, userLongitude);
    final double distanceToKaaba = calculateDistanceToKaaba(userLatitude, userLongitude);

    return QiblaModel(
      qiblaAngle: qiblaAngle,
      compassAngle: compassAngle,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      distanceToKaaba: distanceToKaaba,
      isLocationAvailable: isLocationAvailable,
      isCompassAvailable: isCompassAvailable,
    );
  }

  /// Get the relative angle between compass and Qibla direction
  double get relativeQiblaAngle {
    double angle = qiblaAngle - compassAngle;
    // Normalize to -180 to 180 degrees
    while (angle > 180) {
      angle -= 360;
    }
    while (angle < -180) {
      angle += 360;
    }
    return angle;
  }

  /// Check if the device is pointing towards Qibla (within tolerance)
  bool isPointingToQibla({double tolerance = 10.0}) {
    return relativeQiblaAngle.abs() <= tolerance;
  }

  QiblaModel copyWith({
    double? qiblaAngle,
    double? compassAngle,
    double? userLatitude,
    double? userLongitude,
    double? distanceToKaaba,
    bool? isLocationAvailable,
    bool? isCompassAvailable,
  }) {
    return QiblaModel(
      qiblaAngle: qiblaAngle ?? this.qiblaAngle,
      compassAngle: compassAngle ?? this.compassAngle,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      distanceToKaaba: distanceToKaaba ?? this.distanceToKaaba,
      isLocationAvailable: isLocationAvailable ?? this.isLocationAvailable,
      isCompassAvailable: isCompassAvailable ?? this.isCompassAvailable,
    );
  }

  @override
  String toString() {
    return 'QiblaModel(qiblaAngle: $qiblaAngle, compassAngle: $compassAngle, '
           'userLat: $userLatitude, userLng: $userLongitude, '
           'distance: $distanceToKaaba, locationAvailable: $isLocationAvailable, '
           'compassAvailable: $isCompassAvailable)';
  }
}
