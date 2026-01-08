// lib/controllers/visiting_card_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/data/visiting_card_repository.dart';
import 'package:meetzone/models/visiting_card_state.dart';

class VisitingCardNotifier extends Notifier<VisitingCardState> {
  late final VisitingCardRepository _repository;
  // Fixed: Removed invalid mounted checks

  @override
  VisitingCardState build() {
    _repository = VisitingCardRepository();
    return VisitingCardState.initial();
  }

  /// Scan a visiting card from the captured image
  Future<void> scanCard(String imagePath) async {
    try {
      // Set uploading state
      state = state.copyWith(
        status: VisitingCardStatus.uploading,
        uploadProgress: 0.0,
        errorMessage: null,
      );

      // Upload and scan the card with progress tracking
      final visitingCard = await _repository.scanVisitingCard(
        imagePath: imagePath,
        onUploadProgress: (progress) {
          // Safely update state during upload
          try {
            state = state.copyWith(uploadProgress: progress);
          } catch (_) {
            // Ignore if state update fails (e.g., notifier disposed)
          }
        },
      );

      // Set processing state (API is processing the image)
      state = state.copyWith(
        status: VisitingCardStatus.processing,
        uploadProgress: 1.0,
      );

      // Once we receive the response, set completed state
      state = state.copyWith(
        status: VisitingCardStatus.completed,
        visitingCard: visitingCard,
      );
    } catch (e) {
      // Safely handle errors
      try {
        state = state.copyWith(
          status: VisitingCardStatus.error,
          errorMessage: e.toString(),
        );
      } catch (_) {
        // Ignore if state update fails
      }
    }
  }

  /// Reset the state to initial
  void reset() {
    state = VisitingCardState.initial();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}


