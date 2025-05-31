import '../../../../../base/data/models/code_type_model.dart';

class ReactionModel {
  final String? id;
  final String? substance;
  final String? manifestation;
  final String? description;
  final String? onSet;
  final String? note;
  final CodeModel? severity;
  final CodeModel? exposureRoute;

  ReactionModel({
    required this.id,
    required this.substance,
    required this.manifestation,
    required this.description,
    required this.onSet,
    this.note,
    required this.severity,
    required this.exposureRoute,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'].toString(),
      substance: json['substance'].toString(),
      manifestation: json['manifestation'].toString(),
      description: json['description'].toString(),
      onSet: json['on_set'].toString(),
      note: json['note'].toString(),
      severity:json['severity']!=null? CodeModel.fromJson(json['severity']):null,
      exposureRoute:json['exposure_route']!=null? CodeModel.fromJson(json['exposure_route']):null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'substance': substance,
      'manifestation': manifestation,
      'description': description,
      'on_set': onSet,
      'note': note,
      'severity': severity!.toJson(),
      'exposure_route': exposureRoute!.toJson(),
    };
  }
}

