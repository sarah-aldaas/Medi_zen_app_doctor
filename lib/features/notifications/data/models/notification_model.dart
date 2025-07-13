import '../../../../base/data/models/code_type_model.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationData data;
  final bool isRead;
  final DateTime? readAt;
  final CodeModel? type;
  final DateTime sentAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    this.isRead = false,
    this.readAt,
    this.type,
    required this.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'].toString(),
      body: json['body'].toString(),
      data: NotificationData.fromJson(json['data']),
      type:json['type']!=null? CodeModel.fromJson(json['type']):null,
      isRead: json['is_read']==1?true:false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      sentAt: DateTime.parse(json['sent_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data.toJson(),
      'type': type!.toJson(),
      'is_read': isRead?1:0,
      'read_at': readAt?.toIso8601String(),
      'sent_at': sentAt.toIso8601String(),
    };
  }

  bool get isUnread => isRead == 0;
}

class NotificationData {
  final String? tip;
  final String? articleId;
  final String? allergyId;
  final String? organizationId;
  final String? reactionId;
  final String? medicationId;
  final String? invoiceId;
  final String? medicationRequestId;
  final String? time;
  final String? appointmentId;
  final String? doctorId;
  final String? encounterId;
  final String? serviceRequestId;
  final String? observationId;
  final String? imagingStudyId;
  final String? seriesId;
  final String? conditionId;
  final String? diagnosticReportId;
  final String? complaintId;

  NotificationData({
    this.tip,
    this.articleId,
    this.allergyId,
    this.organizationId,
    this.reactionId,
    this.medicationId,
    this.medicationRequestId,
    this.time,
    this.invoiceId,
    this.appointmentId,
    this.doctorId,
    this.encounterId,
    this.serviceRequestId,
    this.observationId,
    this.imagingStudyId,
    this.seriesId,
    this.conditionId,
    this.diagnosticReportId,
    this.complaintId,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      tip: json['tip']?.toString(),
      articleId: json['article_id']?.toString(),
      allergyId: json['allergy_id']?.toString(),
      organizationId: json['organization_id']?.toString(),
      reactionId: json['reaction_id']?.toString(),
      medicationId: json['medication_id']?.toString(),
      medicationRequestId: json['medication_request_id']?.toString(),
      time: json['time']?.toString(),
      appointmentId: json['appointment_id']?.toString(),
      invoiceId: json['invoice_id']?.toString(),
      doctorId: json['doctor_id']?.toString(),
      encounterId: json['encounter_id']?.toString(),
      serviceRequestId: json['service_request_id']?.toString(),
      observationId: json['observation_id']?.toString(),
      imagingStudyId: json['imaging_study_id']?.toString(),
      seriesId: json['series_id']?.toString(),
      conditionId: json['condition_id']?.toString(),
      diagnosticReportId: json['diagnostic_report_id']?.toString(),
      complaintId: json['complaint_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tip != null) 'tip': tip,
      if (articleId != null) 'article_id': articleId,
      if (allergyId != null) 'allergy_id': allergyId,
      if (organizationId != null) 'organization_id': organizationId,
      if (reactionId != null) 'reaction_id': reactionId,
      if (medicationId != null) 'medication_id': medicationId,
      if (medicationRequestId != null) 'medication_request_id': medicationRequestId,
      if (time != null) 'time': time,
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (doctorId != null) 'doctor_id': doctorId,
      if (encounterId != null) 'encounter_id': encounterId,
      if (serviceRequestId != null) 'service_request_id': serviceRequestId,
      if (observationId != null) 'observation_id': observationId,
      if (imagingStudyId != null) 'imaging_study_id': imagingStudyId,
      if (seriesId != null) 'series_id': seriesId,
      if (conditionId != null) 'condition_id': conditionId,
      if (diagnosticReportId != null) 'diagnostic_report_id': diagnosticReportId,
      if (complaintId != null) 'complaint_id': complaintId,
      if (invoiceId != null) 'invoice_id': invoiceId,
    };
  }
}
enum NotificationType {
  articleCreated,
  allergyCreated,
  allergyUpdated,
  allergyDeleted,
  organizationUpdated,
  reactionCreated,
  reactionUpdated,
  reactionDeleted,
  invoiceCreated,
  invoiceUpdated,
  invoiceCanceled,
  serviceRequestCreated,
  serviceRequestUpdated,
  serviceRequestChangedStatus,
  serviceRequestCanceled,
  serviceRequestChangedStatusForLabOrRadiology,
  observationCreated,
  observationUpdated,
  observationChangedStatus,
  imagingStudyCreated,
  imagingStudyUpdated,
  imagingStudyChangedStatus,
  seriesCreated,
  seriesUpdated,
  encounterCreated,
  encounterUpdated,
  appointmentCreated,
  appointmentUpdated,
  appointmentCanceled,
  conditionCreated,
  conditionUpdated,
  conditionCanceled,
  reminderAppointment,
  medicationRequestCreated,
  medicationRequestUpdated,
  medicationRequestCanceled,
  medicationCreated,
  medicationUpdated,
  medicationCanceled,
  diagnosticReportCreated,
  diagnosticReportUpdated,
  diagnosticReportCanceled,
  diagnosticReportFinalized,
  complaintCreated,
  complaintResolved,
  complaintRejected,
  complaintClosed,
  complaintResponded,
  dailyHealthTip,
  reminderMedication,
  unknown
}

extension NotificationTypeExtension on NotificationModel {
  NotificationType get typeNotification {
    if (type == null) return NotificationType.unknown;

    // First handle medical record cases which need special ID checking
    if (type!.code == 'MEDICAL_RECORD_UPDATED' ||
        type!.code == 'MEDICAL_RECORD_CREATED' ||
        type!.code == 'MEDICAL_RECORD_DELETED') {
      return _handleMedicalRecordType();
    }

    // Handle all other standard cases
    switch (type!.code) {
      case 'UPDATE_ORGANIZATION':
        return NotificationType.organizationUpdated;
      case 'NEW_ARTICLE':
        return NotificationType.articleCreated;
      case 'NEW_APPOINTMENT':
        return NotificationType.appointmentCreated;
      case 'UPDATED_APPOINTMENT':
        return NotificationType.appointmentUpdated;
      case 'CANCELLED_APPOINTMENT':
        return NotificationType.appointmentCanceled;
      case 'LAB_RESULT_READY':
      case 'IMG_RESULT_READY':
        return NotificationType.diagnosticReportCreated;
      case 'INVOICE_CREATED':
        return NotificationType.invoiceCreated;
      case 'INVOICE_UPDATED':
        return NotificationType.invoiceUpdated;
      case 'NEW_PRESCRIPTION':
        return NotificationType.medicationRequestCreated;
      case 'ADMIN_BROADCAST':
        return NotificationType.unknown; // Or create a new type if needed
      case 'HEALTH_TIP':
        return NotificationType.dailyHealthTip;
      case 'NEW_COMPLAINT':
        return NotificationType.complaintCreated;
      case 'COMPLAINT_RESOLVED':
        return NotificationType.complaintResolved;
      case 'COMPLAINT_REJECTED':
        return NotificationType.complaintRejected;
      case 'COMPLAINT_CLOSED':
        return NotificationType.complaintClosed;
      case 'COMPLAINT_RESPONDED':
        return NotificationType.complaintResponded;
      case 'REMINDER_APPOINTMENT':
        return NotificationType.reminderAppointment;
      case 'REMINDER_MEDICATION':
        return NotificationType.reminderMedication;
      default:
        return NotificationType.unknown;
    }
  }

