// lib/views/otp_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetzone/controllers/otp_controller.dart';
import 'package:meetzone/theme.dart';
import 'package:meetzone/widgets/custom_text_field.dart';

class OtpView extends StatefulWidget {
  final String email;

  const OtpView({Key? key, required this.email}) : super(key: key);

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> with TickerProviderStateMixin {
  late final OtpController controller;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    controller = OtpController(email: widget.email);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.background, AppColors.backgroundLight],
            ),
          ),
          child: Stack(
            children: [
              _buildFloatingShapes(),

              // MAIN CONTENT
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
                  child: Column(
                    children: [
                      // Fixed Header
                      Text(
                        'Verify OTP',
                        style: AppTextStyles.headlineXL.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          foreground:
                              Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    AppColors.textPrimary,
                                    AppColors.primary,
                                  ],
                                ).createShader(
                                  const Rect.fromLTWH(0, 0, 300, 70),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter the 6-digit code sent to',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // SCROLLABLE FORM AREA
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.of(context).size.height -
                                  200 -
                                  MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: IntrinsicHeight(
                              child: Form(
                                key: controller.formKey,
                                child: Column(
                                  children: [
                                    AuthTextField(
                                      hint: 'Enter OTP',
                                      controller: controller.otpController,

                                      validator:
                                          (v) =>
                                              v!.trim().length != 6
                                                  ? 'OTP must be 6 digits'
                                                  : null,
                                    ),

                                    const SizedBox(height: 24),

                                    // Resend OTP button
                                    TextButton(
                                      onPressed:
                                          controller.isResending
                                              ? null
                                              : () =>
                                                  controller.resendOtp(context),
                                      child:
                                          controller.isResending
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: AppColors.primary,
                                                    ),
                                              )
                                              : Text(
                                                'Resend OTP',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      AppColors.primary,
                                                ),
                                              ),
                                    ),

                                    const SizedBox(height: 40),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // FIXED BOTTOM SECTION
                      SizedBox(
                        width: double.infinity,
                        height: 62,
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoading
                                  ? null
                                  : () => controller.verifyOtp(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(31),
                            ),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(31),
                              gradient: LinearGradient(
                                colors:
                                    controller.isLoading
                                        ? [
                                          AppColors.primary.withValues(
                                            alpha: 0.6,
                                          ),
                                          AppColors.primaryDark.withValues(
                                            alpha: 0.6,
                                          ),
                                        ]
                                        : [
                                          AppColors.primary,
                                          AppColors.primaryDark,
                                        ],
                              ),
                              boxShadow:
                                  controller.isLoading ? [] : [AppShadows.glow],
                            ),
                            child: Center(
                              child:
                                  controller.isLoading
                                      ? const SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                      : Text(
                                        'Verify OTP',
                                        style: AppTextStyles.button.copyWith(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(
                          alpha: 0.1 + 0.03 * _glowController.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                right: -80,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(
                          alpha: 0.06 + 0.02 * _glowController.value,
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
}
