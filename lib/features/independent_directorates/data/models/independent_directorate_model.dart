class IndependentDirectorateItem {
  final int id;
  final String? title;
  final String? description;
  final String? image;
  final String? phone;
  final String? link;

  IndependentDirectorateItem({
    required this.id,
    this.title,
    this.description,
    this.image,
    this.phone,
    this.link,
  });

  factory IndependentDirectorateItem.fromJson(Map<String, dynamic> json) {
    return IndependentDirectorateItem(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      phone: json['phone'] as String?,
      link: json['link'] as String?,
    );
  }
}

class IndependentDirectoratePagination {
  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int totalPages;

  IndependentDirectoratePagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  factory IndependentDirectoratePagination.fromJson(Map<String, dynamic> json) {
    return IndependentDirectoratePagination(
      total: json['total'] as int,
      count: json['count'] as int,
      perPage: json['per_page'] as int,
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
    );
  }
}

class IndependentDirectorateResponse {
  final List<IndependentDirectorateItem> items;
  final IndependentDirectoratePagination pagination;

  IndependentDirectorateResponse({
    required this.items,
    required this.pagination,
  });

  factory IndependentDirectorateResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return IndependentDirectorateResponse(
      items: (data['items'] as List<dynamic>)
          .map((item) => IndependentDirectorateItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: IndependentDirectoratePagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }
} 