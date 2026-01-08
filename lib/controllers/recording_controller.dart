// lib/controllers/recording_controller.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/data/recording_repository.dart';
import 'package:meetzone/models/recording_state.dart';

class RecordingNotifier extends Notifier<RecordingState> {
  late final RecordingRepository _repository;
  Timer? _durationTimer;
  StreamSubscription? _amplitudeSubscription;

  @override
  RecordingState build() {
    _repository = RecordingRepository();
    return RecordingState.initial();
  }

  /// Initialize with meeting participant
  Future<void> initialize(String meetingWith) async {
    try {
      // Check permission
      final hasPermission = await _repository.checkMicrophonePermission();

      if (!hasPermission) {
        final granted = await _repository.requestMicrophonePermission();

        if (!granted) {
          state = state.copyWith(
            status: RecordingStatus.permissionDenied,
            errorMessage:
                'Microphone permission is required to record meetings',
          );
          return;
        }
      }

      state = state.copyWith(
        status: RecordingStatus.ready,
        meetingWith: meetingWith,
      );
    } catch (e) {
      state = state.copyWith(
        status: RecordingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Start recording
  Future<void> startRecording() async {
    try {
      final path = await _repository.startRecording();

      state = state.copyWith(
        status: RecordingStatus.recording,
        recordingPath: path,
        duration: Duration.zero,
      );

      // Start duration timer
      _startDurationTimer();

      // Start amplitude monitoring
      _startAmplitudeMonitoring();
    } catch (e) {
      state = state.copyWith(
        status: RecordingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    try {
      await _repository.pauseRecording();
      _durationTimer?.cancel();

      state = state.copyWith(status: RecordingStatus.paused, audioLevels: []);
    } catch (e) {
      state = state.copyWith(
        status: RecordingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    try {
      await _repository.resumeRecording();
      _startDurationTimer();
      _startAmplitudeMonitoring();

      state = state.copyWith(status: RecordingStatus.recording);
    } catch (e) {
      state = state.copyWith(
        status: RecordingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Stop recording
  Future<void> stopRecording() async {
    try {
      _durationTimer?.cancel();
      _amplitudeSubscription?.cancel();

      final path = await _repository.stopRecording();

      state = state.copyWith(
        status: RecordingStatus.stopped,
        recordingPath: path,
        audioLevels: [],
      );
    } catch (e) {
      state = state.copyWith(
        status: RecordingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Upload recording
  Future<void> uploadRecording() async {
    if (state.recordingPath == null) return;

    try {
      state = state.copyWith(
        status: RecordingStatus.uploading,
        uploadProgress: 0.0,
      );

      // Generate a meeting ID (you might want to get this from elsewhere)
      final meetingId = 'meeting_${DateTime.now().millisecondsSinceEpoch}';

      // Upload the recording
      final meetingSummary = await _repository.uploadRecording(
        filePath: state.recordingPath!,
        meetingId: meetingId,
        participantEmails: null, // TODO: Add participant emails if available
        onProgress: (progress) {
          state = state.copyWith(uploadProgress: progress);
        },
      );

      state = state.copyWith(
        status: RecordingStatus.processing,
        uploadProgress: 1.0,
      );

      // Simulate processing (in real app, the API handles this)
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(
        status: RecordingStatus.completed,
        meetingSummary: meetingSummary,
      );
    } catch (e) {
      state = state.copyWith(
        status: RecordingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Cancel upload
  Future<void> cancelUpload() async {
    if (state.recordingPath != null) {
      await _repository.deleteRecording(state.recordingPath!);
    }

    state = state.copyWith(
      status: RecordingStatus.stopped,
      uploadProgress: 0.0,
    );
  }

  /// Reset to initial state
  void reset() {
    _durationTimer?.cancel();
    _amplitudeSubscription?.cancel();

    if (state.recordingPath != null) {
      _repository.deleteRecording(state.recordingPath!);
    }

    state = RecordingState.initial();
  }

  /// Start duration timer
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        duration: state.duration + const Duration(seconds: 1),
      );
    });
  }

  /// Start amplitude monitoring
  void _startAmplitudeMonitoring() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = _repository.getAmplitudeStream().listen((
      amplitude,
    ) {
      final levels = List<double>.from(state.audioLevels);
      levels.add(amplitude);

      // Keep only last 50 levels for waveform
      if (levels.length > 50) {
        levels.removeAt(0);
      }

      state = state.copyWith(audioLevels: levels);
    });
  }

  /// Dispose resources
  void disposeRecording() {
    _durationTimer?.cancel();
    _amplitudeSubscription?.cancel();
    _repository.dispose();
  }
}
