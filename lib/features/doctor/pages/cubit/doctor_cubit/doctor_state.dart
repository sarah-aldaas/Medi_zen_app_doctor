part of 'doctor_cubit.dart';

@immutable
sealed class DoctorState {}

final class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {
  final bool isInitialLoad;

  DoctorLoading({this.isInitialLoad = true});
}


class LoadedDoctorsOfClinicSuccess extends DoctorState {
  final List<DoctorModel> allDoctors;
  final bool hasMore;

  LoadedDoctorsOfClinicSuccess({
    required this.allDoctors,
    required this.hasMore,
  });
}


class DoctorError extends DoctorState {
  final String error;

  DoctorError({required this.error});
}
