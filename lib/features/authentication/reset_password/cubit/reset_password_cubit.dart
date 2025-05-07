import 'package:bloc/bloc.dart';
import 'package:medi_zen_app_doctor/features/authentication/reset_password/cubit/reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super(ResetPasswordInitial());

  Future<void> resetPassword(String otp) async {
    emit(ResetPasswordLoading());
    try {
      if (otp.length == 6) {
        emit(ResetPasswordSuccess());
      } else {
        emit(ResetPasswordFailure("Invalid OTP"));
      }
    } catch (e) {
      emit(ResetPasswordFailure(e.toString()));
    }
  }
}
