// lib/models/recording_state.dart
import 'package:meetzone/models/meeting_summary_model.dart';

enum RecordingStatus {
  idle,
  permissionDenied,
  ready,
  recording,
  paused,
  stopped,
  uploading,
  processing,
  completed,
  error,
}

class RecordingState {
  final RecordingStatus status;
  final String? meetingWith;
  final Duration duration;
  final String? recordingPath;
  final double uploadProgress;
  final String? errorMessage;
  final List<double> audioLevels;
  final MeetingSummary? meetingSummary;

  RecordingState({
    required this.status,
    this.meetingWith,
    this.duration = Duration.zero,
    this.recordingPath,
    this.uploadProgress = 0.0,
    this.errorMessage,
    this.audioLevels = const [],
    this.meetingSummary,
  });

  RecordingState copyWith({
    RecordingStatus? status,
    String? meetingWith,
    Duration? duration,
    String? recordingPath,
    double? uploadProgress,
    String? errorMessage,
    List<double>? audioLevels,
    MeetingSummary? meetingSummary,
  }) {
    return RecordingState(
      status: status ?? this.status,
      meetingWith: meetingWith ?? this.meetingWith,
      duration: duration ?? this.duration,
      recordingPath: recordingPath ?? this.recordingPath,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      audioLevels: audioLevels ?? this.audioLevels,
      meetingSummary: meetingSummary ?? this.meetingSummary,
    );
  }

  factory RecordingState.initial() {
    return RecordingState(status: RecordingStatus.idle);
  }

  String get formattedDuration {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
