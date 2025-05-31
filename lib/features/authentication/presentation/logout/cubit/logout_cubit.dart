import 'package:bloc/bloc.dart';
import 'package:medi_zen_app_doctor/base/constant/storage_key.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
import 'package:medi_zen_app_doctor/base/services/storage/storage_service.dart';
import 'package:meta/meta.dart';

import '../../../../../base/data/models/respons_model.dart';
import '../../../../../base/error/exception.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../data/datasource/auth_remote_data_source.dart';

part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final AuthRemoteDataSource authRemoteDataSource;

  LogoutCubit({required this.authRemoteDataSource}) : super(LogoutInitial());

  void sendResetLink(int allDevices) async {
    if (allDevices == 1) {
      emit(LogoutLoadingAllDevices());
    } else {
      emit(LogoutLoadingOnlyThisDevice());
    }
    try {
      final result = await authRemoteDataSource.logout(allDevices: allDevices);

      if (result is Success<AuthResponseModel>) {
        if (result.data.status) {
          serviceLocator<StorageService>().removeFromDisk(StorageKey.token);
          serviceLocator<StorageService>().removeFromDisk(
            StorageKey.doctorModel,
          );
          emit(LogoutSuccess(message: result.data.msg.toString()));
        } else {
          // serviceLocator<StorageService>().removeFromDisk(StorageKey.token);

          String errorMessage = '';
          if (result.data.msg is Map<String, dynamic>) {
            // Handle nested error messages
            (result.data.msg as Map<String, dynamic>).forEach((key, value) {
              if (value is List) {
                errorMessage += value.join(', '); // Join list of errors
              } else {
                errorMessage += value.toString();
              }
            });
          } else if (result.data.msg is String) {
            // serviceLocator<StorageService>().removeFromDisk(StorageKey.token);

            errorMessage = result.data.msg;
          } else {
            // serviceLocator<StorageService>().removeFromDisk(StorageKey.token);

            errorMessage = 'Unknown error';
          }
          // serviceLocator<StorageService>().removeFromDisk(StorageKey.token);

          emit(LogoutError(error: errorMessage));
        }
      } else if (result is ResponseError<AuthResponseModel>) {
        // serviceLocator<StorageService>().removeFromDisk(StorageKey.token);

        emit(LogoutError(error: result.message ?? 'An error occurred'));
      }
    } on ServerException catch (e) {
      // serviceLocator<StorageService>().removeFromDisk(StorageKey.token);

      emit(LogoutError(error: e.message));
    } catch (e) {
      // serviceLocator<StorageService>().removeFromDisk(StorageKey.token);

      emit(LogoutError(error: 'Unexpected error: ${e.toString()}'));
    }
  }
}
