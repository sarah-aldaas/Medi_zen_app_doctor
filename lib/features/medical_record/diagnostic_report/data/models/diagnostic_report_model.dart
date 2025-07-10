import '../../../../../base/data/models/code_type_model.dart';
import '../../../conditions/data/models/conditions_model.dart';

class DiagnosticReportModel {
  final String? id;
  final String? name;
  final String? conclusion;
  final String? note;
  final CodeModel? status;
  final ConditionsModel? condition;

  DiagnosticReportModel({
    this.id,
    this.name,
    this.conclusion,
    this.note,
    this.status,
    this.condition,
  });

  factory DiagnosticReportModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticReportModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      conclusion: json['conclusion']?.toString(),
      note: json['note']?.toString(),
      status:
          json['status'] != null ? CodeModel.fromJson(json['status']) : null,
      condition:
          json['condition'] != null
              ? ConditionsModel.fromJson(json['condition'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'conclusion': conclusion,
      'note': note,
      'status': status?.toJson(),
      'condition': condition?.toJson(),
    };
  }
}
