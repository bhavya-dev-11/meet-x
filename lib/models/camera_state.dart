// lib/models/camera_state.dart
import 'package:camera/camera.dart';

enum CameraStatus {
  initial,
  permissionDenied,
  permissionGranted,
  cameraReady,
  capturing,
  captured,
  error,
}

class CameraState {
  final CameraStatus status;
  final CameraController? controller;
  final bool isFlashOn;
  final String? capturedImagePath;
  final String? errorMessage;

  CameraState({
    required this.status,
    this.controller,
    this.isFlashOn = false,
    this.capturedImagePath,
    this.errorMessage,
  });

  CameraState copyWith({
    CameraStatus? status,
    CameraController? controller,
    bool? isFlashOn,
    String? capturedImagePath,
    String? errorMessage,
    bool clearCapturedImagePath = false,
    bool clearErrorMessage = false,
  }) {
    return CameraState(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      capturedImagePath:
          clearCapturedImagePath
              ? null
              : (capturedImagePath ?? this.capturedImagePath),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  factory CameraState.initial() {
    return CameraState(status: CameraStatus.initial);
  }
}
