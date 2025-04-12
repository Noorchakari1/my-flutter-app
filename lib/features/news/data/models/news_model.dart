class NewsItem {
  final int id;
  final String? title;
  final String? date;
  final String? image;
  final String? type;

  NewsItem({
    required this.id,
    this.title,
    this.date,
    this.image,
    this.type,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] as int,
      title: json['title'] as String?,
      date: json['date'] as String?,
      image: json['image'] as String?,
      type: json['type'] as String?,
    );
  }
}

class NewsDetail {
  final int id;
  final String? title;
  final String? description;
  final String? date;
  final String? type;
  final int? status;
  final String? createdAt;
  final String? image;
  final String? video;
  final String? tags;
  final int? views;
  final List<String>? gallery;

  NewsDetail({
    required this.id,
    this.title,
    this.description,
    this.date,
    this.type,
    this.status,
    this.createdAt,
    this.image,
    this.video,
    this.tags,
    this.views,
    this.gallery,
  });

  factory NewsDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return NewsDetail(
      id: data['id'] as int,
      title: data['title'] as String?,
      description: data['description'] as String?,
      date: data['date'] as String?,
      type: data['type'] as String?,
      status: data['status'] as int?,
      createdAt: data['created_at'] as String?,
      image: data['image'] as String?,
      video: data['video'] as String?,
      tags: data['tags'] as String?,
      views: data['views'] as int?,
      gallery: data['gallery'] is List ? List<String>.from(data['gallery']) : null,
    );
  }
}

class NewsPagination {
  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int totalPages;

  NewsPagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  factory NewsPagination.fromJson(Map<String, dynamic> json) {
    return NewsPagination(
      total: json['total'] as int,
      count: json['count'] as int,
      perPage: json['per_page'] as int,
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
    );
  }
}

class NewsResponse {
  final List<NewsItem> items;
  final NewsPagination pagination;

  NewsResponse({
    required this.items,
    required this.pagination,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return NewsResponse(
      items: (data['items'] as List<dynamic>)
          .map((item) => NewsItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: NewsPagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }
} 