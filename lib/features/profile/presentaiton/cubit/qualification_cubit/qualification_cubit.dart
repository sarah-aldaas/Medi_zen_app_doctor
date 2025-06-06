import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/profile/data/models/qualification_model.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../data/data_sources/qualification_remote_data_source.dart';

part 'qualification_state.dart';

class QualificationCubit extends Cubit<QualificationState> {
  final QualificationRemoteDataSource remoteDataSource;

  QualificationCubit({required this.remoteDataSource}) : super(QualificationInitial());

  Future<void> fetchQualifications({
    required String paginationCount,
    int page = 1,
  }) async {
    emit(QualificationLoading());
    final result = await remoteDataSource.getListAllQualifications(
      paginationCount: paginationCount,
    );
    if (result is Success<PaginatedResponse<QualificationModel>>) {
      emit(QualificationSuccess(
        paginatedResponse: result.data,
        currentPage: page,
      ));
    } else if (result is ResponseError<PaginatedResponse<QualificationModel>>) {
      emit(QualificationError(error: result.message ?? 'Failed to fetch qualifications'));
    }
  }

  Future<void> fetchNextPage() async {
    if (state is QualificationSuccess) {
      final currentState = state as QualificationSuccess;
      final nextPage = currentState.currentPage + 1;
      if (nextPage <= currentState.paginatedResponse.meta!.lastPage) {
        emit(QualificationLoading());
        final result = await remoteDataSource.getListAllQualifications(
          paginationCount: currentState.paginatedResponse.meta!.perPage.toString(),
        );
        if (result is Success<PaginatedResponse<QualificationModel>>) {
          emit(QualificationSuccess(
            paginatedResponse: result.data,
            currentPage: nextPage,
          ));
        } else if (result is ResponseError<PaginatedResponse<QualificationModel>>) {
          emit(QualificationError(error: result.message ?? 'Failed to fetch next page'));
        }
      }
    }
  }

  Future<void> fetchPreviousPage() async {
    if (state is QualificationSuccess) {
      final currentState = state as QualificationSuccess;
      final prevPage = currentState.currentPage - 1;
      if (prevPage >= 1) {
        emit(QualificationLoading());
        final result = await remoteDataSource.getListAllQualifications(
          paginationCount: currentState.paginatedResponse.meta!.perPage.toString(),
        );
        if (result is Success<PaginatedResponse<QualificationModel>>) {
          emit(QualificationSuccess(
            paginatedResponse: result.data,
            currentPage: prevPage,
          ));
        } else if (result is ResponseError<PaginatedResponse<QualificationModel>>) {
          emit(QualificationError(error: result.message ?? 'Failed to fetch previous page'));
        }
      }
    }
  }

  Future<void> createQualification({required QualificationModel qualificationModel, required File pdfFile}) async {
    emit(QualificationLoading());
    final result = await remoteDataSource.createQualification(
      qualificationModel: qualificationModel,
      pdfFile: pdfFile,
    );
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        await fetchQualifications(paginationCount: '100');
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(QualificationError(error: result.data.msg ?? 'Failed to create qualification'));
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to create qualification');
      emit(QualificationError(error: result.message ?? 'Failed to create qualification'));
    }
  }

  Future<void> updateQualification({required String id, required QualificationModel qualificationModel, File? pdfFile}) async {
    emit(QualificationLoading());
    final result = await remoteDataSource.updateQualification(
      id: id,
      qualificationModel: qualificationModel,
      pdfFile: pdfFile,
    );
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        await fetchQualifications(paginationCount: '100');
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(QualificationError(error: result.data.msg ?? 'Failed to update qualification'));
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to update qualification');
      emit(QualificationError(error: result.message ?? 'Failed to update qualification'));
    }
  }

  Future<void> deleteQualification({required String id}) async {
    emit(QualificationLoading());
    final result = await remoteDataSource.deleteQualification(id: id);
    if (result is Success<PublicResponseModel>) {
      if (result.data.status) {
        await fetchQualifications(paginationCount: '100');
      } else {
        ShowToast.showToastError(message: result.data.msg);
        emit(QualificationError(error: result.data.msg ?? 'Failed to delete qualification'));
      }
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to delete qualification');
      emit(QualificationError(error: result.message ?? 'Failed to delete qualification'));
    }
  }

  Future<QualificationModel?> showQualification({required String id}) async {
    emit(QualificationLoading());
    final result = await remoteDataSource.showQualification(id: id);
    if (result is Success<QualificationModel>) {
      return result.data;
    } else if (result is ResponseError<QualificationModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to fetch qualification details');
      emit(QualificationError(error: result.message ?? 'Failed to fetch qualification details'));
      return null;
    }
    return null;
  }
}


// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
// import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
// import 'package:medi_zen_app_doctor/features/profile/data/models/qualification_model.dart';
// import '../../../../../base/data/models/pagination_model.dart';
// import '../../../../../base/data/models/public_response_model.dart';
// import '../../../data/data_sources/qualification_remote_data_source.dart';
//
// part 'qualification_state.dart';
//
// class QualificationCubit extends Cubit<QualificationState> {
//   final QualificationRemoteDataSource remoteDataSource;
//
//   QualificationCubit({required this.remoteDataSource}) : super(QualificationInitial());
//
//   Future<void> fetchQualifications({
//     required String paginationCount,
//     int page = 1,
//   }) async {
//     emit(QualificationLoading());
//     final result = await remoteDataSource.getListAllQualifications(
//       paginationCount: paginationCount,
//     );
//     if (result is Success<PaginatedResponse<QualificationModel>>) {
//       emit(QualificationSuccess(
//         paginatedResponse: result.data,
//         currentPage: page,
//       ));
//     } else if (result is ResponseError<PaginatedResponse<QualificationModel>>) {
//       emit(QualificationError(error: result.message ?? 'Failed to fetch qualifications'));
//     }
//   }
//
//   Future<void> fetchNextPage() async {
//     if (state is QualificationSuccess) {
//       final currentState = state as QualificationSuccess;
//       final nextPage = currentState.currentPage + 1;
//       if (nextPage <= currentState.paginatedResponse.meta!.lastPage) {
//         emit(QualificationLoading());
//         final result = await remoteDataSource.getListAllQualifications(
//           paginationCount: currentState.paginatedResponse.meta!.perPage.toString(),
//         );
//         if (result is Success<PaginatedResponse<QualificationModel>>) {
//           emit(QualificationSuccess(
//             paginatedResponse: result.data,
//             currentPage: nextPage,
//           ));
//         } else if (result is ResponseError<PaginatedResponse<QualificationModel>>) {
//           emit(QualificationError(error: result.message ?? 'Failed to fetch next page'));
//         }
//       }
//     }
//   }
//
//   Future<void> fetchPreviousPage() async {
//     if (state is QualificationSuccess) {
//       final currentState = state as QualificationSuccess;
//       final prevPage = currentState.currentPage - 1;
//       if (prevPage >= 1) {
//         emit(QualificationLoading());
//         final result = await remoteDataSource.getListAllQualifications(
//           paginationCount: currentState.paginatedResponse.meta!.perPage.toString(),
//         );
//         if (result is Success<PaginatedResponse<QualificationModel>>) {
//           emit(QualificationSuccess(
//             paginatedResponse: result.data,
//             currentPage: prevPage,
//           ));
//         } else if (result is ResponseError<PaginatedResponse<QualificationModel>>) {
//           emit(QualificationError(error: result.message ?? 'Failed to fetch previous page'));
//         }
//       }
//     }
//   }
//
//   Future<void> createQualification({required QualificationModel qualificationModel}) async {
//     emit(QualificationLoading());
//     final result = await remoteDataSource.createQualification(qualificationModel: qualificationModel);
//     if (result is Success<PublicResponseModel>) {
//       if (result.data.status) {
//         await fetchQualifications(paginationCount: '100');
//       } else {
//         ShowToast.showToastError(message: result.data.msg);
//         emit(QualificationError(error: result.data.msg ?? 'Failed to create qualification'));
//       }
//     } else if (result is ResponseError<PublicResponseModel>) {
//       ShowToast.showToastError(message: result.message ?? 'Failed to create qualification');
//       emit(QualificationError(error: result.message ?? 'Failed to create qualification'));
//     }
//   }
//
//   Future<void> updateQualification({required String id, required QualificationModel qualificationModel}) async {
//     emit(QualificationLoading());
//     final result = await remoteDataSource.updateQualification(id: id, qualificationModel: qualificationModel);
//     if (result is Success<PublicResponseModel>) {
//       if (result.data.status) {
//         await fetchQualifications(paginationCount: '100');
//       } else {
//         ShowToast.showToastError(message: result.data.msg);
//         emit(QualificationError(error: result.data.msg ?? 'Failed to update qualification'));
//       }
//     } else if (result is ResponseError<PublicResponseModel>) {
//       ShowToast.showToastError(message: result.message ?? 'Failed to update qualification');
//       emit(QualificationError(error: result.message ?? 'Failed to update qualification'));
//     }
//   }
//
//   Future<void> deleteQualification({required String id}) async {
//     emit(QualificationLoading());
//     final result = await remoteDataSource.deleteQualification(id: id);
//     if (result is Success<PublicResponseModel>) {
//       if (result.data.status) {
//         await fetchQualifications(paginationCount: '100');
//       } else {
//         ShowToast.showToastError(message: result.data.msg);
//         emit(QualificationError(error: result.data.msg ?? 'Failed to delete qualification'));
//       }
//     } else if (result is ResponseError<PublicResponseModel>) {
//       ShowToast.showToastError(message: result.message ?? 'Failed to delete qualification');
//       emit(QualificationError(error: result.message ?? 'Failed to delete qualification'));
//     }
//   }
//
//   Future<QualificationModel?> showQualification({required String id}) async {
//     emit(QualificationLoading());
//     final result = await remoteDataSource.showQualification(id: id);
//     if (result is Success<QualificationModel>) {
//       return result.data;
//     } else if (result is ResponseError<QualificationModel>) {
//       ShowToast.showToastError(message: result.message ?? 'Failed to fetch qualification details');
//       emit(QualificationError(error: result.message ?? 'Failed to fetch qualification details'));
//       return null;
//     }
//     return null;
//   }
// }