import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/theme/app_style.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../cubit/forgot_password_cubit.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordCubit>(
      create:
          (context) =>
              ForgotPasswordCubit(authRemoteDataSource: serviceLocator()),
      child: _ForgotPasswordContent(),
    );
  }
}

class _ForgotPasswordContent extends StatefulWidget {
  @override
  State<_ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<_ForgotPasswordContent> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          // ShowToast.showToastSuccess(message: state.message);
          context.pushNamed(
            AppRouter.verifyPasswordOtp.name,
            extra: {'email': _emailController.text},
          );
        } else if (state is ForgotPasswordError) {
          ShowToast.showToastError(message: state.error);
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: AppColors.primaryColor,
                ),
                onPressed: () {
                  context.pop();
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: context.width,
                      height: context.height / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),

                        child: Image.asset(
                          "assets/images/locks/Forgotpassword-rafiki.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "forgotPassword.title".tr(context),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "forgotPassword.instruction".tr(context),
                      textAlign: TextAlign.center,
                      style: AppStyles.instructionTextStyle,
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "login_page.email".tr(context),
                        prefixIcon: Icon(
                          Icons.email,
                          color: Theme.of(context).primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "login_page.validation.email_required".tr(
                            context,
                          );
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return "login_page.validation.email_invalid".tr(
                            context,
                          );
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ForgotPasswordCubit>().sendResetLink(
                            _emailController.text.trim(),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.width / 3,
                          vertical: 15,
                        ),
                      ),
                      child:
                          state is ForgotPasswordLoading
                              ? LoadingButton(isWhite: true)
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
