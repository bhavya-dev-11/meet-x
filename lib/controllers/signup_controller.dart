// lib/controllers/signup_controller.dart
import 'package:flutter/material.dart';
import 'package:meetzone/services/api_service.dart';
import 'package:meetzone/widgets/custom_snackbar.dart';

class SignupController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<bool> signup(BuildContext context) async {
    print("sign up is pressed");
    if (!(formKey.currentState?.validate() ?? false))
      return Future.value(false);

    if (passwordController.text != confirmPasswordController.text) {
      CustomSnackbar.showError(context, 'Passwords do not match');
      return Future.value(false);
    }

    isLoading = true;
    isLoading = true;
    (context as Element).markNeedsBuild();

    return AuthService.register(
          email: emailController.text.trim(),
          password: passwordController.text,
        )
        .then((_) {
          Navigator.of(context).pushReplacementNamed(
            '/otp',
            arguments: emailController.text.trim(),
          );
          return true;
        })
        .catchError((e) {
          final error = e.toString().replaceAll('Exception: ', '');
          CustomSnackbar.showError(context, error);
          return false;
        })
        .whenComplete(() {
          isLoading = false;
          (context as Element).markNeedsBuild();
        });
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}


