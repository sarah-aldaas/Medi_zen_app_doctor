import 'health_care_services_model.dart';

class HealthCareServiceEligibilityCodesModel {
  final int id;
  final String comment;
  final HealthCareServiceModel healthCareService;

  HealthCareServiceEligibilityCodesModel({
    required this.id,
    required this.comment,
    required this.healthCareService,
  });

  factory HealthCareServiceEligibilityCodesModel.fromJson(Map<String, dynamic> json) {
    return HealthCareServiceEligibilityCodesModel(
      id: json['id'] as int,
      comment: json['comment'] as String,
      healthCareService: HealthCareServiceModel.fromJson(json['health_care_service'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'health_care_service': healthCareService.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HealthCareServiceEligibilityCodesModel &&
              id == other.id &&
              comment == other.comment &&
              healthCareService == other.healthCareService;

  @override
  int get hashCode => Object.hash(id, comment, healthCareService);
}