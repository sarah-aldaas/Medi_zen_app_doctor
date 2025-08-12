import '../../../../base/data/models/code_type_model.dart';

class TelecomModel {
  final String? id;
  final String? value;
  final String? rank;
  final String? startDate;
  final String? endDate;
  final String? typeId;
  final String? useId;

  final CodeModel? type;
  final CodeModel? use;

  TelecomModel({
    required this.id,
    required this.value,
    required this.rank,
    this.startDate,
    this.endDate,
    required this.type,
    required this.use,

    required this.typeId,
    required this.useId,
  });

  factory TelecomModel.fromJson(Map<String, dynamic> json) {
    return TelecomModel(
      id: json['id'] != null ? json['id'].toString() : null,
      value: json['value'] != null ? json['value'].toString() : null,
      rank: json['rank'] != null ? json['rank'].toString() : null,
      startDate:
          json['start_date'] != null ? json['start_date']?.toString() : null,
      endDate: json['end_date'] != null ? json['end_date']?.toString() : null,
      type:
          json['type'] != null
              ? CodeModel.fromJson(json['type'] as Map<String, dynamic>)
              : null,
      use:
          json['use'] != null
              ? CodeModel.fromJson(json['use'] as Map<String, dynamic>)
              : null,
      typeId:json['type']!=null? json['type']['id'] != null ? json['type']["id"].toString() : null:null,
      useId: json['use']!=null?json['use']['id'] != null ? json['use']["id"].toString() : null:null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'value': value.toString(),
      'rank': rank.toString(),
      'start_date': DateTime.now().toString(),

      'type': type!.toJson(),
      'use': use!.toJson(),
      'use_id': useId.toString(),
      'type_id': typeId.toString(),
    };
  }
}
