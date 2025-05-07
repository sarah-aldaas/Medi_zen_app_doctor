import 'package:equatable/equatable.dart';

import '../model/patient_model.dart';

class PatientState extends Equatable {
  final List<Patient> patients;

  PatientState({required this.patients});

  @override
  List<Object> get props => [patients];
}
