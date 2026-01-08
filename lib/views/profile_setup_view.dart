// lib/views/profile_setup_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetzone/controllers/profile_setup_controller.dart';
import 'package:meetzone/theme.dart';
import 'package:meetzone/widgets/custom_text_field.dart';

class ProfileSetupView extends StatefulWidget {
  const ProfileSetupView({super.key});

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView>
    with TickerProviderStateMixin {
  late final ProfileSetupController controller;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    controller = ProfileSetupController();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
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
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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

              // MAIN CONTENT
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
                  child: Column(
                    children: [
                      // Fixed Header
                      Text(
                        'Complete Profile',
                        style: AppTextStyles.headlineXL.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          foreground:
                              Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                  ],
                                ).createShader(
                                  const Rect.fromLTWH(0, 0, 300, 70),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tell us a bit about yourself',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textMutedLight.withValues(alpha: 0.9),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // FORM FIELDS - Scrollable when keyboard appears
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: controller.formKey,
                            child: Column(
                              children: [
                                AuthTextField(
                                  hint: 'Full Name',
                                  controller: controller.fullNameController,
                                  isLightBackground: true,
                                  validator:
                                      (v) =>
                                          v!.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 14),
                                AuthTextField(
                                  hint: 'Designation',
                                  controller: controller.designationController,
                                  isLightBackground: true,
                                  validator:
                                      (v) =>
                                          v!.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 14),
                                AuthTextField(
                                  hint: 'Phone Number',
                                  controller: controller.phoneController,
                                  isLightBackground: true,
                                  keyboardType: TextInputType.phone,
                                  validator:
                                      (v) =>
                                          v!.trim().isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // FIXED BOTTOM SECTION (button)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  controller.isLoading
                                      ? null
                                      : () => controller.submit(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: LinearGradient(
                                    colors:
                                        controller.isLoading
                                            ? [
                                              AppColors.primary.withValues(alpha: 
                                                0.6,
                                              ),
                                              AppColors.primaryDark.withValues(alpha: 
                                                0.6,
                                              ),
                                            ]
                                            : [
                                              AppColors.primary,
                                              AppColors.primaryDark,
                                            ],
                                  ),
                                  boxShadow:
                                      controller.isLoading
                                          ? []
                                          : [AppShadows.glow],
                                ),
                                child: Center(
                                  child:
                                      controller.isLoading
                                          ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                          : Text(
                                            'Complete Setup',
                                            style: AppTextStyles.button
                                                .copyWith(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                          ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                top: -80,
                left: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 
                          0.18 + 0.05 * _glowController.value,
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
                        AppColors.accent.withValues(alpha: 
                          0.14 + 0.04 * _glowController.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 180,
                right: 40,
                child: Transform.rotate(
                  angle: 0.8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}


