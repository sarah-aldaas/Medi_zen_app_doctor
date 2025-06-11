class AppointmentFilterModel {
  final String? searchQuery;
  final int? typeId;
  final int? statusId;
  final int? doctorId;
  final int? patientId;
  final int? clinicId;
  final int? createdByPractitioner;
  final DateTime? minStartDate;
  final DateTime? maxStartDate;
  final DateTime? minEndDate;
  final DateTime? maxEndDate;
  final DateTime? minCancellationDate;
  final DateTime? maxCancellationDate;
  final String? sort; // 'asc' or 'desc'
  final int? paginationCount;

  AppointmentFilterModel({
    this.searchQuery,
    this.typeId,
    this.statusId,
    this.doctorId,
    this.patientId,
    this.clinicId,
    this.createdByPractitioner,
    this.minStartDate,
    this.maxStartDate,
    this.minEndDate,
    this.maxEndDate,
    this.minCancellationDate,
    this.maxCancellationDate,
    this.sort,
    this.paginationCount,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      map['search_query'] = searchQuery;
    }

    if (typeId != null) {
      map['type_id'] = typeId;
    }

    if (statusId != null) {
      map['status_id'] = statusId;
    }

    if (doctorId != null) {
      map['doctor_id'] = doctorId;
    }

    if (patientId != null) {
      map['patient_id'] = patientId;
    }

    if (clinicId != null) {
      map['clinic_id'] = clinicId;
    }

    if (createdByPractitioner != null) {
      map['created_by_practitioner'] = createdByPractitioner;
    }

    if (minStartDate != null) {
      map['start_date_from'] = minStartDate!.toIso8601String();
    }

    if (maxStartDate != null) {
      map['start_date_to'] = maxStartDate!.toIso8601String();
    }

    if (minEndDate != null) {
      map['end_date_from'] = minEndDate!.toIso8601String();
    }

    if (maxEndDate != null) {
      map['end_date_to'] = maxEndDate!.toIso8601String();
    }

    if (minCancellationDate != null) {
      map['cancellation_date_from'] = minCancellationDate!.toIso8601String();
    }

    if (maxCancellationDate != null) {
      map['cancellation_date_to'] = maxCancellationDate!.toIso8601String();
    }

    if (sort != null) {
      map['sort'] = sort;
    }

    if (paginationCount != null) {
      map['pagination_count'] = paginationCount;
    }

    return map;
  }

  AppointmentFilterModel copyWith({
    String? searchQuery,
    int? typeId,
    int? statusId,
    int? doctorId,
    int? patientId,
    int? clinicId,
    int? createdByPractitioner,
    DateTime? minStartDate,
    DateTime? maxStartDate,
    DateTime? minEndDate,
    DateTime? maxEndDate,
    DateTime? minCancellationDate,
    DateTime? maxCancellationDate,
    String? sort,
    int? paginationCount,
  }) {
    return AppointmentFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      typeId: typeId ?? this.typeId,
      statusId: statusId ?? this.statusId,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      clinicId: clinicId ?? this.clinicId,
      createdByPractitioner: createdByPractitioner ?? this.createdByPractitioner,
      minStartDate: minStartDate ?? this.minStartDate,
      maxStartDate: maxStartDate ?? this.maxStartDate,
      minEndDate: minEndDate ?? this.minEndDate,
      maxEndDate: maxEndDate ?? this.maxEndDate,
      minCancellationDate: minCancellationDate ?? this.minCancellationDate,
      maxCancellationDate: maxCancellationDate ?? this.maxCancellationDate,
      sort: sort ?? this.sort,
      paginationCount: paginationCount ?? this.paginationCount,
    );
  }
}