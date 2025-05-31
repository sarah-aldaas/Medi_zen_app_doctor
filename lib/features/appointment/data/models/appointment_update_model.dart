class AppointmentUpdateModel {
  final String reason;
  final String description;
  final String? note;

  AppointmentUpdateModel({required this.reason, required this.description, this.note});

  factory AppointmentUpdateModel.fromJson(Map<String, dynamic> json) {
    return AppointmentUpdateModel(reason: json['reason'] as String, description: json['description'] as String, note: json['note'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'reason': reason, 'description': description, 'note': note};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppointmentUpdateModel && reason == other.reason && description == other.description && note == other.note;

  @override
  int get hashCode => Object.hash(reason, description, note);
}
