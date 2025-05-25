import '../../../../base/data/models/code_type_model.dart';

class CommunicationModel {
  final String? id;
  final bool? preferred;
  final CodeModel? language;

  CommunicationModel({
    required this.id,
    required this.preferred,
    required this.language,
  });

  factory CommunicationModel.fromJson(Map<String, dynamic> json) {
    return CommunicationModel(
      id: json['id'].toString(),
      preferred: json['preferred'] as bool,
      language:json['language']!=null? CodeModel.fromJson(json['language'] as Map<String, dynamic>):null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'preferred': preferred,
      'language': language!.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CommunicationModel &&
              id == other.id &&
              preferred == other.preferred &&
              language == other.language;

  @override
  int get hashCode => Object.hash(id, preferred, language);
}

