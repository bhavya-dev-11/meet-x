// lib/views/scan_card_view.dart
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/models/camera_state.dart';
import 'package:meetzone/models/visiting_card_state.dart';
import 'package:meetzone/providers/camera_provider.dart';
import 'package:meetzone/providers/visiting_card_provider.dart';
import 'package:meetzone/theme.dart';

class ScanCardView extends ConsumerStatefulWidget {
  const ScanCardView({super.key});

  @override
  ConsumerState<ScanCardView> createState() => _ScanCardViewState();
}

class _ScanCardViewState extends ConsumerState<ScanCardView>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  CameraController? _cameraControllerToDispose;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Initialize camera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();

    // Dispose camera controller if it exists
    _cameraControllerToDispose?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);

    // Show camera preview with minimal overlay
    if (cameraState.status == CameraStatus.cameraReady ||
        cameraState.status == CameraStatus.capturing) {
      return _buildCameraPreview(cameraState);
    }

    // Captured view has its own scaffold
    if (cameraState.status == CameraStatus.captured) {
      return _buildCapturedView(cameraState);
    }

    // All other states use the gradient background
    return _buildGradientBackground(cameraState);
  }

  Widget _buildGradientBackground(CameraState cameraState) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textOnLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
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
            SafeArea(child: _buildContent(cameraState)),
          ],
        ),
      ),
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
              Positioned(
                top: 200,
                right: 30,
                child: Transform.rotate(
                  angle: 0.8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildContent(CameraState cameraState) {
    switch (cameraState.status) {
      case CameraStatus.initial:
      case CameraStatus.permissionGranted:
        return _buildLoadingView();

      case CameraStatus.permissionDenied:
        return _buildPermissionDeniedView();

      case CameraStatus.error:
        return _buildErrorView(cameraState);

      default:
        return _buildLoadingView();
    }
  }

  Widget _buildLoadingView() {
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
            'Preparing Camera...',
            style: AppTextStyles.title.copyWith(
              color: AppColors.textOnLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Just a moment',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMutedLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Padding(
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
            child: Icon(
              Icons.camera_alt_rounded,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Camera Access Needed',
            style: AppTextStyles.headlineMd.copyWith(
              color: AppColors.textOnLight,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'To scan business cards, we need permission to access your camera',
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
                ref.read(cameraProvider.notifier).initialize();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
              ),
              child: Container(
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
                child: Center(
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
    );
  }

  Widget _buildCameraPreview(CameraState cameraState) {
    if (cameraState.controller == null ||
        !cameraState.controller!.value.isInitialized) {
      return _buildGradientBackground(cameraState);
    }

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          CameraPreview(cameraState.controller!),

          // Subtle overlay with guide
          _buildCameraOverlay(),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(cameraState),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCameraControls(cameraState),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(CameraState cameraState) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Title
          Text(
            'Scan Business Card',
            style: AppTextStyles.title.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),

          // Flash button
          GestureDetector(
            onTap: () {
              ref.read(cameraProvider.notifier).toggleFlash();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    cameraState.isFlashOn
                        ? AppColors.primary.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                cameraState.isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraOverlay() {
    return CustomPaint(
      painter: CardFramePainter(pulseAnimation: _pulseController),
      child: Container(),
    );
  }

  Widget _buildCameraControls(CameraState cameraState) {
    final isCapturing = cameraState.status == CameraStatus.capturing;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Align card within the frame',
              style: AppTextStyles.body.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Camera Controls Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gallery Button
                GestureDetector(
                  onTap:
                      isCapturing
                          ? null
                          : () {
                            ref.read(cameraProvider.notifier).pickFromGallery();
                          },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                const SizedBox(width: 40),

                // Capture Button
                GestureDetector(
                  onTap:
                      isCapturing
                          ? null
                          : () {
                            ref.read(cameraProvider.notifier).captureImage();
                          },
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(
                                alpha: 0.3 + 0.2 * _pulseController.value,
                              ),
                              blurRadius: 20 + 10 * _pulseController.value,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                            ),
                          ),
                          child:
                              isCapturing
                                  ? const Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  )
                                  : const Icon(
                                    Icons.camera,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 40),

                // Placeholder for symmetry
                const SizedBox(width: 56, height: 56),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturedView(CameraState cameraState) {
    if (cameraState.capturedImagePath == null) {
      return _buildErrorView(cameraState);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textOnLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Preview',
          style: AppTextStyles.title.copyWith(
            color: AppColors.textOnLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
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
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Image Preview
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(cameraState.capturedImagePath!),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Retake Button
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ref.read(cameraProvider.notifier).retake();
                              },
                              icon: const Icon(
                                Icons.refresh,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                'Retake',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Use Photo Button
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () async {
                                final imagePath = cameraState.capturedImagePath;
                                if (imagePath == null) return;

                                // Call the API to scan the card
                                await ref
                                    .read(visitingCardProvider.notifier)
                                    .scanCard(imagePath);

                                // Check if widget is still mounted before accessing ref
                                if (!mounted) return;

                                // Get the result
                                final visitingCardState = ref.read(
                                  visitingCardProvider,
                                );

                                if (!context.mounted) return;

                                if (visitingCardState.status ==
                                    VisitingCardStatus.completed) {
                                  // Success - navigate back with the result
                                  Navigator.pop(
                                    context,
                                    visitingCardState.visitingCard,
                                  );
                                } else if (visitingCardState.status ==
                                    VisitingCardStatus.error) {
                                  // Show error
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        visitingCardState.errorMessage ??
                                            'Failed to scan card',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final visitingCardState = ref.watch(
                                    visitingCardProvider,
                                  );
                                  final isLoading =
                                      visitingCardState.status ==
                                          VisitingCardStatus.uploading ||
                                      visitingCardState.status ==
                                          VisitingCardStatus.processing;

                                  return Ink(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(27),
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryDark,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child:
                                          isLoading
                                              ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    visitingCardState.status ==
                                                            VisitingCardStatus
                                                                .uploading
                                                        ? 'Uploading ${(visitingCardState.uploadProgress * 100).toInt()}%'
                                                        : 'Processing...',
                                                    style: AppTextStyles.button
                                                        .copyWith(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                        ),
                                                  ),
                                                ],
                                              )
                                              : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Use Photo',
                                                    style: AppTextStyles.button
                                                        .copyWith(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(CameraState cameraState) {
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
              child: Icon(
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
              cameraState.errorMessage ?? 'An unexpected error occurred',
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
                  ref.read(cameraProvider.notifier).initialize();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: Container(
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
                  child: Center(
                    child: Text(
                      'Try Again',
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
}

// Custom painter for card frame with subtle corners
class CardFramePainter extends CustomPainter {
  final Animation<double> pulseAnimation;

  CardFramePainter({required this.pulseAnimation})
    : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    // Semi-transparent overlay
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.4);

    // Calculate card frame (credit card aspect ratio)
    final frameWidth = size.width * 0.88;
    final frameHeight = frameWidth / 1.586;
    final frameLeft = (size.width - frameWidth) / 2;
    final frameTop = (size.height - frameHeight) / 2;
    final frameRect = Rect.fromLTWH(
      frameLeft,
      frameTop,
      frameWidth,
      frameHeight,
    );

    // Draw overlay with cutout
    final path =
        Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
          ..addRRect(
            RRect.fromRectAndRadius(frameRect, const Radius.circular(16)),
          )
          ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);

    // Draw corner accents
    final cornerPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

    final cornerLength = 32.0;
    final cornerRadius = 16.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(frameLeft + cornerRadius, frameTop)
        ..lineTo(frameLeft + cornerLength, frameTop)
        ..moveTo(frameLeft, frameTop + cornerRadius)
        ..lineTo(frameLeft, frameTop + cornerLength),
      cornerPaint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(frameLeft + frameWidth - cornerLength, frameTop)
        ..lineTo(frameLeft + frameWidth - cornerRadius, frameTop)
        ..moveTo(frameLeft + frameWidth, frameTop + cornerRadius)
        ..lineTo(frameLeft + frameWidth, frameTop + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(frameLeft, frameTop + frameHeight - cornerLength)
        ..lineTo(frameLeft, frameTop + frameHeight - cornerRadius)
        ..moveTo(frameLeft + cornerRadius, frameTop + frameHeight)
        ..lineTo(frameLeft + cornerLength, frameTop + frameHeight),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(frameLeft + frameWidth, frameTop + frameHeight - cornerLength)
        ..lineTo(frameLeft + frameWidth, frameTop + frameHeight - cornerRadius)
        ..moveTo(frameLeft + frameWidth - cornerLength, frameTop + frameHeight)
        ..lineTo(frameLeft + frameWidth - cornerRadius, frameTop + frameHeight),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CardFramePainter oldDelegate) => true;
}


