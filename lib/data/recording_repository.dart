// lib/data/recording_repository.dart
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:meetzone/models/meeting_summary_model.dart';
import 'package:meetzone/services/api_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingRepository {
  FlutterSoundRecorder? _recorder;
  StreamController<double>? _amplitudeController;
  bool _isRecorderInitialized = false;

  /// Check if microphone permission is granted
  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Initialize recorder
  Future<void> _initRecorder() async {
    if (_isRecorderInitialized) return;

    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    _isRecorderInitialized = true;
  }

  /// Start recording audio
  Future<String> startRecording() async {
    try {
      await _initRecorder();

      // Get app directory for storing recording
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/recording_$timestamp.aac';

      // Start recording
      await _recorder!.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );

      // Start amplitude monitoring
      _startAmplitudeMonitoring();

      return path;
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    try {
      await _recorder?.pauseRecorder();
      _stopAmplitudeMonitoring();
    } catch (e) {
      throw Exception('Failed to pause recording: $e');
    }
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    try {
      await _recorder?.resumeRecorder();
      _startAmplitudeMonitoring();
    } catch (e) {
      throw Exception('Failed to resume recording: $e');
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    try {
      _stopAmplitudeMonitoring();
      final path = await _recorder?.stopRecorder();
      return path;
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  /// Get amplitude stream for waveform visualization
  Stream<double> getAmplitudeStream() {
    _amplitudeController ??= StreamController<double>.broadcast();
    return _amplitudeController!.stream;
  }

  /// Start monitoring amplitude
  void _startAmplitudeMonitoring() {
    if (_recorder == null) return;

    _recorder!.setSubscriptionDuration(const Duration(milliseconds: 100));
    _recorder!.onProgress!.listen((event) {
      if (event.decibels != null) {
        // Normalize decibels to 0-1 range
        // Typical range is -60 to 0 dB
        final normalizedDb = (event.decibels! + 60).clamp(0.0, 60.0);
        final level = normalizedDb / 60.0;
        _amplitudeController?.add(level);
      }
    });
  }

  /// Stop monitoring amplitude
  void _stopAmplitudeMonitoring() {
    _recorder?.setSubscriptionDuration(Duration.zero);
  }

  /// Upload recording to server with FormData
  Future<MeetingSummary> uploadRecording({
    required String filePath,
    required String meetingId,
    String? participantEmails,
    required Function(double) onProgress,
  }) async {
    try {
      // Verify file exists
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Recording file not found');
      }

      // Create FormData
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          filePath,
          filename: 'meeting_audio.aac',
        ),
        'meeting_id': meetingId,
        if (participantEmails != null && participantEmails.isNotEmpty)
          'participant_emails': participantEmails,
      });

      // Make the API request using ApiClient
      final response = await ApiClient.dio.post(
        '/api/v1/meeting-recordings',
        data: formData,
        onSendProgress: (sent, total) {
          final progress = sent / total;
          onProgress(progress);
        },
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      // Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return MeetingSummary.fromJson(response.data);
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw Exception('Upload cancelled');
      } else if (e.response != null) {
        throw Exception('Upload failed: ${e.response?.data ?? e.message}');
      } else {
        throw Exception('Upload failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to upload recording: $e');
    }
  }

  /// Delete recording file
  Future<void> deleteRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete recording: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    _stopAmplitudeMonitoring();
    _amplitudeController?.close();

    if (_isRecorderInitialized) {
      await _recorder?.closeRecorder();
      _recorder = null;
      _isRecorderInitialized = false;
    }
  }
}