  NotificationType _handleMedicalRecordType() {
    // Check which specific medical record type this is based on the data IDs
    if (data.conditionId != null) {
      if (type!.code == 'MEDICAL_RECORD_CREATED') return NotificationType.conditionCreated;
      if (type!.code == 'MEDICAL_RECORD_UPDATED') return NotificationType.conditionUpdated;
      if (type!.code == 'MEDICAL_RECORD_DELETED') return NotificationType.conditionCanceled;
    }
    else if (data.medicationRequestId != null) {
      if (type!.code == 'MEDICAL_RECORD_CREATED') return NotificationType.medicationRequestCreated;
      if (type!.code == 'MEDICAL_RECORD_UPDATED') return NotificationType.medicationRequestUpdated;
      if (type!.code == 'MEDICAL_RECORD_DELETED') return NotificationType.medicationRequestCanceled;
    }
    else if (data.diagnosticReportId != null) {
      if (type!.code == 'MEDICAL_RECORD_CREATED') return NotificationType.diagnosticReportCreated;
      if (type!.code == 'MEDICAL_RECORD_UPDATED') return NotificationType.diagnosticReportUpdated;
      if (type!.code == 'MEDICAL_RECORD_DELETED') return NotificationType.diagnosticReportCanceled;
    }
    else if (data.allergyId != null) {
      if (type!.code == 'MEDICAL_RECORD_CREATED') return NotificationType.allergyCreated;
      if (type!.code == 'MEDICAL_RECORD_UPDATED') return NotificationType.allergyUpdated;
      if (type!.code == 'MEDICAL_RECORD_DELETED') return NotificationType.allergyDeleted;
    }
    else if (data.observationId != null) {
      if (type!.code == 'MEDICAL_RECORD_CREATED') return NotificationType.observationCreated;
      if (type!.code == 'MEDICAL_RECORD_UPDATED') return NotificationType.observationUpdated;
    }
    else if (data.imagingStudyId != null) {
      if (type!.code == 'MEDICAL_RECORD_CREATED') return NotificationType.imagingStudyCreated;
      if (type!.code == 'MEDICAL_RECORD_UPDATED') return NotificationType.imagingStudyUpdated;
    }
    else if (data.serviceRequestId != null) {
      if (type!.code == 'MEDICAL_RECORD_CREATED') return NotificationType.serviceRequestCreated;
      if (type!.code == 'MEDICAL_RECORD_UPDATED') return NotificationType.serviceRequestUpdated;
    }
    else if (data.encounterId != null) {
      if (type!.code == 'MEDICAL_RECORD_CREATED') return NotificationType.encounterCreated;
      if (type!.code == 'MEDICAL_RECORD_UPDATED') return NotificationType.encounterUpdated;
    }

    return NotificationType.unknown;
  }
}