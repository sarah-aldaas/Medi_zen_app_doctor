import 'dart:io';
import 'package:equatable/equatable.dart';

class UpdateProfileRequestModel extends Equatable {
  final String? fName;
  final String? lName;
  final File? avatar;
  final String? genderId;
  final String? image;
  final String? dateOfBirth;
  final String? text;
  final String? family;
  final String? given;
  final String? prefix;
  final String? suffix;
  final String? address;

  const UpdateProfileRequestModel({
    this.fName,
    this.lName,
    this.avatar,
    this.genderId,
    this.image,
    this.dateOfBirth,
    this.text,
    this.family,
    this.given,
    this.prefix,
    this.suffix,
    this.address,
  });

  factory UpdateProfileRequestModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileRequestModel(
      fName: json['f_name']?.toString(),
      lName: json['l_name']?.toString(),
      avatar: json['avatar'] != null ? File(json['avatar'] as String) : null,
      genderId: json['gender_id']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      text: json['text']?.toString(),
      family: json['family']?.toString(),
      given: json['given']?.toString(),
      prefix: json['prefix']?.toString(),
      suffix: json['suffix']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'f_name': fName,
      'l_name': lName,
      'gender_id': genderId,
      'date_of_birth': dateOfBirth,
      'text': text,
      'family': family,
      'given': given,
      'prefix': prefix,
      'suffix': suffix,
      'address': address,
    };

    // Only include avatar if it has been changed (non-null in this context means changed)
    if (image == null) {
      if (avatar != null) {
        data['avatar'] = avatar!.path;
      } else {
        data['avatar'] = null;
      }
    }

    return data;
  }

  @override
  List<Object?> get props => [
    fName,
    lName,
    avatar,
    genderId,
    image,
    dateOfBirth,
    text,
    family,
    given,
    prefix,
    suffix,
    address,
  ];
}