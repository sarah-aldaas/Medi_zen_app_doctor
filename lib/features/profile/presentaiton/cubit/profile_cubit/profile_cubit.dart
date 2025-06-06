import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';
import 'package:medi_zen_app_doctor/features/authentication/data/models/doctor_model.dart';
import 'package:medi_zen_app_doctor/features/profile/data/data_sources/profile_remote_data_sources.dart';

import '../../../../../base/constant/storage_key.dart';
import '../../../../../base/services/di/injection_container_common.dart';
import '../../../../../base/services/storage/storage_service.dart';
import '../../../data/models/update_profile_request_Model.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this.remoteDataSource})
    : super(ProfileState.initial());

  final ProfileRemoteDataSource remoteDataSource;

  Future<void> fetchMyProfile() async {
    if (isClosed) return;
    emit(ProfileState.loading());
    try {
      final result = await remoteDataSource.getMyProfile();
      if (isClosed) return;
      result.fold(
        success: (DoctorModel doctor) {
          if (isClosed) return;
          serviceLocator<StorageService>().savePatient(
            StorageKey.doctorModel,
            doctor,
          );
          emit(ProfileState.success(doctor));
        },
        error: (String? message, int? code, DoctorModel? data) {
          if (isClosed) return;
          emit(ProfileState.error(message ?? 'Failed to fetch profile'));
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(ProfileState.error('Unexpected error: ${e.toString()}'));
    }
  }

  Future<void> updateMyProfile({
    required UpdateProfileRequestModel updateProfileRequestModel,
  }) async {
    if (isClosed) return;
    emit(ProfileState.loadingUpdate());
    try {
      final result = await remoteDataSource.updateMyProfile(
        updateProfileRequestModel: updateProfileRequestModel,
      );
      if (isClosed) return;
      result.fold(
        success: (PublicResponseModel updatedPatient) {
          if (isClosed) return;
          emit(ProfileState.success(null));
        },
        error: (String? message, int? code, PublicResponseModel? data) {
          if (isClosed) return;
          emit(ProfileState.error(message ?? 'Failed to update profile'));
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(ProfileState.error('Unexpected error: ${e.toString()}'));
    }
  }
}
