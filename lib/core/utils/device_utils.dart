import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A utility class for handling device information and platform-specific operations
class DeviceUtils {
  /// Check if the device is in dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  /// Check if the device is a tablet
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = (size.width * size.width + size.height * size.height) * 0.5;
    return diagonal > 1100; // Approximate diagonal size for tablets
  }
  
  /// Get the device platform
  static String getPlatform() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isLinux) {
      return 'linux';
    } else {
      return 'unknown';
    }
  }
  
  /// Get the app version
  static Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
  
  /// Get the app build number
  static Future<String> getBuildNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }
  
  /// Get the app name
  static Future<String> getAppName() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.appName;
  }
  
  /// Get the app package name
  static Future<String> getPackageName() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.packageName;
  }
  
  /// Open the device dialer with a phone number
  static Future<bool> openDialer(String phoneNumber) async {
    try {
      final url = 'tel:$phoneNumber';
      return await _launchUrl(url);
    } catch (e) {
      return false;
    }
  }
  
  /// Open a URL in the device browser
  static Future<bool> openUrl(String url) async {
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      return await _launchUrl(url);
    } catch (e) {
      return false;
    }
  }
  
  /// Open an email client with a pre-filled email
  static Future<bool> openEmail(String email, {String? subject, String? body}) async {
    try {
      String url = 'mailto:$email';
      if (subject != null || body != null) {
        url += '?';
        if (subject != null) {
          url += 'subject=${Uri.encodeComponent(subject)}';
        }
        if (body != null) {
          if (subject != null) url += '&';
          url += 'body=${Uri.encodeComponent(body)}';
        }
      }
      return await _launchUrl(url);
    } catch (e) {
      return false;
    }
  }
  
  /// Launch a URL (implementation will need url_launcher package)
  static Future<bool> _launchUrl(String url) async {
    // This is a placeholder - you'll need to implement this with url_launcher
    // For now, we'll just print the URL and return true
    print('Launching URL: $url');
    return true;
  }
}
