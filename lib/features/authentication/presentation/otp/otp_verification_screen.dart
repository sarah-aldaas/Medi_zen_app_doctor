import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../base/services/di/injection_container_common.dart';
import 'cubit/otp_cubit.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    serviceLocator<OtpCubit>().startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<OtpCubit>(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            "otp_verification_page.title".tr(context),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocConsumer<OtpCubit, OtpState>(
            listener: (context, state) {
              if (state is OtpSuccess) {
                // ShowToast.showToastSuccess(message: state.message);
                context.goNamed(AppRouter.verified.name);
              } else if (state is OtpResendSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.indigo,
                  ),
                );
              } else if (state is OtpError) {
                ShowToast.showToastError(message: state.error);
              }
            },
            builder: (context, state) {
              bool isLoadingVerify = state is OtpLoadingVerify;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: context.width,
                      height: context.height / 2,
                      child: Image.asset(
                        "assets/images/locks/111.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      "otp_verification_page.enter_otp".tr(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "otp_verification_page.sent_to".tr(context) +
                          widget.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _otpController,
                      enabled: !isLoadingVerify,
                      keyboardType: TextInputType.number,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        inactiveFillColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        selectedFillColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Colors.grey,
                        selectedColor: Theme.of(context).primaryColor,
                      ),
                      animationType: AnimationType.fade,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 20),
                    // ElevatedButton(
                    //   onPressed:
                    //       isLoadingVerify
                    //           ? null
                    //           : () {
                    //             if (_otpController.text.length == 6) {
                    //               context.read<OtpCubit>().verifyOtp(email: widget.email, otp: _otpController.text);
                    //             } else {
                    //               ScaffoldMessenger.of(context).showSnackBar(
                    //                 SnackBar(content: Text("otp_verification_page.invalid_otp_error".tr(context)), backgroundColor: Colors.deepOrange),
                    //               );
                    //             }
                    //           },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Theme.of(context).primaryColor,
                    //     padding: EdgeInsets.symmetric(horizontal: context.width / 3, vertical: 12),
                    //   ),
                    //   child:
                    //       isLoadingVerify
                    //           ? LoadingButton(isWhite: true)
                    //           : Text("otp_verification_page.verify".tr(context), style: const TextStyle(color: Colors.white)),
                    // ),
                    // const SizedBox(height: 20),
                    // BlocSelector<OtpCubit, OtpState, (bool, int)>(
                    //   selector: (state) {
                    //     if (state is OtpTimerRunning) {
                    //       return (true, state.seconds);
                    //     }
                    //     return (false, 0);
                    //   },
                    //   builder: (context, timerState) {
                    //     final isTimerRunning = timerState.$1;
                    //     final secondsRemaining = timerState.$2;
                    //     return Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Text(
                    //           isTimerRunning
                    //               ? "otp_verification_page.resend_otp_in".tr(context) + ' ${_formatTime(secondsRemaining)}'
                    //               : "otp_verification_page.didnt_receive_otp".tr(context),
                    //           style: const TextStyle(fontSize: 14),
                    //         ),
                    //         if (!isTimerRunning)
                    //           TextButton(
                    //             onPressed: () {
                    //               context.read<OtpCubit>().resendOtp(email: widget.email);
                    //             },
                    //             child:
                    //                 state is OtpLoadingResend
                    //                     ? LoadingAnimationWidget.hexagonDots(color: Theme.of(context).primaryColor, size: 25)
                    //                     : Text("otp_verification_page.resend_otp".tr(context), style: TextStyle(color: Theme.of(context).primaryColor)),
                    //           ),
                    //       ],
                    //     );
                    //   },
                    // ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
