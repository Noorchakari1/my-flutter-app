class MinistryItem {
  final int id;
  final String? title;
  final String? description;
  final String? image;
  final String? phone;
  final String? link;

  MinistryItem({
    required this.id,
    this.title,
    this.description,
    this.image,
    this.phone,
    this.link,
  });

  factory MinistryItem.fromJson(Map<String, dynamic> json) {
    return MinistryItem(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      phone: json['phone'] as String?,
      link: json['link'] as String?,
    );
  }
}

class MinistryPagination {
  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int totalPages;

  MinistryPagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  factory MinistryPagination.fromJson(Map<String, dynamic> json) {
    return MinistryPagination(
      total: json['total'] as int,
      count: json['count'] as int,
      perPage: json['per_page'] as int,
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
    );
  }
}

class MinistryResponse {
  final List<MinistryItem> items;
  final MinistryPagination pagination;

  MinistryResponse({
    required this.items,
    required this.pagination,
  });

  factory MinistryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return MinistryResponse(
      items: (data['items'] as List<dynamic>)
          .map((item) => MinistryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: MinistryPagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }
} 