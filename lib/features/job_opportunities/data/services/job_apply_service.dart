import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job_model.dart';

/// Service for handling job application functionality
class JobApplyService {
  /// Apply to a job based on the apply link type
  static Future<JobApplyResult> applyToJob(JobItem job) async {
    
    if (!job.hasValidApplyLink) {
      return const JobApplyResult(
        success: false,
        message: 'No valid apply link available',
        linkType: ApplyLinkType.none,
      );
    }

    final formattedLink = job.formattedApplyLink;
    
    if (formattedLink == null) {
      return JobApplyResult(
        success: false,
        message: 'Invalid apply link format',
        linkType: job.applyLinkType,
      );
    }

    try {
      final uri = Uri.parse(formattedLink);
      // Get the appropriate launch mode
      final launchMode = _getLaunchMode(job.applyLinkType);
      // Check if the URL can be launched
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        // Try alternative launch methods for different link types
        return await _tryAlternativeLaunch(job, formattedLink);
      }

      // Launch the URL with appropriate mode based on link type
      final launched = await launchUrl(uri, mode: launchMode);
      if (launched) {
        return JobApplyResult(
          success: true,
          message: _getSuccessMessage(job.applyLinkType),
          linkType: job.applyLinkType,
        );
      } else {
        return await _tryAlternativeLaunch(job, formattedLink);
      }
    } catch (e) {
      return JobApplyResult(
        success: false,
        message: 'Failed to open ${_getLinkTypeDisplayName(job.applyLinkType)}: ${e.toString()}',
        linkType: job.applyLinkType,
      );
    }
  }

  /// Try alternative launch methods when primary method fails
  static Future<JobApplyResult> _tryAlternativeLaunch(JobItem job, String formattedLink) async {
    try {
      final uri = Uri.parse(formattedLink);
      
      // Try different launch modes
      final launchModes = [
        LaunchMode.externalApplication,
        LaunchMode.externalNonBrowserApplication,
        LaunchMode.platformDefault,
      ];
      
      for (final mode in launchModes) {
        try {
          final launched = await launchUrl(uri, mode: mode);
          if (launched) {
            return JobApplyResult(
              success: true,
              message: _getSuccessMessage(job.applyLinkType),
              linkType: job.applyLinkType,
            );
          }
        } catch (e) {
          continue;
        }
      }
      
      // If all modes fail, return error
      return JobApplyResult(
        success: false,
        message: _getErrorMessage(job.applyLinkType),
        linkType: job.applyLinkType,
      );
    } catch (e) {
      return JobApplyResult(
        success: false,
        message: 'All launch attempts failed: ${e.toString()}',
        linkType: job.applyLinkType,
      );
    }
  }

  /// Get the appropriate launch mode based on link type
  static LaunchMode _getLaunchMode(ApplyLinkType linkType) {
    switch (linkType) {
      case ApplyLinkType.email:
        // For email, use external application to open default email client
        return LaunchMode.externalApplication;
      case ApplyLinkType.webUrl:
        // For web URLs, use external application to open in Chrome/default browser
        return LaunchMode.externalApplication;
      case ApplyLinkType.none:
        return LaunchMode.platformDefault;
    }
  }

  /// Get success message based on link type
  static String _getSuccessMessage(ApplyLinkType linkType) {
    switch (linkType) {
      case ApplyLinkType.email:
        return 'Email client opened successfully';
      case ApplyLinkType.webUrl:
        return 'Browser opened successfully';
      case ApplyLinkType.none:
        return 'Link opened successfully';
    }
  }

  /// Get error message based on link type
  static String _getErrorMessage(ApplyLinkType linkType) {
    switch (linkType) {
      case ApplyLinkType.email:
        return 'Unable to open email client. Please check if you have an email app installed.';
      case ApplyLinkType.webUrl:
        return 'Unable to open browser. Please check your internet connection.';
      case ApplyLinkType.none:
        return 'Unable to open the link.';
    }
  }

  /// Get display name for link type
  static String _getLinkTypeDisplayName(ApplyLinkType linkType) {
    switch (linkType) {
      case ApplyLinkType.email:
        return 'email';
      case ApplyLinkType.webUrl:
        return 'website';
      case ApplyLinkType.none:
        return 'link';
    }
  }

  /// Get appropriate icon for the apply button based on link type
  static IconData getApplyButtonIcon(ApplyLinkType linkType) {
    switch (linkType) {
      case ApplyLinkType.email:
        return Icons.email;
      case ApplyLinkType.webUrl:
        return Icons.open_in_new;
      case ApplyLinkType.none:
        return Icons.link;
    }
  }

  /// Get appropriate button text based on link type and language
  static String getApplyButtonText(ApplyLinkType linkType, String fallbackText) {
    // For now, return the fallback text
    // This can be enhanced with localized text based on link type
    return fallbackText;
  }

  /// Validate if an apply link is properly formatted
  static bool isValidApplyLink(String? link) {
    if (link == null || link.isEmpty) return false;
    
    try {
      final uri = Uri.parse(link);
      return uri.hasScheme || link.contains('@') || link.startsWith('www.');
    } catch (e) {
      return false;
    }
  }

  /// Test method to verify URL launcher is working
  static Future<bool> testUrlLauncher() async {
    try {
      // Test with a simple web URL
      final testUri = Uri.parse('https://www.google.com');
      
      final canLaunch = await canLaunchUrl(testUri);
      
      if (canLaunch) {
        final launched = await launchUrl(testUri, mode: LaunchMode.externalApplication);
        return launched;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Test method to verify email launcher is working
  static Future<bool> testEmailLauncher() async {
    try {
      // Test with a simple email
      final testUri = Uri.parse('mailto:test@example.com');
      
      final canLaunch = await canLaunchUrl(testUri);
      
      if (canLaunch) {
        final launched = await launchUrl(testUri, mode: LaunchMode.externalApplication);
        return launched;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Result class for job apply operations
class JobApplyResult {
  final bool success;
  final String message;
  final ApplyLinkType linkType;

  const JobApplyResult({
    required this.success,
    required this.message,
    required this.linkType,
  });

  @override
  String toString() {
    return 'JobApplyResult(success: $success, message: $message, linkType: $linkType)';
  }
} 