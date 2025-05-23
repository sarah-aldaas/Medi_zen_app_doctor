import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/theme/app_style.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../cubit/reset_password_cubit.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResetPasswordCubit>(
      create: (context) => ResetPasswordCubit(authRemoteDataSource: serviceLocator()), // Initialize ResetPasswordCubit
      child: _ResetPasswordContent(email: email),
    );
  }
}

class _ResetPasswordContent extends StatefulWidget {
  final String email;

  const _ResetPasswordContent({required this.email});

  @override
  _ResetPasswordContentState createState() => _ResetPasswordContentState();
}

class _ResetPasswordContentState extends State<_ResetPasswordContent> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          // ShowToast.showToastSuccess(message: state.message);
          context.goNamed(AppRouter.login.name);
        } else if (state is ResetPasswordFailure) {
          ShowToast.showToastError(message: state.error);
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(onPressed: (){
                context.pop();
              }, icon: Icon(Icons.arrow_back_ios,color: Colors.grey,)),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 50),
                    Text(
                      "Reset Password",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Enter your new password for login to your account",
                      textAlign: TextAlign.center,
                      style: AppStyles.instructionTextStyle,
                    ),
                    const SizedBox(height: 60),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: "sign_up_page.password".tr(context),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF47BD93)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "sign_up_page.validation.password_required".tr(context);
                        }
                        if (value.length < 6) {
                          return "sign_up_page.validation.password_length".tr(context);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmText,
                      decoration: InputDecoration(
                        hintText: "sign_up_page.confirm_password".tr(context),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF47BD93)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmText ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmText = !_obscureConfirmText;
                            });
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "sign_up_page.validation.confirm_password_required".tr(context);
                        }
                        if (value != _passwordController.text) {
                          return "sign_up_page.validation.passwords_not_match".tr(context);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ResetPasswordCubit>().resetPassword(
                            email: widget.email,
                            newPassword: _passwordController.text.trim(),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: context.width / 3, vertical: 15),
                      ),
                      child: state is ResetPasswordLoading
                          ?  LoadingButton(isWhite: true)
                          : Text(
                        "forgotPassword.buttons.continue".tr(context),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}