import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../base/constant/storage_key.dart';
import '../../../../../base/data/models/respons_model.dart';
import '../../../../../base/error/exception.dart';
import '../../../../../base/services/di/injection_container_common.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/storage/storage_service.dart';
import '../../../../../main.dart';
import '../../../data/datasource/auth_remote_data_source.dart';
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRemoteDataSource authRemoteDataSource;

  LoginCubit({required this.authRemoteDataSource}) : super(LoginInitial());

  void login(String email, String password) async {
    emit(LoginLoading());

    try {
      final result = await authRemoteDataSource.login(
        email: email,
        password: password,
      );

      if (result is Success<AuthResponseModel>) {
        if (result.data.status) {
          final loginData = result.data.loginData;
          if (loginData != null) {
            token = loginData.token;
            serviceLocator<StorageService>().saveToDisk(
              StorageKey.token,
              token,
            );
            serviceLocator<StorageService>().savePatient(
              StorageKey.doctorModel,
              loginData.doctor,
            );
            emit(LoginSuccess(message: result.data.msg));
          } else {
            emit(LoginError(error: _parseErrorMessage(result.data.msg)));
          }
        } else {
          // Handle the case when status is false
          emit(LoginError(error: _parseErrorMessage(result.data.msg)));
        }
      }
    } on ServerException catch (e) {
      emit(LoginError(error: e.message));
    } catch (e) {
      emit(LoginError(error: 'Unexpected error: ${e.toString()}'));
    }
  }

  // Helper method to parse the error message
  String _parseErrorMessage(dynamic msg) {
    String errorMessage = '';
    if (msg is Map<String, dynamic>) {
      msg.forEach((key, value) {
        if (value is List) {
          errorMessage += '${key.capitalize()}: ${value.join(', ')}\n';
        } else {
          errorMessage += '${key.capitalize()}: $value\n';
        }
      });
    } else if (msg is String) {
      errorMessage = msg;
    } else {
      errorMessage = 'Unknown error';
    }
    return errorMessage.trim();
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
