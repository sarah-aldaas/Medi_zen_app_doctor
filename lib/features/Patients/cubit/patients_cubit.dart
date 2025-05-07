import 'package:bloc/bloc.dart';
import 'package:medi_zen_app_doctor/features/Patients/cubit/patients_state.dart';

import '../model/patient_model.dart';

class PatientCubit extends Cubit<PatientState> {
  PatientCubit() : super(PatientState(patients: _initialPatients()));

  static List<Patient> _initialPatients() {
    return [
      Patient(name: 'ليلى أحمد', condition: 'مستقرة', recordId: '123'),
      Patient(name: 'يوسف محمد', condition: 'يتحسن', recordId: '456'),
      Patient(name: 'سارة علي', condition: 'بحاجة لمتابعة', recordId: '789'),
      Patient(name: 'خالد إبراهيم', condition: 'تحت العلاج', recordId: '101'),
      Patient(name: 'نورة حسن', condition: 'متعافية', recordId: '112'),
    ];
  }
}
