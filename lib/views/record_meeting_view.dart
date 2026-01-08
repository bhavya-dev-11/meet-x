// lib/views/record_meeting_view.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/models/recording_state.dart';
import 'package:meetzone/providers/recording_provider.dart';
import 'package:meetzone/theme.dart';

class RecordMeetingView extends ConsumerStatefulWidget {
  final String meetingWith;

  const RecordMeetingView({Key? key, required this.meetingWith})
    : super(key: key);

  @override
  ConsumerState<RecordMeetingView> createState() => _RecordMeetingViewState();
}

class _RecordMeetingViewState extends ConsumerState<RecordMeetingView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Initialize recording
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recordingProvider.notifier).initialize(widget.meetingWith);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    ref.read(recordingProvider.notifier).disposeRecording();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        if (recordingState.status == RecordingStatus.recording ||
            recordingState.status == RecordingStatus.paused) {
          _showStopConfirmation();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(recordingState),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.onboardBgStart,
                AppColors.onboardBgMiddle,
                AppColors.onboardBgEnd,
              ],
            ),
          ),
          child: Stack(
            children: [
              _buildFloatingShapes(),
              SafeArea(child: _buildContent(recordingState)),

              // Upload overlay
              if (recordingState.status == RecordingStatus.uploading ||
                  recordingState.status == RecordingStatus.processing)
                _buildUploadOverlay(recordingState),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(RecordingState state) {
    final isRecording = state.status == RecordingStatus.recording;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textOnLight),
        onPressed: () {
          if (state.status == RecordingStatus.recording ||
              state.status == RecordingStatus.paused) {
            _showStopConfirmation();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRecording) ...[
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(
                      alpha: 0.5 + 0.5 * _pulseController.value,
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              'Meeting: ${state.meetingWith ?? widget.meetingWith}',
              style: AppTextStyles.title.copyWith(
                color: AppColors.textOnLight,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildFloatingShapes() {
    return AnimatedBuilder(
      animation: _glowController,
      builder:
          (_, __) => Stack(
            children: [
              Positioned(
                top: -80,
                left: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(
                          alpha: 0.18 + 0.05 * _glowController.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                right: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(
                          alpha: 0.14 + 0.04 * _glowController.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildContent(RecordingState state) {
    switch (state.status) {
      case RecordingStatus.permissionDenied:
        return _buildPermissionDenied(state);
      case RecordingStatus.ready:
        return _buildReadyState(state);
      case RecordingStatus.recording:
      case RecordingStatus.paused:
        return _buildRecordingState(state);
      case RecordingStatus.stopped:
        return _buildStoppedState(state);
      case RecordingStatus.completed:
        return _buildCompletedState();
      case RecordingStatus.error:
        return _buildErrorState(state);
      default:
        return _buildLoadingState();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Preparing...',
            style: AppTextStyles.title.copyWith(
              color: AppColors.textOnLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied(RecordingState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic_off,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Microphone Access Needed',
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.textOnLight,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ??
                  'We need microphone access to record meetings',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMutedLight,
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(recordingProvider.notifier)
                      .initialize(widget.meetingWith);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Grant Permission',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyState(RecordingState state) {
    return Column(
      children: [
        const SizedBox(height: 40),

        // Title
        Text(
          'Start Meeting Recording',
          style: AppTextStyles.headlineXL.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textOnLight,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Timer and Status
        _buildTimerAndStatus(state, 'Ready to record'),

        const Spacer(),

        // Record Button
        _buildRecordButton(),

        const SizedBox(height: 40),

        // Quick actions
        _buildQuickActions(false),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildRecordingState(RecordingState state) {
    final isRecording = state.status == RecordingStatus.recording;

    return Column(
      children: [
        const SizedBox(height: 40),

        // Waveform
        if (isRecording) _buildWaveform(state),

        const SizedBox(height: 20),

        // Timer and Status
        _buildTimerAndStatus(state, isRecording ? 'Recording...' : 'Paused'),

        const Spacer(),

        // Control Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pause/Resume Button
            _buildControlButton(
              icon: isRecording ? Icons.pause : Icons.play_arrow,
              label: isRecording ? 'Pause' : 'Resume',
              onTap: () {
                if (isRecording) {
                  ref.read(recordingProvider.notifier).pauseRecording();
                } else {
                  ref.read(recordingProvider.notifier).resumeRecording();
                }
              },
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),

            const SizedBox(width: 20),

            // Stop Button
            _buildControlButton(
              icon: Icons.stop,
              label: 'Stop',
              onTap: _showStopConfirmation,
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Quick actions
        _buildQuickActions(true),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStoppedState(RecordingState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle,
                size: 56,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Recording Completed',
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.textOnLight,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Duration: ${state.formattedDuration}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMutedLight,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(recordingProvider.notifier).uploadRecording();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Upload & Process',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.cloud_done,
                size: 56,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Processing Complete!',
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.textOnLight,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your meeting summary is ready',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMutedLight,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to summary view
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'View Summary',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(RecordingState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline,
                size: 56,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Oops! Something Went Wrong',
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.textOnLight,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'An unexpected error occurred',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMutedLight,
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Go Back',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerAndStatus(RecordingState state, String status) {
    return Column(
      children: [
        Text(
          state.formattedDuration,
          style: AppTextStyles.headlineXL.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            foreground:
                Paint()
                  ..shader = const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaveform(RecordingState state) {
    // Ensure we have audio levels to display
    if (state.audioLevels.isEmpty) {
      return const SizedBox(height: 60);
    }

    // Calculate how many bars to show (max 30)
    final barCount = math.min(state.audioLevels.length, 30);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barCount, (index) {
          // Calculate the actual index in the audioLevels list
          // We want to show the last 30 items, so we start from (length - barCount)
          final audioLevelIndex = state.audioLevels.length - barCount + index;

          // Safety check to ensure index is valid
          final level =
              (audioLevelIndex >= 0 &&
                      audioLevelIndex < state.audioLevels.length)
                  ? state.audioLevels[audioLevelIndex]
                  : 0.0;

          final height = 10 + (level * 40);

          return Container(
            width: 3,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: () {
        ref.read(recordingProvider.notifier).startRecording();
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.3 + 0.2 * _pulseController.value,
                  ),
                  blurRadius: 30 + 20 * _pulseController.value,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 48),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textOnLight,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isRecording) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickAction(
          icon: Icons.note_add_outlined,
          label: 'Notes',
          onTap: () {
            // TODO: Add notes functionality
          },
        ),
        _buildQuickAction(
          icon: Icons.people_outline,
          label: 'Participants',
          onTap: () {
            // TODO: Add participants functionality
          },
        ),
        if (!isRecording)
          _buildQuickAction(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {
              // TODO: Add settings functionality
            },
          ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMutedLight,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOverlay(RecordingState state) {
    final isUploading = state.status == RecordingStatus.uploading;

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [AppShadows.lg],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUploading)
                const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                )
              else
                const Icon(
                  Icons.cloud_sync,
                  size: 56,
                  color: AppColors.primary,
                ),

              const SizedBox(height: 24),

              Text(
                isUploading
                    ? 'Uploading recording...'
                    : 'Processing summary...',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.textOnLight,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              if (isUploading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: state.uploadProgress,
                  backgroundColor: AppColors.softGray,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(state.uploadProgress * 100).toInt()}%',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMutedLight,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    ref.read(recordingProvider.notifier).cancelUpload();
                  },
                  child: Text(
                    'Cancel Upload',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showStopConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Stop Recording?',
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.textOnLight,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Text(
              'Are you sure you want to stop this recording?',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMutedLight,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textMutedLight,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(recordingProvider.notifier).stopRecording();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Stop',
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
