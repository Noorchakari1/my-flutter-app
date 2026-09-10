import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/services/api_exception.dart';
import '../../../../core/services/ssl_http_client.dart';
import '../models/announcement.dart';

/// Retrieves public announcements for the selected application language.
class AnnouncementService {
  static const String _endpoint = 'https://it.arg.gov.af/api/announcements';

  final http.Client _httpClient;

  AnnouncementService({http.Client? httpClient})
      : _httpClient = httpClient ?? SslHttpClient.instance;

  Future<Announcement> getLatestAnnouncement(String appLanguage) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(_endpoint).replace(queryParameters: {
          'locale': _apiLocaleFor(appLanguage),
        }),
      );

      if (response.statusCode != 200) {
        throw ApiException.fromResponse(response);
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      final announcements = data
          .whereType<Map<String, dynamic>>()
          .map(Announcement.fromJson)
          .where((announcement) => announcement.description.isNotEmpty)
          .toList();

      announcements.sort((first, second) =>
          (second.publishDate ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(first.publishDate ?? DateTime.fromMillisecondsSinceEpoch(0)));

      if (announcements.isEmpty) {
        throw const ApiException(
          message: 'No announcement is available.',
          code: 'empty_announcement',
        );
      }

      return announcements.first;
    } catch (error) {
      throw ApiException.fromError(error);
    }
  }

  String _apiLocaleFor(String appLanguage) => switch (appLanguage) {
        'persian' => 'fa',
        'english' => 'en',
        _ => 'ps',
      };
}
