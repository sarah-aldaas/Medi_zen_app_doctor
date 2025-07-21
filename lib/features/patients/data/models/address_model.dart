import '../../../../base/data/models/code_type_model.dart';

class AddressModel {
  final String? id;
  final String? country;
  final String? city;
  final String? state;
  final String? district;
  final String? line;
  final String? text;
  final String? postalCode;
  final String? startDate;
  final String? endDate;
  final CodeModel? use;
  final CodeModel? type;

  AddressModel({
    required this.id,
    required this.country,
    required this.city,
    required this.state,
    required this.district,
    required this.line,
    required this.text,
    required this.postalCode,
    this.startDate,
    this.endDate,
    required this.use,
    required this.type,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      district: json['district']?.toString(),
      line: json['line']?.toString(),
      text: json['text']?.toString(),
      postalCode: json['postal_code']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      use:json['use_id'] !=null? CodeModel.fromJson(json['use_id'] as Map<String, dynamic>):null,
      type: json['type_id']!=null? CodeModel.fromJson(json['type_id'] as Map<String, dynamic>):null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'city': city,
      'state': state,
      'district': district,
      'line': line,
      'text': text,
      'postal_code': postalCode,
      'start_date': startDate,
      'end_date': endDate,
      'use_id': use!.toJson(),
      'type_id': type!.toJson(),
    };
  }
}

class AddOrUpdateAddressModel {
  final String? id;
  final String? country;
  final String? city;
  final String? state;
  final String? district;
  final String? line;
  final String? text;
  final String? postalCode;
  final String? startDate;
  final String? endDate;
  final CodeModel? use;
  final CodeModel? type;

  AddOrUpdateAddressModel({
    required this.id,
    required this.country,
    required this.city,
    required this.state,
    required this.district,
    required this.line,
    required this.text,
    required this.postalCode,
    this.startDate,
    this.endDate,
    required this.use,
    required this.type,
  });

  factory AddOrUpdateAddressModel.fromJson(Map<String, dynamic> json) {
    return AddOrUpdateAddressModel(
      id: json['id'].toString(),
      country: json['country'].toString(),
      city: json['city'].toString(),
      state: json['state'].toString(),
      district: json['district'].toString(),
      line: json['line'].toString(),
      text: json['text'].toString(),
      postalCode: json['postal_code'].toString(),
      startDate: json['start_date'].toString(),
      endDate: json['end_date'] != null ? json['end_date'].toString() : null,
      use: CodeModel.fromJson(json['use_id'] as Map<String, dynamic>),
      type: CodeModel.fromJson(json['type_id'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'city': city,
      'state': state,
      'district': district,
      'line': line,
      'text': text,
      'postal_code': postalCode,
      'start_date': startDate,
      'end_date': endDate,
      'use_id': use!.id.toString(),
      'type_id': type!.id.toString(),
    };
  }
}
