import '../../../../../base/data/models/code_type_model.dart';
import '../../../../clinics/data/models/clinic_model.dart';

class LaboratoryModel {
  final String? id;
  final String? fName;
  final String? lName;
  final String? text;
  final String? family;
  final String? given;
  final String? prefix;
  final String? suffix;
  final String? avatar;
  final String? address;
  final DateTime? dateOfBirth;
  final String? deceasedDate;
  final String? email;
  final DateTime? emailVerifiedAt;
  final bool? active;
  final CodeModel? gender;
  final ClinicModel? clinic;

  LaboratoryModel({
    this.id,
    this.fName,
    this.lName,
    this.text,
    this.family,
    this.given,
    this.prefix,
    this.suffix,
    this.avatar,
    this.address,
    this.dateOfBirth,
    this.deceasedDate,
    this.email,
    this.emailVerifiedAt,
    this.active,
    this.gender,
    this.clinic,
  });

  factory LaboratoryModel.fromJson(Map<String, dynamic> json) {
    return LaboratoryModel(
      id: json['id']?.toString(),
      fName: json['f_name']?.toString(),
      lName: json['l_name']?.toString(),
      text: json['text']?.toString(),
      family: json['family']?.toString(),
      given: json['given']?.toString(),
      prefix: json['prefix']?.toString(),
      suffix: json['suffix']?.toString(),
      avatar: json['avatar']?.toString(),
      address: json['address']?.toString(),
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      deceasedDate: json['deceased_date']?.toString(),
      email: json['email']?.toString(),
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'])
          : null,
      active: json['active'] != null
          ? json['active'] == 1 || json['active'] == true
          : null,
      gender: json['gender'] != null
          ? CodeModel.fromJson(json['gender'])
          : null,
      clinic: json['clinic'] != null
          ? ClinicModel.fromJson(json['clinic'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'f_name': fName,
      'l_name': lName,
      'text': text,
      'family': family,
      'given': given,
      'prefix': prefix,
      'suffix': suffix,
      'avatar': avatar,
      'address': address,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'deceased_date': deceasedDate,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'active': active,
      'gender': gender?.toJson(),
      'clinic': clinic?.toJson(),
    };
  }

}