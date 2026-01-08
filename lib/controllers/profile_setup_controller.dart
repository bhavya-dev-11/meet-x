// lib/controllers/profile_setup_controller.dart
import 'package:flutter/material.dart';
import 'package:meetzone/services/api_service.dart';
import 'package:meetzone/services/storage_service.dart';
import 'package:meetzone/widgets/custom_snackbar.dart';

class ProfileSetupController {
  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final designationController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;

  Future<bool> submit(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false))
      return Future.value(false);

    isLoading = true;
    (context as Element).markNeedsBuild();

    return AuthService.completeProfile(
          fullName: fullNameController.text.trim(),
          designation: designationController.text.trim(),
          phone: phoneController.text.trim(),
        )
        .then((_) async {
          // Navigate to business setup
          await StorageService.saveCurrentRoute('/business-setup');
          Navigator.of(context).pushReplacementNamed('/business-setup');
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
    fullNameController.dispose();
    designationController.dispose();
    phoneController.dispose();
  }
}


