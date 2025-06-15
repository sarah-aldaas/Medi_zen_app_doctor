import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';

import '../../../encounters/data/models/encounter_model.dart';
import '../../../reactions/data/models/reaction_model.dart';

class AllergyModel {
  final String? id;
  final String? name;
  final String? onSetAge;
  final String? lastOccurrence;
  final String? discoveredDuringEncounter;
  final String? note;
  final CodeModel? type;
  final CodeModel? clinicalStatus;
  final CodeModel? verificationStatus;
  final CodeModel? category;
  final CodeModel? criticality;
  final List<ReactionModel>? reactions;
  final EncounterModel? encounter;

  AllergyModel({
    required this.id,
    required this.name,
    required this.onSetAge,
    required this.lastOccurrence,
    required this.discoveredDuringEncounter,
    this.note,
    required this.type,
    required this.clinicalStatus,
    required this.verificationStatus,
    required this.category,
    required this.criticality,
    required this.reactions,
    required this.encounter,
  });

  factory AllergyModel.fromJson(Map<String, dynamic> json) {
    return AllergyModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      onSetAge: json['on_set_age'].toString(),
      lastOccurrence: json['last_occurrence'].toString(),
      discoveredDuringEncounter: json['discovered_during_encounter'].toString(),
      note: json['note'].toString(),
      type: json['type'] != null ? CodeModel.fromJson(json['type']) : null,
      clinicalStatus: json['clinical_status'] != null ? CodeModel.fromJson(json['clinical_status']) : null,
      verificationStatus: json['verification_status'] != null ? CodeModel.fromJson(json['verification_status']) : null,
      category: json['category'] != null ? CodeModel.fromJson(json['category']) : null,
      criticality: json['criticality'] != null ? CodeModel.fromJson(json['criticality']) : null,
      reactions: json['reactions'] != null ? List<ReactionModel>.from(json['reactions'].map((x) => ReactionModel.fromJson(x))) : [],
      encounter: json['encounter'] != null ? EncounterModel.fromJson(json['encounter']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'on_set_age': onSetAge,
      'last_occurrence': lastOccurrence,
      'discovered_during_encounter': discoveredDuringEncounter,
      'note': note,
      'type': type!.toJson(),
      'clinical_status': clinicalStatus!.toJson(),
      'verification_status': verificationStatus!.toJson(),
      'category': category!.toJson(),
      'criticality': criticality!.toJson(),
      'reactions': reactions!.map((x) => x.toJson()).toList(),
      'encounter': encounter!.toJson(),
    };
  }

  Map<String, dynamic> createJson({required String patientId}) {
    return {
      'name': name,
      'on_set_age': onSetAge,
      'last_occurrence': lastOccurrence,
      'discovered_during_encounter': discoveredDuringEncounter,
      'note': note,
      'type_id': type!.id,
      'clinical_status_id': clinicalStatus!.id,
      'verification_status_id': verificationStatus!.id,
      'category_id': category!.id,
      'criticality_id': criticality!.id,
      'encounter_id': encounter!.id,
      'patient_id': patientId,
    };
  }
}
