// lib/views/business_setup_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetzone/controllers/business_setup_controller.dart';
import 'package:meetzone/theme.dart';
import 'package:meetzone/widgets/custom_text_field.dart';

class BusinessSetupView extends StatefulWidget {
  const BusinessSetupView({super.key});

  @override
  State<BusinessSetupView> createState() => _BusinessSetupViewState();
}

class _BusinessSetupViewState extends State<BusinessSetupView>
    with TickerProviderStateMixin {
  late final BusinessSetupController controller;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    controller = BusinessSetupController();
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
                        'Setup Business',
                        style: AppTextStyles.headlineXL.copyWith(
                          fontSize: 32,
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
                      const SizedBox(height: 6),
                      Text(
                        'Tell us about your business',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // FORM FIELDS - Scrollable when keyboard appears
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: controller.formKey,
                            child: Column(
                              children: [
                                AuthTextField(
                                  hint: 'Business Name',
                                  controller: controller.nameController,

                                  validator:
                                      (v) =>
                                          v!.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 14),
                                AuthTextField(
                                  hint: 'Industry',
                                  controller: controller.industryController,

                                  validator:
                                      (v) =>
                                          v!.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 14),
                                AuthTextField(
                                  hint: 'Description',
                                  controller: controller.descriptionController,

                                  maxLines: 3,
                                  validator:
                                      (v) =>
                                          v!.trim().isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 14),
                                AuthTextField(
                                  hint: 'Address',
                                  controller: controller.addressController,

                                  maxLines: 2,
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
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  controller.isLoading
                                      ? null
                                      : () => controller.submit(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
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
