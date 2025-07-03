
import '../../../../../base/data/models/code_type_model.dart';
import '../../../conditions/data/models/conditions_model.dart';

class MedicationRequestModel {
  final String? id;
  final String? statusReason;
  final String? statusChanged;
  final bool? doNotPerform;
  final String? reason;
  final String? numberOfRepeatsAllowed;
  final String? note;
  final CodeModel? status;
  final CodeModel? intent;
  final CodeModel? priority;
  final CodeModel? courseOfTherapyType;
  final ConditionsModel? condition;

  MedicationRequestModel({
    this.id,
    this.statusReason,
    this.statusChanged,
    this.doNotPerform,
    this.reason,
    this.numberOfRepeatsAllowed,
    this.note,
    this.status,
    this.intent,
    this.priority,
    this.courseOfTherapyType,
    this.condition,
  });

  factory MedicationRequestModel.fromJson(Map<String, dynamic> json) {
    return MedicationRequestModel(
      id: json['id']?.toString(),
      statusReason: json['status_reason']?.toString(),
      statusChanged: json['status_changed']?.toString(),
      doNotPerform: json['do_not_perform'] == 1,
      reason: json['reason']?.toString(),
      numberOfRepeatsAllowed: json['number_of_repeats_allowed']?.toString(),
      note: json['note']?.toString(),
      status: json['status'] != null ? CodeModel.fromJson(json['status']) : null,
      intent: json['intent'] != null ? CodeModel.fromJson(json['intent']) : null,
      priority: json['priority'] != null ? CodeModel.fromJson(json['priority']) : null,
      courseOfTherapyType: json['course_of_therapy_type'] != null ? CodeModel.fromJson(json['course_of_therapy_type']) : null,
      condition: json['condition'] != null ? ConditionsModel.fromJson(json['condition']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status_reason': statusReason,
      'status_changed': statusChanged,
      'do_not_perform': doNotPerform! ? 1 : 0,
      'reason': reason,
      'number_of_repeats_allowed': numberOfRepeatsAllowed,
      'note': note,
      'status': status?.toJson(),
      'intent': intent?.toJson(),
      'priority': priority?.toJson(),
      'course_of_therapy_type': courseOfTherapyType?.toJson(),
      'condition': condition?.toJson(),
    };
  }
  Map<String, dynamic> createJson() {
    return {
      'status_reason': statusReason,
      'status_changed': statusChanged,
      'do_not_perform': doNotPerform! ? 1 : 0,
      'reason': reason,
      'number_of_repeats_allowed': numberOfRepeatsAllowed,
      'note': note,
      'status': status!.id,
      'intent_id': intent!.id,
      'priority_id': priority!.id,
      'course_of_therapy_type_id': courseOfTherapyType!.id,
      'condition': condition!.id,
    };
  }
}
