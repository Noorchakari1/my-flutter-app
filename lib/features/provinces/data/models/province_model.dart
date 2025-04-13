class ProvinceItem {
  final int id;
  final String? title;
  final String? description;
  final String? image;
  final String? phone;
  final String? link;

  ProvinceItem({
    required this.id,
    this.title,
    this.description,
    this.image,
    this.phone,
    this.link,
  });

  factory ProvinceItem.fromJson(Map<String, dynamic> json) {
    return ProvinceItem(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      phone: json['phone'] as String?,
      link: json['link'] as String?,
    );
  }
}

class ProvincePagination {
  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int totalPages;

  ProvincePagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  factory ProvincePagination.fromJson(Map<String, dynamic> json) {
    return ProvincePagination(
      total: json['total'] as int,
      count: json['count'] as int,
      perPage: json['per_page'] as int,
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
    );
  }
}

class ProvinceResponse {
  final List<ProvinceItem> items;
  final ProvincePagination pagination;

  ProvinceResponse({
    required this.items,
    required this.pagination,
  });

  factory ProvinceResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return ProvinceResponse(
      items: (data['items'] as List<dynamic>)
          .map((item) => ProvinceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: ProvincePagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }
} 