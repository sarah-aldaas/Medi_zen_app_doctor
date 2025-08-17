import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasource/auth_remote_data_source.dart';

part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  final AuthRemoteDataSource authRemoteDataSource;
  Timer? _timer;

  OtpCubit({required this.authRemoteDataSource}) : super(OtpInitial());
  void startTimer() {
    _timer?.cancel();
    int seconds = 5 * 60; // 5 minutes
    emit(OtpTimerRunning(seconds: seconds));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      if (seconds >= 0) {
        emit(OtpTimerRunning(seconds: seconds));
      } else {
        emit(OtpTimerFinished());
        timer.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}