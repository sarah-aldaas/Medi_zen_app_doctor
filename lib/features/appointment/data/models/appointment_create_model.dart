class AppointmentCreateModel {
  final String reason;
  final String description;
  final String? note;
  final String doctorId;
  final String patientId;
  final String? previousAppointment;
  final String slotId;

  AppointmentCreateModel({
    required this.reason,
    required this.description,
    this.note,
    required this.doctorId,
    required this.patientId,
    this.previousAppointment,
    required this.slotId,
  });

  factory AppointmentCreateModel.fromJson(Map<String, dynamic> json) {
    return AppointmentCreateModel(
      reason: json['reason'].toString(),
      description: json['description'].toString(),
      note: json['note'].toString(),
      doctorId: json['doctor_id'].toString(),
      patientId: json['patient_id'].toString(),
      previousAppointment: json['previous_appointment'].toString(),
      slotId: json['slot_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reason': reason.toString(),
      'description': description.toString(),
      'note': note.toString(),
      'doctor_id': doctorId.toString(),
      'patient_id': patientId.toString(),
      // 'previous_appointment': previousAppointment,
      'slot_id': slotId.toString(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppointmentCreateModel &&
              reason == other.reason &&
              description == other.description &&
              note == other.note &&
              doctorId == other.doctorId &&
              patientId == other.patientId &&
              previousAppointment == other.previousAppointment &&
              slotId == other.slotId;

  @override
  int get hashCode => Object.hash(
    reason,
    description,
    note,
    doctorId,
    patientId,
    previousAppointment,
    slotId,
  );
}