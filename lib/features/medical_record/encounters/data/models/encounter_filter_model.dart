class EncounterFilterModel {
  final String? searchQuery;
  final int? statusId;
  final int? typeId;
  final int? appointmentId;
  final DateTime? minStartDate;
  final DateTime? maxStartDate;

  EncounterFilterModel({
    this.searchQuery,
    this.statusId,
    this.typeId,
    this.appointmentId,
    this.minStartDate,
    this.maxStartDate,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      map['search_query'] = searchQuery;
    }

    if (statusId != null) {
      map['status_id'] = statusId;
    }

    if (typeId != null) {
      map['type_id'] = typeId;
    }

    if (appointmentId != null) {
      map['appointment_id'] = appointmentId;
    }

    if (minStartDate != null) {
      map['min_start_date'] = minStartDate!.toIso8601String();
    }

    if (maxStartDate != null) {
      map['max_start_date'] = maxStartDate!.toIso8601String();
    }

    return map;
  }

  EncounterFilterModel copyWith({
    String? searchQuery,
    int? statusId,
    int? typeId,
    int? appointmentId,
    DateTime? minStartDate,
    DateTime? maxStartDate,
    }) {
    return EncounterFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      statusId: statusId ?? this.statusId,
      typeId: typeId ?? this.typeId,
      appointmentId: appointmentId ?? this.appointmentId,
      minStartDate: minStartDate ?? this.minStartDate,
      maxStartDate: maxStartDate ?? this.maxStartDate,
    );
  }
}