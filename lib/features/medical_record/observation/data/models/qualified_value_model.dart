import 'package:medi_zen_app_doctor/features/medical_record/observation/data/models/value_range_model.dart';

import '../../../../../base/data/models/code_type_model.dart';
import 'age_range_model.dart';

class QualifiedValueModel {
  final String? id;
  final AgeRangeModel? ageRange;
  final ValueRangeModel? valueRange;
  final CodeModel? context;
  final CodeModel? appliesTo;
  final CodeModel? gender;
  final CodeModel? rangeCategory;

  QualifiedValueModel({
    this.id,
    this.ageRange,
    this.valueRange,
    this.context,
    this.appliesTo,
    this.gender,
    this.rangeCategory,
  });

  factory QualifiedValueModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return QualifiedValueModel();

    return QualifiedValueModel(
      id: json['id']?.toString(),
      ageRange: json['age_range'] != null
          ? AgeRangeModel.fromJson(json['age_range'])
          : null,
      valueRange: json['value_range'] != null
          ? ValueRangeModel.fromJson(json['value_range'])
          : null,
      context: json['context'] != null
          ? CodeModel.fromJson(json['context'])
          : null,
      appliesTo: json['applies_to'] != null
          ? CodeModel.fromJson(json['applies_to'])
          : null,
      gender: json['gender'] != null
          ? CodeModel.fromJson(json['gender'])
          : null,
      rangeCategory: json['range_category'] != null
          ? CodeModel.fromJson(json['range_category'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'age_range': ageRange?.toJson(),
      'value_range': valueRange?.toJson(),
      'context': context?.toJson(),
      'applies_to': appliesTo?.toJson(),
      'gender': gender?.toJson(),
      'range_category': rangeCategory?.toJson(),
    };
  }

  // Optional: Add a method to check if required fields are present
  bool get isValid =>
      id != null &&
          ageRange != null &&
          valueRange != null &&
          context != null &&
          appliesTo != null &&
          gender != null &&
          rangeCategory != null;

  // Optional: Add copyWith method for easier updates
  QualifiedValueModel copyWith({
    String? id,
    AgeRangeModel? ageRange,
    ValueRangeModel? valueRange,
    CodeModel? context,
    CodeModel? appliesTo,
    CodeModel? gender,
    CodeModel? rangeCategory,
  }) {
    return QualifiedValueModel(
      id: id ?? this.id,
      ageRange: ageRange ?? this.ageRange,
      valueRange: valueRange ?? this.valueRange,
      context: context ?? this.context,
      appliesTo: appliesTo ?? this.appliesTo,
      gender: gender ?? this.gender,
      rangeCategory: rangeCategory ?? this.rangeCategory,
    );
  }

}