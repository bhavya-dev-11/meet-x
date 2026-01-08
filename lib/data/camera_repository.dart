// lib/data/camera_repository.dart
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class CameraRepository {
  CameraController? _controller;

  /// Check if camera permission is granted
  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Initialize camera with the first available back camera
  Future<CameraController> initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Find back camera, fallback to first camera
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      return _controller!;
    } catch (e) {
      throw Exception('Failed to initialize camera: $e');
    }
  }

  /// Toggle flash mode
  Future<void> toggleFlash(bool enable) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      await _controller!.setFlashMode(enable ? FlashMode.torch : FlashMode.off);
    } catch (e) {
      throw Exception('Failed to toggle flash: $e');
    }
  }

  /// Capture image and return the file path
  Future<String> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    try {
      final image = await _controller!.takePicture();
      return image.path;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  /// Check if photo library permission is granted
  /// Note: On Android 13+, image_picker handles permissions automatically
  Future<bool> checkPhotoLibraryPermission() async {
    // On Android, image_picker handles permissions automatically
    // We'll just return true and let the picker handle it
    return true;
  }

  /// Request photo library permission
  /// Note: On Android 13+, image_picker handles permissions automatically
  Future<bool> requestPhotoLibraryPermission() async {
    // On Android, image_picker handles permissions automatically
    // We'll just return true and let the picker handle it
    return true;
  }

  /// Pick image from gallery
  /// The image_picker package handles permissions automatically
  Future<String?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // High quality for better OCR
      );

      if (image != null) {
        return image.path;
      }
      return null;
    } catch (e) {
      // If user denies permission or cancels, return null
      if (e.toString().contains('photo_access_denied') ||
          e.toString().contains('User cancelled')) {
        return null;
      }
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  /// Dispose camera controller
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}


