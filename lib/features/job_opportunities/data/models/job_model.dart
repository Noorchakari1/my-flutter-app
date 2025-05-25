class JobMinistry {
  final int id;
  final String? titleDr;
  final String? titlePs;
  final String? titleEn;
  final String? descriptionDr;
  final String? descriptionPs;
  final String? descriptionEn;
  final String? websiteUrl;
  final String? logoPath;
  final int? createdBy;
  final int? updatedBy;
  final String? createdAt;
  final String? updatedAt;

  JobMinistry({
    required this.id,
    this.titleDr,
    this.titlePs,
    this.titleEn,
    this.descriptionDr,
    this.descriptionPs,
    this.descriptionEn,
    this.websiteUrl,
    this.logoPath,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory JobMinistry.fromJson(Map<String, dynamic> json) {
    return JobMinistry(
      id: json['id'] as int,
      titleDr: json['title_dr'] as String?,
      titlePs: json['title_ps'] as String?,
      titleEn: json['title_en'] as String?,
      descriptionDr: json['description_dr'] as String?,
      descriptionPs: json['description_ps'] as String?,
      descriptionEn: json['description_en'] as String?,
      websiteUrl: json['website_url'] as String?,
      logoPath: json['logo_path'] as String?,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Get title based on current language
  String? getTitle(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return titleEn;
      case 'persian':
        return titleDr;
      case 'pashto':
        return titlePs;
      default:
        return titleEn ?? titleDr ?? titlePs;
    }
  }
}

class JobItem {
  final int id;
  final String uuid;
  final String? titleEn;
  final String? titlePs;
  final String? titleDr;
  final String? contractDuration;
  final String? announcementDate;
  final String? endDate;
  final String? type;
  final String? status;
  final int isVisible;
  final int? ministryId;
  final String? attachmentPath;
  final String? descriptionEn;
  final String? descriptionPs;
  final String? descriptionDr;
  final String? applyLink;
  final int? createdBy;
  final int? updatedBy;
  final String? publishedAt;
  final int? publishedBy;
  final String? archivedAt;
  final int? archivedBy;
  final String? createdAt;
  final String? updatedAt;
  final JobMinistry? ministry;

  JobItem({
    required this.id,
    required this.uuid,
    this.titleEn,
    this.titlePs,
    this.titleDr,
    this.contractDuration,
    this.announcementDate,
    this.endDate,
    this.type,
    this.status,
    required this.isVisible,
    this.ministryId,
    this.attachmentPath,
    this.descriptionEn,
    this.descriptionPs,
    this.descriptionDr,
    this.applyLink,
    this.createdBy,
    this.updatedBy,
    this.publishedAt,
    this.publishedBy,
    this.archivedAt,
    this.archivedBy,
    this.createdAt,
    this.updatedAt,
    this.ministry,
  });

  factory JobItem.fromJson(Map<String, dynamic> json) {
    return JobItem(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      titleEn: json['title_en'] as String?,
      titlePs: json['title_ps'] as String?,
      titleDr: json['title_dr'] as String?,
      contractDuration: json['contract_duration'] as String?,
      announcementDate: json['announcement_date'] as String?,
      endDate: json['end_date'] as String?,
      type: json['type'] as String?,
      status: json['status'] as String?,
      isVisible: json['is_visible'] as int,
      ministryId: json['ministry_id'] as int?,
      attachmentPath: json['attachment_path'] as String?,
      descriptionEn: json['description_en'] as String?,
      descriptionPs: json['description_ps'] as String?,
      descriptionDr: json['description_dr'] as String?,
      applyLink: json['apply_link'] as String?,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      publishedAt: json['published_at'] as String?,
      publishedBy: json['published_by'] as int?,
      archivedAt: json['archived_at'] as String?,
      archivedBy: json['archived_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      ministry: json['ministry'] != null
          ? JobMinistry.fromJson(json['ministry'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Get title based on current language
  String? getTitle(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return titleEn;
      case 'persian':
        return titleDr;
      case 'pashto':
        return titlePs;
      default:
        return titleEn ?? titleDr ?? titlePs;
    }
  }

  /// Get description based on current language
  String? getDescription(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return descriptionEn;
      case 'persian':
        return descriptionDr;
      case 'pashto':
        return descriptionPs;
      default:
        return descriptionEn ?? descriptionDr ?? descriptionPs;
    }
  }

  /// Check if job is still active (not expired)
  bool get isActive {
    if (endDate == null) return true;
    try {
      final endDateTime = DateTime.parse(endDate!);
      return DateTime.now().isBefore(endDateTime);
    } catch (e) {
      return true; // If date parsing fails, assume it's active
    }
  }

  /// Get formatted announcement date
  String? get formattedAnnouncementDate {
    if (announcementDate == null) return null;
    try {
      final date = DateTime.parse(announcementDate!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return announcementDate;
    }
  }

  /// Get formatted end date
  String? get formattedEndDate {
    if (endDate == null) return null;
    try {
      final date = DateTime.parse(endDate!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return endDate;
    }
  }
}

class JobResponse {
  final bool success;
  final String message;
  final List<JobItem> data;

  JobResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory JobResponse.fromJson(Map<String, dynamic> json) {
    return JobResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => JobItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
