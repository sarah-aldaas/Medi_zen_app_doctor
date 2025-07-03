import 'package:intl/intl.dart';

class ConditionsFilterModel {
  final String? searchQuery;
  final bool? isChronic;
  final String? clinicalStatusId;
  final String? verificationStatusId;
  final String? bodySiteId;
  final String? stageId;
  final DateTime? minOnSetDate;
  final DateTime? maxOnSetDate;
  final DateTime? minRecordDate;
  final DateTime? maxRecordDate;
  final String? minOnSetAge;
  final String? maxOnSetAge;
  final String? minAbatementAge;
  final String? maxAbatementAge;
  final DateTime? minAbatementDate;
  final DateTime? maxAbatementDate;

  ConditionsFilterModel({
    this.searchQuery,
    this.isChronic,
    this.clinicalStatusId,
    this.verificationStatusId,
    this.bodySiteId,
    this.stageId,
    this.minOnSetDate,
    this.maxOnSetDate,
    this.minRecordDate,
    this.maxRecordDate,
    this.minOnSetAge,
    this.maxOnSetAge,
    this.minAbatementAge,
    this.maxAbatementAge,
    this.minAbatementDate,
    this.maxAbatementDate,
  });

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return {
      if (searchQuery != null && searchQuery!.isNotEmpty)
        'search_query': searchQuery,
      if (isChronic != null) 'is_chronic': isChronic! ? 1 : 0,
      if (clinicalStatusId != null) 'clinical_status_id': clinicalStatusId,
      if (verificationStatusId != null) 'verification_status_id': verificationStatusId,
      if (bodySiteId != null) 'body_site_id': bodySiteId,
      if (stageId != null) 'stage_id': stageId,
      if (minOnSetDate != null) 'min_on_set_date': dateFormat.format(minOnSetDate!),
      if (maxOnSetDate != null) 'max_on_set_date': dateFormat.format(maxOnSetDate!),
      if (minRecordDate != null) 'min_record_date': dateFormat.format(minRecordDate!),
      if (maxRecordDate != null) 'max_record_date': dateFormat.format(maxRecordDate!),
      if (minOnSetAge != null) 'min_on_set_age': minOnSetAge,
      if (maxOnSetAge != null) 'max_on_set_age': maxOnSetAge,
      if (minAbatementAge != null) 'min_abatement_age': minAbatementAge,
      if (maxAbatementAge != null) 'max_abatement_age': maxAbatementAge,
      if (minAbatementDate != null) 'min_abatement_date': dateFormat.format(minAbatementDate!),
      if (maxAbatementDate != null) 'max_abatement_date': dateFormat.format(maxAbatementDate!),
    };
  }

  ConditionsFilterModel copyWith({
    String? searchQuery,
    bool? isChronic,
    String? clinicalStatusId,
    String? verificationStatusId,
    String? bodySiteId,
    String? stageId,
    DateTime? minOnSetDate,
    DateTime? maxOnSetDate,
    DateTime? minRecordDate,
    DateTime? maxRecordDate,
    String? minOnSetAge,
    String? maxOnSetAge,
    String? minAbatementAge,
    String? maxAbatementAge,
    DateTime? minAbatementDate,
    DateTime? maxAbatementDate,
  }) {
    return ConditionsFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      isChronic: isChronic ?? this.isChronic,
      clinicalStatusId: clinicalStatusId ?? this.clinicalStatusId,
      verificationStatusId: verificationStatusId ?? this.verificationStatusId,
      bodySiteId: bodySiteId ?? this.bodySiteId,
      stageId: stageId ?? this.stageId,
      minOnSetDate: minOnSetDate ?? this.minOnSetDate,
      maxOnSetDate: maxOnSetDate ?? this.maxOnSetDate,
      minRecordDate: minRecordDate ?? this.minRecordDate,
      maxRecordDate: maxRecordDate ?? this.maxRecordDate,
      minOnSetAge: minOnSetAge ?? this.minOnSetAge,
      maxOnSetAge: maxOnSetAge ?? this.maxOnSetAge,
      minAbatementAge: minAbatementAge ?? this.minAbatementAge,
      maxAbatementAge: maxAbatementAge ?? this.maxAbatementAge,
      minAbatementDate: minAbatementDate ?? this.minAbatementDate,
      maxAbatementDate: maxAbatementDate ?? this.maxAbatementDate,
    );
  }
}