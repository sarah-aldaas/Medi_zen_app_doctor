import 'package:medi_zen_app_doctor/features/medical_record/observation/data/models/qualified_value_model.dart';

import '../../../../../base/data/models/code_type_model.dart';

class ObservationDefinitionModel {
  final String? id;
  final String? version;
  final String? name;
  final String? title;
  final String? description;
  final String? purpose;
  final String? lastRenewDate;
  final String? preferredReportName;
  final CodeModel? type;
  final CodeModel? status;
  final CodeModel? classification;
  final CodeModel? method;
  final CodeModel? bodySite;
  final CodeModel? permittedUnit;
  final List<QualifiedValueModel> qualifiedValues;

  ObservationDefinitionModel({
    this.id,
    this.version,
    this.name,
    this.title,
    this.description,
    this.purpose,
    this.lastRenewDate,
    this.preferredReportName,
    this.type,
    this.status,
    this.classification,
    this.method,
    this.bodySite,
    this.permittedUnit,
    required this.qualifiedValues,
  });

  factory ObservationDefinitionModel.fromJson(Map<String, dynamic> json) {
    return ObservationDefinitionModel(
      id: json['id']?.toString(),
      version: json['version']?.toString(),
      name: json['name']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      purpose: json['purpose']?.toString(),
      lastRenewDate: json['last_renew_date']?.toString(),
      preferredReportName: json['preferred_report_name']?.toString(),
      type: json['type'] != null ? CodeModel.fromJson(json['type']) : null,
      status: json['status'] != null ? CodeModel.fromJson(json['status']) : null,
      classification: json['classification'] != null
          ? CodeModel.fromJson(json['classification'])
          : null,
      method: json['method'] != null ? CodeModel.fromJson(json['method']) : null,
      bodySite: json['body_site'] != null ? CodeModel.fromJson(json['body_site']) : null,
      permittedUnit: json['permitted_unit'] != null
          ? CodeModel.fromJson(json['permitted_unit'])
          : null,
      qualifiedValues: json['qualified_values'] != null
          ? (json['qualified_values'] as List)
          .map((e) => QualifiedValueModel.fromJson(e))
          .toList()
          : <QualifiedValueModel>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'name': name,
      'title': title,
      'description': description,
      'purpose': purpose,
      'last_renew_date': lastRenewDate,
      'preferred_report_name': preferredReportName,
      'type': type?.toJson(),
      'status': status?.toJson(),
      'classification': classification?.toJson(),
      'method': method?.toJson(),
      'body_site': bodySite?.toJson(),
      'permitted_unit': permittedUnit?.toJson(),
      'qualified_values': qualifiedValues.map((e) => e.toJson()).toList(),
    };
  }

}