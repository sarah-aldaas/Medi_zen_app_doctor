import 'package:equatable/equatable.dart';

import '../model/medical_record_model.dart';

class MedicalRecordState extends Equatable {
  final List<Encounter> encounters;

  MedicalRecordState({required this.encounters});

  @override
  List<Object> get props => [encounters];
}
