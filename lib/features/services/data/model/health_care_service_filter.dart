class HealthCareServiceFilter {
  final String? searchQuery;
  final bool? active;
  final int? categoryId;
  final int? clinicId;
  final bool? appointmentRequired;
  final double? minPrice;
  final double? maxPrice;
  final int? paginationCount;

  HealthCareServiceFilter({
    this.searchQuery,
    this.active,
    this.categoryId,
    this.clinicId,
    this.appointmentRequired,
    this.minPrice,
    this.maxPrice,
    this.paginationCount = 10,
  });


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      map['search_query'] = searchQuery;
    }

    if (active != null) {
      map['active'] = active! ? 1 : 0;
    }

    if (categoryId != null) {
      map['category_id'] = categoryId;
    }

    if (clinicId != null) {
      map['clinic_id'] = clinicId;
    }

    if (appointmentRequired != null) {
      map['appointment_required'] = appointmentRequired! ? 1 : 0;
    }

    if (minPrice != null) {
      map['min_price'] = minPrice;
    }

    if (maxPrice != null) {
      map['max_price'] = maxPrice;
    }

    return map;
  }

  HealthCareServiceFilter copyWith({
    String? searchQuery,
    bool? active,
    int? categoryId,
    int? clinicId,
    bool? appointmentRequired,
    double? minPrice,
    double? maxPrice,
    int? paginationCount,
  }) {
    return HealthCareServiceFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      active: active ?? this.active,
      categoryId: categoryId ?? this.categoryId,
      clinicId: clinicId ?? this.clinicId,
      appointmentRequired: appointmentRequired ?? this.appointmentRequired,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      paginationCount: paginationCount ?? this.paginationCount,
    );
  }
}