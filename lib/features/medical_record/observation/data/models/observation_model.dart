import '../../../../../base/data/models/code_type_model.dart';
import '../../../service_request/data/models/service_request_model.dart';
import 'laboratory_model.dart';
import 'observation_definition_model.dart';

class ObservationModel {
  final String? id;
  final String? cancelledReason;
  final DateTime? effectiveDateTime;
  final String? value;
  final String? absentReason;
  final String? note;
  final String? pdf;
  final CodeModel? status;
  final CodeModel? interpretation;
  final CodeModel? bodySite;
  final CodeModel? method;
  final LaboratoryModel? laboratory;
  final ServiceRequestModel? serviceRequest;
  final ObservationDefinitionModel? observationDefinition;

  ObservationModel({
    this.id,
    this.cancelledReason,
    this.effectiveDateTime,
    this.value,
    this.absentReason,
    this.note,
    this.pdf,
    this.status,
    this.interpretation,
    this.bodySite,
    this.method,
    this.laboratory,
    this.serviceRequest,
    this.observationDefinition,
  });

  factory ObservationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ObservationModel();

    return ObservationModel(
      id: json['id']?.toString(),
      cancelledReason: json['cancelled_reason']?.toString(),
      effectiveDateTime: json['effective_date_time'] != null
          ? DateTime.tryParse(json['effective_date_time'])
          : null,
      value: json['value']?.toString(),
      absentReason: json['absent_reason']?.toString(),
      note: json['note']?.toString(),
      pdf: json['pdf']?.toString(),
      status: json['status'] != null
          ? CodeModel.fromJson(json['status'])
          : null,
      interpretation: json['interpretation'] != null
          ? CodeModel.fromJson(json['interpretation'])
          : null,
      bodySite: json['body_site'] != null
          ? CodeModel.fromJson(json['body_site'])
          : null,
      method: json['method'] != null
          ? CodeModel.fromJson(json['method'])
          : null,
      laboratory: json['laboratory'] != null
          ? LaboratoryModel.fromJson(json['laboratory'])
          : null,
      observationDefinition: json['observation_definition'] != null
          ? ObservationDefinitionModel.fromJson(json['observation_definition'])
          : null,
      serviceRequest: json['service_request'] != null
          ? ServiceRequestModel.fromJson(json['service_request'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cancelled_reason': cancelledReason,
      'effective_date_time': effectiveDateTime?.toIso8601String(),
      'value': value,
      'absent_reason': absentReason,
      'note': note,
      'pdf': pdf,
      'status': status?.toJson(),
      'interpretation': interpretation?.toJson(),
      'body_site': bodySite?.toJson(),
      'method': method?.toJson(),
      'laboratory': laboratory?.toJson(),
      'service_request': serviceRequest?.toJson(),
      'observation_definition': observationDefinition?.toJson(),
    };
  }

}