import 'package:flutter/material.dart';

class DownloadDialog {
  static void show(BuildContext context, String language) {
    String message;
    String buttonText;

    switch (language) {
      case 'pashto':
        message = 'فایل په بریالیتوب سره ډانلوډ شو';
        buttonText = 'سمه ده';
        break;
      case 'persian':
        message = 'فایل با موفقیت دانلود شد';
        buttonText = 'تایید';
        break;
      default:
        message = 'File downloaded successfully';
        buttonText = 'OK';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
} 