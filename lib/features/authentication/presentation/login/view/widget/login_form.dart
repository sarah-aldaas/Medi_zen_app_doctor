import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import '../../cubit/login_cubit.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState()  => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          // ShowToast.showToastSuccess(message: state.message);
          context.goNamed(AppRouter.homePage.name);
        } else if (state is LoginError) {
          ShowToast.showToastError(message: state.error);
          if(state.error=="Account is not verified, Please verify your account.") {
            // context.pushNamed(AppRouter.otpVerification.name,extra: {'email': _emailController.text});
          }
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "login_page.email".tr(context),
                  prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "login_page.validation.email_required".tr(context);
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                    return "login_page.validation.email_invalid".tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  hintText: "login_page.password".tr(context),
                  prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
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
                    return "login_page.validation.password_required".tr(context);
                  }
                  if (value.length < 6) {
                    return "login_page.validation.password_length".tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.pushNamed(AppRouter.forgetPassword.name);
                  },
                  child: Text('login_page.forgot_password'.tr(context), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    FocusScope.of(context).unfocus();
                    context.read<LoginCubit>().login(_emailController.text.trim(), _passwordController.text.trim(),context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: context.width / 3, vertical: 15),
                ),
                child:
                state is LoginLoading
                    ? LoadingButton(isWhite: true)
                    : Text('login_page.login'.tr(context), style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}


