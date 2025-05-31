import 'package:equatable/equatable.dart';

class RegisterRequestModel extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String genderId;
  final String maritalStatusId;

  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.genderId,
    required this.maritalStatusId,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      firstName: json['f_name'] as String,
      lastName: json['l_name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      genderId: json['gender_id'] .toString(),
      maritalStatusId: json['marital_status_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'f_name': firstName,
      'l_name': lastName,
      'email': email,
      'password': password,
      'gender_id': genderId,
      'marital_status_id': maritalStatusId.toString(),
    };
  }

  @override
  List<Object> get props => [
    firstName,
    lastName,
    email,
    password,
    genderId,
    maritalStatusId,
  ];
}