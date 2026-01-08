// lib/controllers/otp_controller.dart
import 'package:flutter/material.dart';
import 'package:meetzone/services/api_service.dart';
import 'package:meetzone/widgets/custom_snackbar.dart';

class OtpController {
  final formKey = GlobalKey<FormState>();

  final otpController = TextEditingController();
  final String email;

  bool isLoading = false;
  bool isResending = false;

  OtpController({required this.email});

  Future<bool> verifyOtp(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false))
      return Future.value(false);

    isLoading = true;
    isLoading = true;
    (context as Element).markNeedsBuild();

    return AuthService.verifyOtp(email: email, otp: otpController.text.trim())
        .then((_) {
          // Navigate to profile setup
          Navigator.of(context).popAndPushNamed('/login');
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

  Future<void> resendOtp(BuildContext context) async {
    isResending = true;
    isResending = true;
    (context as Element).markNeedsBuild();

    return AuthService.resendOtp(email: email)
        .then((_) {
          // Show success message
          CustomSnackbar.showSuccess(context, 'OTP sent successfully!');
        })
        .catchError((e) {
          final error = e.toString().replaceAll('Exception: ', '');
          CustomSnackbar.showError(context, error);
        })
        .whenComplete(() {
          isResending = false;
          (context as Element).markNeedsBuild();
        });
  }

  void dispose() {
    otpController.dispose();
  }
}


