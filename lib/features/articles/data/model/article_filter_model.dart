class ArticleFilter {
  final String? searchQuery;
  final String? sort;
  final String? categoryId;

  ArticleFilter({
    this.searchQuery,
    this.sort,
    this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (searchQuery != null && searchQuery!.isNotEmpty)
        'search_query': searchQuery,
      if (sort != null) 'sort': sort,
      if (categoryId != null) 'category_id': categoryId,
    };
  }

  ArticleFilter copyWith({
    String? searchQuery,
    String? sort,
    String? categoryId,
  }) {
    return ArticleFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      sort: sort ?? this.sort,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  // Helper methods for common filter operations
  ArticleFilter withSearchQuery(String query) {
    return copyWith(searchQuery: query);
  }

  ArticleFilter withCategory(String categoryId) {
    return copyWith(categoryId: categoryId);
  }

  ArticleFilter withSort(String sortField, {bool ascending = true}) {
    return copyWith(sort: '${ascending ? '' : '-'}$sortField');
  }

  ArticleFilter clearFilters() {
    return ArticleFilter();
  }
}