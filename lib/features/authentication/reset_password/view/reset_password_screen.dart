import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../base/theme/app_color.dart';
import '../../../../base/theme/app_style.dart';
import '../../change_password/view/change_password_page.dart';
import '../../forget_password/view/forget_password.dart';
import '../cubit/reset_password_cubit.dart';
import '../cubit/reset_password_state.dart';


class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  List<String> _otp = List.generate(6, (index) => '');

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResetPasswordCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Reset Password', style: AppStyles.appBarTitle),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForgotPasswordScreen(),
                ),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 180),
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Text(
                    'Check your email',
                    textAlign: TextAlign.center,
                    style: AppStyles.heading,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'please enter your 6-digit code. Then create and confirm your new password',
                    style: AppStyles.bodyText,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      6,
                          (index) => Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _otp[index] = value;
                                if (index < 5 && value.isNotEmpty) {
                                  FocusScope.of(context).nextFocus();
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
                    listener: (context, state) {
                      if (state is ResetPasswordSuccess) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordPage(),
                          ),
                        );
                      } else if (state is ResetPasswordFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error)),
                        );
                      }
                    },
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed:
                        state is ResetPasswordLoading
                            ? null
                            : () {
                          context
                              .read<ResetPasswordCubit>()
                              .resetPassword(_otp.join());
                        },
                        child: state is ResetPasswordLoading
                            ? CircularProgressIndicator(color: AppColors.whiteColor)
                            : Text('Reset Password',
                            style: AppStyles.bodyText
                                .copyWith(color: AppColors.whiteColor)),
                        style: AppStyles.primaryButtonStyle,
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                    },
                    child: Text(
                      "Send another code",
                      style: AppStyles.bodyText.copyWith(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
