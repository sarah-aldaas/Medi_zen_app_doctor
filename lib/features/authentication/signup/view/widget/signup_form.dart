import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/go_router/go_router.dart';
import '../../cubit/signup_cubit.dart';
import '../../cubit/signup_state.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Signup Successful!')));
        } else if (state is SignupError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // First Name Field
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  hintText: "sign_up_page.first_name".tr(context),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0xFF47BD93),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "sign_up_page.validation.first_name_required".tr(
                      context,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Last Name Field
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  hintText: "sign_up_page.last_name".tr(context),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0xFF47BD93),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "sign_up_page.validation.last_name_required".tr(
                      context,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "sign_up_page.email".tr(context),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF47BD93)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "sign_up_page.validation.email_required".tr(context);
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return "sign_up_page.validation.email_invalid".tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: "sign_up_page.password".tr(context),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF47BD93)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "sign_up_page.validation.password_required".tr(
                      context,
                    );
                  }
                  if (value.length < 6) {
                    return "sign_up_page.validation.password_length".tr(
                      context,
                    );
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
                    icon: Icon(
                      _obscureConfirmText
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmText = !_obscureConfirmText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "sign_up_page.validation.confirm_password_required"
                        .tr(context);
                  }
                  if (value != _passwordController.text) {
                    return "sign_up_page.validation.passwords_not_match".tr(
                      context,
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Sign Up Button
              ElevatedButton(
                onPressed: () {
                  context.goNamed(AppRouter.homePage.name);
                  // if (_formKey.currentState!.validate()) {
                  //   context.read<SignupCubit>().signup(_firstNameController.text, _lastNameController.text, _emailController.text, _passwordController.text);
                  // }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                child:
                    state is SignupLoading
                        ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : Text(
                          "sign_up_page.sign_up".tr(context),
                          style: TextStyle(color: Colors.white),
                        ),
              ),
              const SizedBox(height: 20),

              // Already have an account? Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("sign_up_page.already_have_account".tr(context)),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(AppRouter.login.name);
                    },
                    child: Text(
                      "sign_up_page.login".tr(context),
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
