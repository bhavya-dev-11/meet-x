// lib/data/visiting_card_repository.dart
import 'package:dio/dio.dart';
import 'package:meetzone/core/app_constants.dart';
import 'package:meetzone/models/visiting_card_model.dart';
import 'package:meetzone/services/api_client.dart';

class VisitingCardRepository {
  /// Scan a visiting card by uploading the image
  /// Returns the scanned visiting card data
  Future<VisitingCard> scanVisitingCard({
    required String imagePath,
    Function(double)? onUploadProgress,
  }) async {
    try {
      // Create form data with the image
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      // Make the API call with upload progress tracking
      // Use extended timeout for image processing (OCR can take time)
      final response = await ApiClient.dio.post(
        ApiConstants.scanVisitingCard,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(
            seconds: 120,
          ), // Extended timeout for image processing
        ),
        onSendProgress: (sent, total) {
          if (onUploadProgress != null && total != -1) {
            final progress = sent / total;
            onUploadProgress(progress);
          }
        },
      );

      // Parse the response
      if (response.statusCode == 201) {
        return VisitingCard.fromJson(response.data);
      } else {
        throw 'Failed to scan visiting card';
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ??
          e.response?.data?['detail'] ??
          'Failed to scan visiting card';
      throw errorMsg;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Get all scanned visiting cards
  Future<List<VisitingCard>> getVisitingCards() async {
    try {
      final response = await ApiClient.dio.get(ApiConstants.getVisitingCards);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => VisitingCard.fromJson(json)).toList();
      } else {
        throw 'Failed to fetch visiting cards';
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Failed to fetch visiting cards';
      throw errorMsg;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Get a specific visiting card by ID
  Future<VisitingCard> getVisitingCardById(String id) async {
    try {
      final response = await ApiClient.dio.get(
        '${ApiConstants.getVisitingCards}/$id',
      );

      if (response.statusCode == 200) {
        return VisitingCard.fromJson(response.data);
      } else {
        throw 'Failed to fetch visiting card';
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Failed to fetch visiting card';
      throw errorMsg;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Delete a visiting card
  Future<void> deleteVisitingCard(String id) async {
    try {
      final response = await ApiClient.dio.delete(
        '${ApiConstants.getVisitingCards}/$id',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw 'Failed to delete visiting card';
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Failed to delete visiting card';
      throw errorMsg;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}


