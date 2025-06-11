class AllergyFilterModel {
  final String? searchQuery;
  final bool? isDiscoveredDuringEncounter;
  final int? typeId;
  final int? clinicalStatusId;
  final int? verificationStatusId;
  final int? categoryId;
  final int? criticalityId;
  final String? sort;
  final DateTime? minLastOccurrence;
  final DateTime? maxLastOccurrence;
  final DateTime? minOnSetAge;
  final DateTime? maxOnSetAge;

  AllergyFilterModel({
    this.searchQuery,
    this.isDiscoveredDuringEncounter,
    this.typeId,
    this.clinicalStatusId,
    this.verificationStatusId,
    this.categoryId,
    this.criticalityId,
    this.sort,
    this.minLastOccurrence,
    this.maxLastOccurrence,
    this.minOnSetAge,
    this.maxOnSetAge,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      map['search_query'] = searchQuery;
    }

    if (isDiscoveredDuringEncounter != null) {
      map['is_discovered_during_encounter'] = isDiscoveredDuringEncounter! ? 1 : 0;
    }

    if (typeId != null) {
      map['type_id'] = typeId;
    }

    if (clinicalStatusId != null) {
      map['clinical_status_id'] = clinicalStatusId;
    }

    if (verificationStatusId != null) {
      map['verification_status_id'] = verificationStatusId;
    }

    if (categoryId != null) {
      map['category_id'] = categoryId;
    }

    if (criticalityId != null) {
      map['criticality_id'] = criticalityId;
    }

    if (sort != null) {
      map['sort'] = sort;
    }

    if (minLastOccurrence != null) {
      map['min_last_occurrence'] = minLastOccurrence!.toIso8601String();
    }

    if (maxLastOccurrence != null) {
      map['max_last_occurrence'] = maxLastOccurrence!.toIso8601String();
    }

    if (minOnSetAge != null) {
      map['min_on_set_age'] = minOnSetAge!.toIso8601String();
    }

    if (maxOnSetAge != null) {
      map['max_on_set_age'] = maxOnSetAge!.toIso8601String();
    }

    return map;
  }

  AllergyFilterModel copyWith({
    String? searchQuery,
    bool? isDiscoveredDuringEncounter,
    int? typeId,
    int? clinicalStatusId,
    int? verificationStatusId,
    int? categoryId,
    int? criticalityId,
    String? sort,
    DateTime? minLastOccurrence,
    DateTime? maxLastOccurrence,
    DateTime? minOnSetAge,
    DateTime? maxOnSetAge,
  }) {
    return AllergyFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      isDiscoveredDuringEncounter: isDiscoveredDuringEncounter ?? this.isDiscoveredDuringEncounter,
      typeId: typeId ?? this.typeId,
      clinicalStatusId: clinicalStatusId ?? this.clinicalStatusId,
      verificationStatusId: verificationStatusId ?? this.verificationStatusId,
      categoryId: categoryId ?? this.categoryId,
      criticalityId: criticalityId ?? this.criticalityId,
      sort: sort ?? this.sort,
      minLastOccurrence: minLastOccurrence ?? this.minLastOccurrence,
      maxLastOccurrence: maxLastOccurrence ?? this.maxLastOccurrence,
      minOnSetAge: minOnSetAge ?? this.minOnSetAge,
      maxOnSetAge: maxOnSetAge ?? this.maxOnSetAge,
    );
  }
}