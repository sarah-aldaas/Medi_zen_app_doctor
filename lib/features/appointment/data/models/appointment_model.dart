
import '../../../../base/data/models/code_type_model.dart';
import '../../../patients/data/models/patient_model.dart';
import '../../../authentication/data/models/doctor_model.dart';

class AppointmentModel {
  final String? id;
  final String? reason;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? minutesDuration;
  final String? note;
  final String? cancellationDate;
  final String? cancellationReason;
  final CodeModel? type;
  final CodeModel? status;
  final DoctorModel? doctor;
  final PatientModel? patient;
  final dynamic previousAppointment;
  final DoctorModel? createdByPractitioner;

  AppointmentModel({
    required this.id,
    required this.reason,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.minutesDuration,
    this.note,
    this.cancellationDate,
    this.cancellationReason,
    required this.type,
    required this.status,
    required this.doctor,
    required this.patient,
    this.previousAppointment,
    this.createdByPractitioner,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'].toString(),
      reason: json['reason'].toString(),
      description: json['description'].toString(),
      startDate: json['start_date'].toString(),
      endDate: json['end_date'].toString(),
      minutesDuration: json['minutes_duration'].toString(),
      note: json['note'].toString(),
      cancellationDate: json['cancellation_date'].toString(),
      cancellationReason: json['cancellation_reason'].toString(),
      type: json['type']!=null?CodeModel.fromJson(json['type'] as Map<String, dynamic>):null,
      status:json['status']!=null? CodeModel.fromJson(json['status'] as Map<String, dynamic>):null,
      doctor:json['doctor']!=null? DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>):null,
      patient:json['patient']!=null? PatientModel.fromJson(json['patient'] as Map<String, dynamic>):null,
      previousAppointment: json['previous_appointment'],
      createdByPractitioner: json['created_by_practitioner']!=null? DoctorModel.fromJson(json['created_by_practitioner'] as Map<String, dynamic>):null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
      'minutes_duration': minutesDuration,
      'note': note,
      'cancellation_date': cancellationDate,
      'cancellation_reason': cancellationReason,
      'type': type!.toJson(),
      'status': status!.toJson(),
      'doctor': doctor!.toJson(),
      'patient': patient!.toJson(),
      'previous_appointment': previousAppointment,
      'created_by_practitioner': createdByPractitioner!.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppointmentModel &&
              id == other.id &&
              reason == other.reason &&
              description == other.description &&
              startDate == other.startDate &&
              endDate == other.endDate &&
              minutesDuration == other.minutesDuration &&
              note == other.note &&
              cancellationDate == other.cancellationDate &&
              cancellationReason == other.cancellationReason &&
              type == other.type &&
              status == other.status &&
              doctor == other.doctor &&
              patient == other.patient &&
              previousAppointment == other.previousAppointment &&
              createdByPractitioner == other.createdByPractitioner;

  @override
  int get hashCode => Object.hash(
    id,
    reason,
    description,
    startDate,
    endDate,
    minutesDuration,
    note,
    cancellationDate,
    cancellationReason,
    type,
    status,
    doctor,
    patient,
    previousAppointment,
    createdByPractitioner,
  );
}