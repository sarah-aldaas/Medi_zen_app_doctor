import 'package:equatable/equatable.dart';

import '../../../../base/data/models/code_type_model.dart';
import '../../../clinics/data/models/clinic_model.dart';
import '../../../profile/data/models/communication_model.dart';
import '../../../profile/data/models/qualification_model.dart';
import '../../../profile/data/models/telecom_model.dart';

class DoctorModel extends Equatable {
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
  final String? dateOfBirth;
  final String? deceasedDate;
  final String? email;
  final String? emailVerifiedAt;
  final String? genderId;
  final String? clinicId;
  final bool? active;
  final CodeModel? gender;
  final List<TelecomModel>? telecoms;
  final List<CommunicationModel>? communications;
  final List<QualificationModel>? qualifications;
  final ClinicModel? clinic;
  final List<RoleModel>? roles;

  const DoctorModel({
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
    this.genderId,
    this.telecoms,
    this.communications,
    this.qualifications,
    this.clinic,
    this.clinicId,
    this.roles,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
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
      genderId: json['gender_id']?.toString(),
      clinicId: json['clinic_id']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      deceasedDate: json['deceased_date']?.toString(),
      email: json['email']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      active: json['active'] == 1,
      gender: json['gender'] != null
          ? CodeModel.fromJson(json['gender'] as Map<String, dynamic>)
          : null,
      telecoms: json['telecoms'] != null
          ? (json['telecoms'] as List).map((telecomJson) =>
          TelecomModel.fromJson(telecomJson as Map<String, dynamic>)).toList()
          : null,
      communications: json['communications'] != null
          ? (json['communications'] as List).map((commJson) =>
          CommunicationModel.fromJson(commJson as Map<String, dynamic>)).toList()
          : null,
      qualifications: json['qualifications'] != null
          ? (json['qualifications'] as List).map((qualJson) =>
          QualificationModel.fromJson(qualJson as Map<String, dynamic>)).toList()
          : null,
      clinic: json['clinic'] != null
          ? ClinicModel.fromJson(json['clinic'] as Map<String, dynamic>)
          : null,
      roles: json['roles'] != null
          ? (json['roles'] as List).map((roleJson) =>
          RoleModel.fromJson(roleJson as Map<String, dynamic>)).toList()
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
      'date_of_birth': dateOfBirth,
      'deceased_date': deceasedDate,
      'email': email,
      'clinic_id': clinicId,
      'gender_id': genderId,
      'email_verified_at': emailVerifiedAt,
      'active': active ?? false ? 1 : 0,
      'gender': gender?.toJson(),
      'telecoms': telecoms?.map((t) => t?.toJson()).whereType<Map<String, dynamic>>().toList(),
      'communications': communications?.map((c) => c?.toJson()).whereType<Map<String, dynamic>>().toList(),
      'qualifications': qualifications?.map((q) => q?.toJson()).whereType<Map<String, dynamic>>().toList(),
      'clinic': clinic?.toJson(),
      'roles': roles?.map((r) => r?.toJson()).whereType<Map<String, dynamic>>().toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    fName,
    lName,
    text,
    family,
    given,
    prefix,
    suffix,
    avatar,
    address,
    dateOfBirth,
    deceasedDate,
    email,
    emailVerifiedAt,
    active,
    gender,
    genderId,
    clinicId,
    telecoms,
    communications,
    qualifications,
    clinic,
    roles,
  ];
}

class RoleModel {
  final String? id;
  final String? name;
  final String? guardName;

  RoleModel({
    this.id,
    this.name,
    this.guardName,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      guardName: json['guard_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'guard_name': guardName,
    };
  }
}

// Keep your existing CodeModel and TelecomModel classes