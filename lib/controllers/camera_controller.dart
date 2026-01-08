// lib/controllers/camera_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/data/camera_repository.dart';
import 'package:meetzone/models/camera_state.dart';

class CameraNotifier extends Notifier<CameraState> {
  late final CameraRepository _repository;

  @override
  CameraState build() {
    _repository = CameraRepository();

    // Automatically dispose repository (and camera) when this provider is disposed
    ref.onDispose(() {
      _repository.dispose();
    });

    return CameraState.initial();
  }

  /// Initialize camera with permission check
  Future<void> initialize() async {
    try {
      // Check permission first
      final hasPermission = await _repository.checkCameraPermission();

      if (!hasPermission) {
        // Request permission
        final granted = await _repository.requestCameraPermission();

        if (!granted) {
          state = state.copyWith(
            status: CameraStatus.permissionDenied,
            errorMessage:
                'Camera permission is required to scan business cards',
          );
          return;
        }
      }

      state = state.copyWith(status: CameraStatus.permissionGranted);

      // Initialize camera
      final controller = await _repository.initializeCamera();

      state = state.copyWith(
        status: CameraStatus.cameraReady,
        controller: controller,
      );
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Toggle flash on/off
  Future<void> toggleFlash() async {
    try {
      final newFlashState = !state.isFlashOn;
      await _repository.toggleFlash(newFlashState);
      state = state.copyWith(isFlashOn: newFlashState);
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Capture image
  Future<void> captureImage() async {
    try {
      state = state.copyWith(status: CameraStatus.capturing);

      final imagePath = await _repository.captureImage();

      state = state.copyWith(
        status: CameraStatus.captured,
        capturedImagePath: imagePath,
      );
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Retake image (reset to camera ready state)
  void retake() {
    state = state.copyWith(
      status: CameraStatus.cameraReady,
      clearCapturedImagePath: true,
    );
  }

  /// Pick image from gallery with permission check
  /// Note: image_picker handles permissions automatically on modern Android/iOS
  Future<void> pickFromGallery() async {
    try {
      // Pick image from gallery (permissions handled by image_picker)
      final imagePath = await _repository.pickImageFromGallery();

      if (imagePath != null) {
        state = state.copyWith(
          status: CameraStatus.captured,
          capturedImagePath: imagePath,
        );
      }
      // If null, user cancelled - no error needed
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Dispose camera resources when notifier is disposed
  void disposeCamera() {
    _repository.dispose();
  }
}
