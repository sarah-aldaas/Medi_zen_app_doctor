class AllergyFilterModel {
  final String? searchQuery;
  final int? isDiscoveredDuringEncounter;
  final int? typeId;
  final int? clinicalStatusId;
  final int? verificationStatusId;
  final int? categoryId;
  final int? criticalityId;

  final String? sort;

  final int? paginationCount;

  AllergyFilterModel({
    this.searchQuery,
    this.isDiscoveredDuringEncounter,
    this.typeId,
    this.clinicalStatusId,
    this.verificationStatusId,
    this.categoryId,
    this.criticalityId,
    this.sort,
    this.paginationCount,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      map['search_query'] = searchQuery;
    }

    if (isDiscoveredDuringEncounter != null) {
      map['is_discovered_during_encounter'] = isDiscoveredDuringEncounter!;
    }

    if (categoryId != null) {
      map['category_id'] = categoryId;
    }
    if (typeId != null) {
      map['type_id'] = typeId;
    }

    if (clinicalStatusId != null) {
      map['clinical_status_id'] = clinicalStatusId;
    }

    if (verificationStatusId != null) {
      map['verification_status_id'] = verificationStatusId!;
    }

    if (criticalityId != null) {
      map['criticality_id'] = criticalityId;
    }

    if (sort != null) {
      map['sort'] = sort;
    }

    return map;
  }

  AllergyFilterModel copyWith({
    String? searchQuery,
    int? isDiscoveredDuringEncounter,
    int? typeId,
    int? clinicalStatusId,
    int? verificationStatusId,
    int? categoryId,
    int? criticalityId,
    String? sort,
    int? paginationCount,
  }) {
    return AllergyFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,

      isDiscoveredDuringEncounter:
      isDiscoveredDuringEncounter ?? this.isDiscoveredDuringEncounter,

      typeId: typeId ?? this.typeId,
      clinicalStatusId: clinicalStatusId ?? this.clinicalStatusId,
      verificationStatusId: verificationStatusId ?? this.verificationStatusId,
      categoryId: categoryId ?? this.categoryId,
      criticalityId: criticalityId ?? this.criticalityId,
      sort: sort ?? this.sort,
      paginationCount: paginationCount ?? this.paginationCount,
    );
  }

  @override
  String toString() {
    return 'AllergyFilterModel{'
        'searchQuery: $searchQuery, '
        'isDiscoveredDuringEncounter: $isDiscoveredDuringEncounter, '
        'typeId: $typeId, '
        'clinicalStatusId: $clinicalStatusId, '
        'verificationStatusId: $verificationStatusId, '
        'categoryId: $categoryId, '
        'criticalityId: $criticalityId, '
        'sort: $sort, '
        'paginationCount: $paginationCount}';
  }
}
