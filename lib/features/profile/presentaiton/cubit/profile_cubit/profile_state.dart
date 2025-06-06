part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, success, error, loadignUpdate }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final DoctorModel? doctorModel;
  final String errorMessage;

  const ProfileState({
    required this.status,
    this.doctorModel,
    this.errorMessage = '',
  });

  factory ProfileState.initial() {
    return const ProfileState(status: ProfileStatus.initial);
  }

  factory ProfileState.loading() {
    return const ProfileState(status: ProfileStatus.loading);
  }

  factory ProfileState.loadingUpdate() {
    return const ProfileState(status: ProfileStatus.loadignUpdate);
  }

  factory ProfileState.success(DoctorModel? doctorModel) {
    return ProfileState(status: ProfileStatus.success, doctorModel: doctorModel);
  }

  factory ProfileState.error(String errorMessage) {
    return ProfileState(
      status: ProfileStatus.error,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, doctorModel, errorMessage];
}
