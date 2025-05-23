import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/features/authentication/data/datasource/auth_remote_data_source.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../base/data/models/respons_model.dart';
import '../../../../../base/error/exception.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRemoteDataSource authRemoteDataSource;

  ResetPasswordCubit({required this.authRemoteDataSource}) : super(ResetPasswordInitial());

  void resetPassword({required String email, required String newPassword}) async {
    emit(ResetPasswordLoading());
    try{
      final result = await authRemoteDataSource.resetPassword(email: email, newPassword: newPassword);

      if (result is Success<AuthResponseModel>) {
        if (result.data.status) {
          emit(ResetPasswordSuccess(message: result.data.msg.toString()));
        } else {
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
            errorMessage = result.data.msg;
          } else {
            errorMessage = 'Unknown error';
          }
          emit(ResetPasswordFailure(error: errorMessage));
        }
      } else if (result is ResponseError<AuthResponseModel>) {
        emit(ResetPasswordFailure(error: result.message ?? 'An error occurred'));
      }
    }on ServerException catch (e) {
      emit(ResetPasswordFailure(error: e.message));
    } catch (e) {
      emit(ResetPasswordFailure(error: 'Unexpected error: ${e.toString()}'));
    }
  }
}
