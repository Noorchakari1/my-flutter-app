/// The announcement data used by the home-screen announcement frame.
class Announcement {
  final int id;
  final String locale;
  final String description;
  final DateTime? publishDate;

  const Announcement({
    required this.id,
    required this.locale,
    required this.description,
    this.publishDate,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int? ?? 0,
      locale: json['locale'] as String? ?? '',
      description: (json['description'] as String? ?? '').trim(),
      publishDate: DateTime.tryParse(json['publish_date'] as String? ?? ''),
    );
  }
}
