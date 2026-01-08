// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:meetzone/core/app_constants.dart';
import 'package:meetzone/services/api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiConstants.register,
        data: {"email": email, "password": password},
      );
      print('response: ${response}');
      return response.data;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Registration failed';
      throw errorMsg;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiConstants.verifyOtp,
        data: {"email": email, "otp": otp},
      );
      return response.data;
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'OTP verification failed';
      throw errorMsg;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response = await ApiClient.dio.post(
        ApiConstants.resendOtp,
        data: {"email": email},
      );
      return response.data;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Failed to resend OTP';
      throw errorMsg;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiConstants.login,
        data: {"email": email, "password": password},
      );
      return response.data;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Login failed';
      throw errorMsg;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  static Future<Map<String, dynamic>> completeProfile({
    required String fullName,
    required String designation,
    required String phone,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiConstants.completeProfile,
        data: {
          "full_name": fullName,
          "designation": designation,
          "phone": phone,
        },
      );
      return response.data;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Profile setup failed';
      throw errorMsg;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  static Future<Map<String, dynamic>> setupBusiness({
    required String name,
    required String industry,
    required String description,
    required String address,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiConstants.setupBusiness,
        data: {
          "name": name,
          "industry": industry,
          "description": description,
          "address": address,
        },
      );
      return response.data;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Business setup failed';
      throw errorMsg;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  // You'll add more methods here later
}


