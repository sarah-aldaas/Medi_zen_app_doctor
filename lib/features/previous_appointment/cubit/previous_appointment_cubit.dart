import 'package:bloc/bloc.dart';
import 'package:medi_zen_app_doctor/features/previous_appointment/cubit/previous_appointment_state.dart';

import '../../../base/constant/app_images.dart';
import '../model/previous_appointment_model.dart';

class PreviousAppointmentCubit extends Cubit<PreviousAppointmentState> {
  PreviousAppointmentCubit() : super(PreviousAppointmentInitial());

  final List<PreviousAppointment> upcomingAppointments = [
    PreviousAppointment(
      imageUrl: AppAssetImages.photoDoctor2,
      patientFullName: 'Salwa Ahmed',
      appointmentType: "المكالمة الفيديوية",
      appointmentDate: DateTime(2025, 5, 8),
      appointmentTime: '11:00 AM',
      status: "مقبلة",
      patientName: '',
    ),
    PreviousAppointment(
      imageUrl: AppAssetImages.photoDoctor2,
      patientFullName: 'Khaled Ibrahim',
      appointmentType: "المراسلة",
      appointmentDate: DateTime(2025, 5, 9),
      appointmentTime: '04:30 PM',
      status: "مقبلة",
      patientName: '',
    ),
  ];

  final List<PreviousAppointment> completedAppointments = [
    PreviousAppointment(
      imageUrl: AppAssetImages.photoDoctor1, // تغيير الصورة
      patientFullName: 'Amina Al Farsi',
      appointmentType: "استشارة طبية",
      appointmentDate: DateTime(2025, 4, 28), // تغيير التاريخ
      appointmentTime: '10:00 AM',
      status: "مكتملة",
      patientName: '',
    ),
    PreviousAppointment(
      imageUrl: AppAssetImages.photoDoctor1, // تغيير الصورة
      patientFullName: 'Omar Al Babtain',
      appointmentType: "فحص طبي",
      appointmentDate: DateTime(2025, 4, 29), // تغيير التاريخ
      appointmentTime: '01:00 PM',
      status: "مكتملة",
      patientName: '',
    ),
    PreviousAppointment(
      imageUrl: AppAssetImages.photoDoctor2, // تغيير الصورة
      patientFullName: 'Sara Ali',
      appointmentType: "تقييم",
      appointmentDate: DateTime(2025, 4, 30),
      appointmentTime: '02:30 PM',
      status: "مكتملة",
      patientName: '',
    ),
  ];

  void loadUpcomingAppointments() {
    emit(PreviousAppointmentLoading());
    emit(PreviousAppointmentLoaded(upcomingAppointments));
  }

  void loadCompletedAppointments() {
    emit(PreviousAppointmentLoading());
    emit(PreviousAppointmentLoaded(completedAppointments));
  }
}
