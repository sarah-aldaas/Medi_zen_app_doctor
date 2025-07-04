class MedicationRequestFilterModel {
  final String? searchQuery;
  final bool? doNotPerform;
  final String? statusId;
  final String? intentId;
  final String? priorityId;
  final String? courseOfTherapyTypeId;
  final String? conditionId;
  final String? minNumberOfRepeatsAllowed;
  final String? maxNumberOfRepeatsAllowed;

  MedicationRequestFilterModel({
    this.searchQuery,
    this.doNotPerform,
    this.statusId,
    this.intentId,
    this.priorityId,
    this.courseOfTherapyTypeId,
    this.conditionId,
    this.minNumberOfRepeatsAllowed,
    this.maxNumberOfRepeatsAllowed,
  });

  Map<String, dynamic> toJson() {
    return {
      if (searchQuery != null && searchQuery!.isNotEmpty) 'search_query': searchQuery,
      if (doNotPerform != null) 'do_not_perform': doNotPerform! ? 1 : 0,
      if (statusId != null) 'status_id': statusId,
      if (intentId != null) 'intent_id': intentId,
      if (priorityId != null) 'priority_id': priorityId,
      if (courseOfTherapyTypeId != null) 'course_of_therapy_type_id': courseOfTherapyTypeId,
      if (conditionId != null) 'condition_id': conditionId,
      if (minNumberOfRepeatsAllowed != null) 'min_number_of_repeats_allowed': minNumberOfRepeatsAllowed,
      if (maxNumberOfRepeatsAllowed != null) 'max_number_of_repeats_allowed': maxNumberOfRepeatsAllowed,
    };
  }

  MedicationRequestFilterModel copyWith({
    String? searchQuery,
    bool? doNotPerform,
    String? statusId,
    String? intentId,
    String? priorityId,
    String? courseOfTherapyTypeId,
    String? conditionId,
    String? minNumberOfRepeatsAllowed,
    String? maxNumberOfRepeatsAllowed,
  }) {
    return MedicationRequestFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      doNotPerform: doNotPerform ?? this.doNotPerform,
      statusId: statusId ?? this.statusId,
      intentId: intentId ?? this.intentId,
      priorityId: priorityId ?? this.priorityId,
      courseOfTherapyTypeId: courseOfTherapyTypeId ?? this.courseOfTherapyTypeId,
      conditionId: conditionId ?? this.conditionId,
      minNumberOfRepeatsAllowed: minNumberOfRepeatsAllowed ?? this.minNumberOfRepeatsAllowed,
      maxNumberOfRepeatsAllowed: maxNumberOfRepeatsAllowed ?? this.maxNumberOfRepeatsAllowed,
    );
  }
}
