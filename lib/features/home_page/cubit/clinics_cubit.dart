import 'package:bloc/bloc.dart';

import 'clinic.dart';
import 'clinics_state.dart';

class ClinicCubit extends Cubit<ClinicState> {
  ClinicCubit() : super(ClinicInitial());

  void loadClinics() async {
    emit(ClinicLoading());
    try {
      List<Clinic> clinics = [
        Clinic(
          'Emergency & Orthopedic Surgery',
          'Emergency and bone-related surgical care.',
        ),
        Clinic('Ophthalmology', 'Eye care and vision treatment.'),
        Clinic('Dentistry', 'Dental check-ups and treatments.'),
        Clinic('Radiology & Panoramic X-ray', 'Imaging services.'),
        Clinic(
          'Gynecology, Emergency & Orthopedics',
          'Women\'s health, emergency, and bone care.',
        ),
        Clinic('Cardiology', 'Heart health and related treatments.'),
        Clinic('Internal Medicine', 'General medical care for adults.'),
        Clinic('Urology', 'Care for the urinary system.'),
        Clinic('Dermatology', 'Skin conditions and treatments.'),
        Clinic(
          'Nerve Conduction Studies',
          'Diagnostic tests for nerve function.',
        ),
        Clinic('Pulmonology', 'Care for lung and respiratory issues.'),
        Clinic('Gastroenterology', 'Care for digestive system health.'),
        Clinic('Endocrinology & Diabetes', 'Hormone and diabetes management.'),
        Clinic('Neurology', 'Care for conditions of the nervous system.'),
        Clinic('Vascular', 'Care for blood vessels.'),
        Clinic('Joints', 'Care for joint-related issues.'),
        Clinic('Physical Therapy', 'Rehabilitation and movement therapy.'),
        Clinic('General Surgery', 'General surgical procedures.'),
      ];
      emit(ClinicLoaded(clinics));
    } catch (e) {
      emit(ClinicError(e.toString()));
    }
  }
}
