// lib/controllers/business_setup_controller.dart
import 'package:flutter/material.dart';
import 'package:meetzone/services/api_service.dart';
import 'package:meetzone/services/storage_service.dart';
import 'package:meetzone/widgets/custom_snackbar.dart';

class BusinessSetupController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final industryController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();

  bool isLoading = false;

  Future<bool> submit(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false))
      return Future.value(false);

    isLoading = true;
    (context as Element).markNeedsBuild();

    return AuthService.setupBusiness(
          name: nameController.text.trim(),
          industry: industryController.text.trim(),
          description: descriptionController.text.trim(),
          address: addressController.text.trim(),
        )
        .then((_) async {
          // Navigate to dashboard
          await StorageService.saveCurrentRoute('/dashboard');
          Navigator.of(context).pushReplacementNamed('/dashboard');
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
    nameController.dispose();
    industryController.dispose();
    descriptionController.dispose();
    addressController.dispose();
  }
}


