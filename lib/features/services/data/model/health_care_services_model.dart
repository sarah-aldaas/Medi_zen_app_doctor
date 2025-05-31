import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';
import '../../../clinics/data/models/clinic_model.dart';

class HealthCareServiceModel {
  final String? id;
  final String? name;
  final String? comment;
  final String? extraDetails;
  final String? photo;
  final bool? appointmentRequired;
  final String? price;
  final bool? active;
  final CodeModel? category;
  final ClinicModel? clinic;
  final List<CodeModel>? eligibilities;

  HealthCareServiceModel({
    required this.id,
    required this.name,
    required this.comment,
    this.extraDetails,
    this.photo,
    required this.appointmentRequired,
    required this.price,
    required this.active,
     this.category,
     this.clinic,
     this.eligibilities,
  });

  factory HealthCareServiceModel.fromJson(Map<String, dynamic> json) {
    return HealthCareServiceModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      comment: json['comment'].toString(),
      extraDetails: json['extra_details'].toString(),
      photo: json['photo'].toString(),
      appointmentRequired: (json['appointmentRequired'].toString()) == "1",
      price: json['price'].toString(),
      active: json['active'].toString()=="1"?true:false,
      category:json['category']!=null? CodeModel.fromJson(json['category'] as Map<String, dynamic>):null,
      clinic:json['clinic']!=null?  ClinicModel.fromJson(json['clinic'] as Map<String, dynamic>):null,
      eligibilities:json['eligibilities']!=null? (json['eligibilities'] as List)
          .map((item) => CodeModel.fromJson(item as Map<String, dynamic>))
          .toList():null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'comment': comment,
      'extra_details': extraDetails,
      'photo': photo,
      'appointmentRequired': appointmentRequired.toString()=="1" ? 1 : 0,
      'price': price.toString(),
      'active': active.toString()=="1" ? 1 : 0,
      'category': category!.toJson(),
      'clinic': clinic!.toJson(),
      'eligibilities': eligibilities!.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HealthCareServiceModel &&
              id == other.id &&
              name == other.name &&
              comment == other.comment &&
              extraDetails == other.extraDetails &&
              photo == other.photo &&
              appointmentRequired == other.appointmentRequired &&
              price == other.price &&
              active == other.active &&
              category == other.category &&
              clinic == other.clinic &&
              eligibilities == other.eligibilities;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    comment,
    extraDetails,
    photo,
    appointmentRequired,
    price,
    active,
    category,
    clinic,
    eligibilities,
  );
}


