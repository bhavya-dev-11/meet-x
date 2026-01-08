// lib/providers/recording_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/controllers/recording_controller.dart';
import 'package:meetzone/models/recording_state.dart';

final recordingProvider = NotifierProvider<RecordingNotifier, RecordingState>(
  () {
    return RecordingNotifier();
  },
);


