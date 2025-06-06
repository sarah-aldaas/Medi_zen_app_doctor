import 'package:bloc/bloc.dart';
import 'package:medi_zen_app_doctor/features/doctor/data/datasource/doctor_remote_datasource.dart';
import 'package:meta/meta.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../authentication/data/models/doctor_model.dart';

part 'doctor_state.dart';

class DoctorCubit extends Cubit<DoctorState> {
  final DoctorRemoteDataSource remoteDataSource;
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false;
  List<DoctorModel> allDoctors = [];

  DoctorCubit({required this.remoteDataSource}) : super(DoctorInitial());

  Future<void> getDoctorsOfClinic({required String clinicId}) async {
    try {
      final result = await remoteDataSource.getDoctorsOfClinic(
        clinicId: clinicId,
        page: currentPage,
        perPage: 4,
      );

      if (result is Success<PaginatedResponse<DoctorModel>>) {
        final newDoctors = result.data.paginatedData?.items ?? [];
        allDoctors.addAll(newDoctors);

        final totalPages = result.data.meta?.lastPage ?? 1;
        hasMore = currentPage < totalPages;
        if (hasMore) {
          currentPage++;
        }

        emit(
          LoadedDoctorsOfClinicSuccess(
            allDoctors: allDoctors,
            hasMore: hasMore,
          ),
        );
      } else if (result is ResponseError<PaginatedResponse<DoctorModel>>) {
        emit(DoctorError(error: result.message ?? 'Failed to fetch doctors'));
      }
    } finally {
      isLoading = false;
    }
  }
}
