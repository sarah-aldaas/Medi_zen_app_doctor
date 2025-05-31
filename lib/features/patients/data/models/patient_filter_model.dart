class PatientFilterModel {
  final String? searchQuery;
  final String? email;
  final bool? isSmoker;
  final bool? isAlcoholDrinker;
  final bool? isActive;
  final bool? isDeceased;
  final int? genderId;
  final int? maritalStatusId;
  final int? bloodId;
  final String? sort; // 'asc' or 'desc'
  final int? paginationCount;
  final DateTime? minDateOfBirth;
  final DateTime? maxDateOfBirth;
  final DateTime? minCreatedAt;
  final DateTime? maxCreatedAt;

  PatientFilterModel({
    this.searchQuery,
    this.email,
    this.isSmoker,
    this.isAlcoholDrinker,
    this.isActive,
    this.isDeceased,
    this.genderId,
    this.maritalStatusId,
    this.bloodId,
    this.sort,
    this.paginationCount,
    this.minDateOfBirth,
    this.maxDateOfBirth,
    this.minCreatedAt,
    this.maxCreatedAt,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      map['search_query'] = searchQuery;
    }

    if (email != null && email!.isNotEmpty) {
      map['email'] = email;
    }

    if (isSmoker != null) {
      map['is_smoker'] = isSmoker! ? 1 : 0;
    }

    if (isAlcoholDrinker != null) {
      map['is_alcohol_drinker'] = isAlcoholDrinker! ? 1 : 0;
    }

    if (isActive != null) {
      map['is_active'] = isActive! ? 1 : 0;
    }

    if (isDeceased != null) {
      map['is_deceased'] = isDeceased! ? 1 : 0;
    }

    if (genderId != null) {
      map['gender_id'] = genderId;
    }

    if (maritalStatusId != null) {
      map['marital_status_id'] = maritalStatusId;
    }

    if (bloodId != null) {
      map['blood_id'] = bloodId;
    }

    if (sort != null) {
      map['sort'] = sort;
    }

    if (paginationCount != null) {
      map['pagination_count'] = paginationCount;
    }

    if (minDateOfBirth != null) {
      map['min_date_of_birth'] = minDateOfBirth!.toIso8601String();
    }

    if (maxDateOfBirth != null) {
      map['max_date_of_birth'] = maxDateOfBirth!.toIso8601String();
    }

    if (minCreatedAt != null) {
      map['min_created_at'] = minCreatedAt!.toIso8601String();
    }

    if (maxCreatedAt != null) {
      map['max_created_at'] = maxCreatedAt!.toIso8601String();
    }

    return map;
  }

  PatientFilterModel copyWith({
    String? searchQuery,
    String? email,
    bool? isSmoker,
    bool? isAlcoholDrinker,
    bool? isActive,
    bool? isDeceased,
    int? genderId,
    int? maritalStatusId,
    int? bloodId,
    String? sort,
    int? paginationCount,
    DateTime? minDateOfBirth,
    DateTime? maxDateOfBirth,
    DateTime? minCreatedAt,
    DateTime? maxCreatedAt,
  }) {
    return PatientFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      email: email ?? this.email,
      isSmoker: isSmoker ?? this.isSmoker,
      isAlcoholDrinker: isAlcoholDrinker ?? this.isAlcoholDrinker,
      isActive: isActive ?? this.isActive,
      isDeceased: isDeceased ?? this.isDeceased,
      genderId: genderId ?? this.genderId,
      maritalStatusId: maritalStatusId ?? this.maritalStatusId,
      bloodId: bloodId ?? this.bloodId,
      sort: sort ?? this.sort,
      paginationCount: paginationCount ?? this.paginationCount,
      minDateOfBirth: minDateOfBirth ?? this.minDateOfBirth,
      maxDateOfBirth: maxDateOfBirth ?? this.maxDateOfBirth,
      minCreatedAt: minCreatedAt ?? this.minCreatedAt,
      maxCreatedAt: maxCreatedAt ?? this.maxCreatedAt,
    );
  }
}