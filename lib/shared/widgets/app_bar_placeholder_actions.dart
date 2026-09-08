import 'package:flutter/material.dart';

/// Temporary notification action. Replace its callback when notification
/// delivery and the notification center are introduced.
class NotificationPlaceholderButton extends StatelessWidget {
  final Color color;

  const NotificationPlaceholderButton({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge(
        smallSize: 7,
        child: Icon(Icons.notifications_none_rounded, color: color),
      ),
      tooltip: 'Notifications (coming soon)',
      onPressed: () => _showPlaceholderMessage(context, 'Notifications will be available soon.'),
    );
  }
}

/// Temporary profile action. Replace its callback when account support is
/// introduced.
class ProfilePlaceholderButton extends StatelessWidget {
  final Color color;

  const ProfilePlaceholderButton({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: CircleAvatar(
        radius: 19,
        backgroundColor: Colors.white.withAlpha(58),
        child: Icon(Icons.face_rounded, color: color, size: 27),
      ),
      tooltip: 'Profile (coming soon)',
      onPressed: () => _showPlaceholderMessage(context, 'Profile features will be available soon.'),
    );
  }
}

void _showPlaceholderMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
