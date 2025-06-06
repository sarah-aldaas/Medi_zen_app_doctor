import '../../../services/data/model/health_care_services_model.dart';

class ClinicModel {
  final String id;
  final String name;
  final String description;
  final String photo;
  final bool active;
  final List<HealthCareServiceModel>? healthCareServices;

  ClinicModel({required this.id, required this.name, required this.description, required this.photo, required this.active, this.healthCareServices});

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      description: json['description'].toString(),
      photo: json['photo'].toString(),
      active: (json['active'].toString()) == "1",
      healthCareServices:
          json['healthCareServices'] != null
              ? (json['healthCareServices'] as List).map((item) => HealthCareServiceModel.fromJson(item as Map<String, dynamic>)).toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'photo': photo, 'active': active ? 1 : 0, 'healthCareServices': healthCareServices};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicModel &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          photo == other.photo &&
          active == other.active &&
          healthCareServices == other.healthCareServices;

  @override
  int get hashCode => Object.hash(id, name, description, photo, active, healthCareServices);
}
