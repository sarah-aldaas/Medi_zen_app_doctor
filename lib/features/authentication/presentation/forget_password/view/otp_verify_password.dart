import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../../base/services/di/injection_container_common.dart';
import '../../../../../base/theme/app_color.dart';
import '../cubit/otp_verify_password_cubit.dart';

class OtpVerifyPassword extends StatefulWidget {
  final String email;

  const OtpVerifyPassword({super.key, required this.email});

  @override
  State<OtpVerifyPassword> createState() => _OtpVerifyPasswordState();
}

class _OtpVerifyPasswordState extends State<OtpVerifyPassword> {
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<OtpVerifyPasswordCubit>(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              context.pop();
            },
          ),
          centerTitle: true,
          title: Text(
            "otp_verification_page.title".tr(context),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocConsumer<OtpVerifyPasswordCubit, OtpVerifyPasswordState>(
            listener: (context, state) {
              if (state is OtpSuccess) {
                // ShowToast.showToastSuccess(message: state.message);
                context.goNamed(
                  AppRouter.resetPassword.name,
                  extra: {'email': widget.email},
                );
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
                      // width: context.width,
                      height: context.height / 3,
                      child: ClipOval(
                        child: Image.asset(
                          "assets/images/otp.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "otp_verification_page.enter_otp".tr(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 15),
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
                    ElevatedButton(
                      onPressed:
                          isLoadingVerify
                              ? null
                              : () {
                                if (_otpController.text.length == 6) {
                                  context
                                      .read<OtpVerifyPasswordCubit>()
                                      .verifyOtp(
                                        email: widget.email,
                                        otp: _otpController.text,
                                      );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a valid -digit OTP',
                                      ),
                                      backgroundColor: Colors.deepOrange,
                                    ),
                                  );
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.width / 3,
                          vertical: 12,
                        ),
                      ),
                      child:
                          isLoadingVerify
                              ? LoadingButton()
                              : Text(
                                "otp_verification_page.verify".tr(context),
                                style: const TextStyle(color: Colors.white),
                              ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
