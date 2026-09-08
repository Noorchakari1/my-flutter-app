import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/announcement.dart';
import '../services/announcement_service.dart';

final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  return AnnouncementService();
});

/// Loads the latest announcement for a given application language.
final latestAnnouncementProvider = FutureProvider.family<Announcement, String>(
  (ref, language) => ref.watch(announcementServiceProvider).getLatestAnnouncement(language),
);
