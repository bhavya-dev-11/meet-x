import 'package:flutter/material.dart';
import 'package:meetzone/models/onboarding_model.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingModel _model = OnboardingModel.defaultData();
  bool _isLoading = false;

  OnboardingModel get model => _model;
  bool get isLoading => _isLoading;

  Future<void> handleSignIn(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    notifyListeners();
    Navigator.pushNamed(context, '/signup');
    
  }

  Future<void> handleCreateAccount(BuildContext context) async {
    Navigator.pushNamed(context, '/login');
  }
}

