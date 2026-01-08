// lib/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:meetzone/models/auth_response.dart';
import 'package:meetzone/services/api_service.dart';
import 'package:meetzone/services/storage_service.dart';
import 'package:meetzone/widgets/custom_snackbar.dart';

class LoginController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<bool> login(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false))
      return Future.value(false);

    isLoading = true;
    isLoading = true;
    (context as Element).markNeedsBuild();

    return AuthService.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        )
        .then((data) async {
          final authResponse = AuthResponse.fromJson(data);

          await StorageService.saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
          );
          await StorageService.saveUser(authResponse.user);

          if (authResponse.user.profileCompleted &&
              authResponse.user.businessSetupCompleted) {
            await StorageService.saveCurrentRoute('/dashboard');
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (!authResponse.user.profileCompleted) {
            await StorageService.saveCurrentRoute('/profile-setup');
            Navigator.of(context).pushReplacementNamed('/profile-setup');
          } else {
            await StorageService.saveCurrentRoute('/business-setup');
            Navigator.of(context).pushReplacementNamed('/business-setup');
          }
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
  }
}


