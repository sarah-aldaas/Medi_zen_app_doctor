import 'package:equatable/equatable.dart';
import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';
import 'package:medi_zen_app_doctor/features/profile/data/models/telecom_model.dart';

import 'address_model.dart';

class PatientModel extends Equatable {
  final String? id;
  final String? fName;
  final String? lName;
  final String? text;
  final String? family;
  final String? given;
  final String? prefix;
  final String? suffix;
  final String? avatar;
  final String? dateOfBirth;
  final String? height;
  final String? weight;
  final String? smoker;
  final String? alcoholDrinker;
  final String? deceasedDate;
  final String email;
  final String? emailVerifiedAt;
  final String? active;
  final String? genderId;
  final String? maritalStatusId;
  final String? bloodId;
  final String createdAt;
  final String updatedAt;
  final CodeModel? gender;
  final CodeModel? maritalStatus;
  final CodeModel? bloodType;
  final AddressModel? addressModel; // Single address or null
  final List<TelecomModel>? telecoms; // List of telecoms

  const PatientModel({
    required this.id,
    required this.fName,
    required this.lName,
    this.text,
    this.family,
    this.given,
    this.prefix,
    this.suffix,
    this.avatar,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.smoker,
    this.alcoholDrinker,
    this.deceasedDate,
    required this.email,
    this.emailVerifiedAt,
    required this.active,
    required this.genderId,
    required this.maritalStatusId,
    this.bloodId,
    required this.createdAt,
    required this.updatedAt,
    this.gender,
    this.maritalStatus,
    this.bloodType,
    this.addressModel,
    this.telecoms,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id']?.toString(),
      fName: json['f_name']?.toString(),
      lName: json['l_name']?.toString(),
      text: json['text']?.toString(),
      family: json['family']?.toString(),
      given: json['given']?.toString(),
      prefix: json['prefix']?.toString(),
      suffix: json['suffix']?.toString(),
      avatar: json['avatar']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      height: json['height']?.toString(),
      weight: json['weight']?.toString(),
      smoker: json['smoker']?.toString(),
      alcoholDrinker: json['alcohol_drinker']?.toString(),
      deceasedDate: json['deceased_date']?.toString(),
      email: json['email']?.toString() ?? '',
      emailVerifiedAt: json['email_verified_at']?.toString(),
      active: json['active']?.toString(),
      genderId: json['gender_id']?.toString(),
      maritalStatusId: json['marital_status_id']?.toString(),
      bloodId: json['blood_id']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      gender:json['gender']!=null? CodeModel.fromJson(json['gender'] as Map<String, dynamic>):null,
      maritalStatus: json['marital_status']!=null?CodeModel.fromJson(json['marital_status'] as Map<String, dynamic>):null,
      bloodType:
      json['blood_type'] != null
          ? CodeModel.fromJson(json['blood_type'] as Map<String, dynamic>)
          : json['blood'] != null
          ? CodeModel.fromJson(json['blood'] as Map<String, dynamic>)
          : null,
      // Handle addresses as a single AddressModel (first item if array) or null
      addressModel: json.containsKey('addresses')
          ? (json['addresses'] is List && (json['addresses'] as List).isNotEmpty
          ? AddressModel.fromJson((json['addresses'] as List).first as Map<String, dynamic>)
          : (json['addresses'] is Map
          ? AddressModel.fromJson(json['addresses'] as Map<String, dynamic>)
          : null)):null,
      // Handle telecoms as a list from a 'telecoms' key (adjust key if different)
      telecoms: json.containsKey('telecoms')?
      json['telecoms'] != null
          ? (json['telecoms'] as List).map((telecomJson) => TelecomModel.fromJson(telecomJson as Map<String, dynamic>)).toList()
          : null:null,
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
      'date_of_birth': dateOfBirth,
      'height': height,
      'weight': weight,
      'smoker': smoker,
      'alcohol_drinker': alcoholDrinker,
      'deceased_date': deceasedDate,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'active': active,
      'gender_id': genderId,
      'marital_status_id': maritalStatusId,
      'blood_id': bloodId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'gender': gender!.toJson(),
      'marital_status': maritalStatus!.toJson(),
      'blood_type': bloodType?.toJson(),
      'blood': bloodType?.toJson(),
      'addresses': addressModel?.toJson(), // Convert single address to JSON
      'telecoms': telecoms?.map((t) => t.toJson()).toList(), // Convert list of telecoms to JSON
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
    dateOfBirth,
    height,
    weight,
    smoker,
    alcoholDrinker,
    deceasedDate,
    email,
    emailVerifiedAt,
    active,
    genderId,
    maritalStatusId,
    bloodId,
    createdAt,
    updatedAt,
    gender,
    maritalStatus,
    bloodType,
    addressModel,
    telecoms,
  ];
}
