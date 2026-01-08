// lib/providers/camera_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/controllers/camera_controller.dart';
import 'package:meetzone/data/camera_repository.dart';
import 'package:meetzone/models/camera_state.dart';

final cameraRepositoryProvider = Provider<CameraRepository>((ref) {
  return CameraRepository();
});

final cameraProvider =
    NotifierProvider.autoDispose<CameraNotifier, CameraState>(
      CameraNotifier.new,
    );
