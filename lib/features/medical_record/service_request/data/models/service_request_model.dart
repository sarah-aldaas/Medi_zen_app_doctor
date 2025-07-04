import '../../../../../base/data/models/code_type_model.dart';
import '../../../../authentication/data/models/doctor_model.dart';
import '../../../../services/data/model/health_care_services_model.dart';
import '../../../encounters/data/models/encounter_model.dart';
import '../../../imaging_study/data/models/imaging_study_model.dart';
import '../../../observation/data/models/observation_model.dart';

class ServiceRequestModel {
  final String? id;
  final String? orderDetails;
  final String? reason;
  final String? note;
  final DateTime? occurrenceDate;
  final String? cancelledReason;
  final String? rejectionReason;
  final CodeModel? serviceRequestStatus;
  final CodeModel? serviceRequestCategory;
  final CodeModel? serviceRequestPriority;
  final CodeModel? serviceRequestBodySite;
  final ObservationModel? observation;
  final ImagingStudyModel? imagingStudy;
  final HealthCareServiceModel? healthCareService;
  final DoctorModel? practitionerWhoAcceptedOrRejected;
  final EncounterModel? encounter;

  ServiceRequestModel({
    this.id,
    this.orderDetails,
    this.reason,
    this.note,
    this.occurrenceDate,
    this.cancelledReason,
    this.rejectionReason,
    this.serviceRequestStatus,
    this.serviceRequestCategory,
    this.serviceRequestPriority,
    this.serviceRequestBodySite,
    this.observation,
    this.imagingStudy,
    this.healthCareService,
    this.practitionerWhoAcceptedOrRejected,
    this.encounter,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ServiceRequestModel();

    return ServiceRequestModel(
      id: json['id']?.toString(),
      orderDetails: json['order_details']?.toString(),
      reason: json['reason']?.toString(),
      note: json['note']?.toString(),
      occurrenceDate: json['occurrence_date'] != null ? DateTime.tryParse(json['occurrence_date']) : null,
      cancelledReason: json['cancelled_reason']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      serviceRequestStatus: json['service_request_status'] != null ? CodeModel.fromJson(json['service_request_status']) : null,
      serviceRequestCategory: json['service_request_category'] != null ? CodeModel.fromJson(json['service_request_category']) : null,
      serviceRequestPriority: json['service_request_priority'] != null ? CodeModel.fromJson(json['service_request_priority']) : null,
      serviceRequestBodySite: json['service_request_bodySite'] != null ? CodeModel.fromJson(json['service_request_bodySite']) : null,
      observation: json['observation'] != null ? ObservationModel.fromJson(json['observation']) : null,
      imagingStudy: json['imaging_study'] != null ? ImagingStudyModel.fromJson(json['imaging_study']) : null,
      healthCareService: json['health_care_service'] != null ? HealthCareServiceModel.fromJson(json['health_care_service']) : null,
      practitionerWhoAcceptedOrRejected:
          json['practitioner_who_accepted_or_rejected'] != null ? DoctorModel.fromJson(json['practitioner_who_accepted_or_rejected']) : null,
      encounter: json['encounter'] != null ? EncounterModel.fromJson(json['encounter']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_details': orderDetails,
      'reason': reason,
      'note': note,
      'occurrence_date': occurrenceDate?.toIso8601String(),
      'cancelled_reason': cancelledReason,
      'rejection_reason': rejectionReason,
      'service_request_status': serviceRequestStatus?.toJson(),
      'service_request_category': serviceRequestCategory?.toJson(),
      'service_request_priority': serviceRequestPriority?.toJson(),
      'service_request_bodySite': serviceRequestBodySite?.toJson(),
      'observation': observation?.toJson(),
      'imaging_study': imagingStudy?.toJson(),
      'health_care_service': healthCareService?.toJson(),
      'practitioner_who_accepted_or_rejected': practitionerWhoAcceptedOrRejected?.toJson(),
      'encounter': encounter?.toJson(),
    };
  }

  Map<String, dynamic> createJson() {
    return {
      'order_details': orderDetails,
      'reason': reason,
      'note': note,
      'category_id': serviceRequestCategory!.id,
      'priority_id': serviceRequestPriority!.id,
      'body_site_id': serviceRequestBodySite!.id,
      'health_care_service_id': healthCareService!.id,
    };
  }
  bool get isValid =>
      id != null &&
      orderDetails != null &&
      reason != null &&
      serviceRequestStatus != null &&
      serviceRequestCategory != null &&
      serviceRequestPriority != null &&
      healthCareService != null &&
      encounter != null;

  ServiceRequestModel copyWith({
    String? id,
    String? orderDetails,
    String? reason,
    String? note,
    DateTime? occurrenceDate,
    String? cancelledReason,
    String? rejectionReason,
    CodeModel? serviceRequestStatus,
    CodeModel? serviceRequestCategory,
    CodeModel? serviceRequestPriority,
    CodeModel? serviceRequestBodySite,
    ObservationModel? observation,
    ImagingStudyModel? imagingStudy,
    HealthCareServiceModel? healthCareService,
    DoctorModel? practitionerWhoAcceptedOrRejected,
    EncounterModel? encounter,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      orderDetails: orderDetails ?? this.orderDetails,
      reason: reason ?? this.reason,
      note: note ?? this.note,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      cancelledReason: cancelledReason ?? this.cancelledReason,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      serviceRequestStatus: serviceRequestStatus ?? this.serviceRequestStatus,
      serviceRequestCategory: serviceRequestCategory ?? this.serviceRequestCategory,
      serviceRequestPriority: serviceRequestPriority ?? this.serviceRequestPriority,
      serviceRequestBodySite: serviceRequestBodySite ?? this.serviceRequestBodySite,
      observation: observation ?? this.observation,
      imagingStudy: imagingStudy ?? this.imagingStudy,
      healthCareService: healthCareService ?? this.healthCareService,
      practitionerWhoAcceptedOrRejected: practitionerWhoAcceptedOrRejected ?? this.practitionerWhoAcceptedOrRejected,
      encounter: encounter ?? this.encounter,
    );
  }
}
