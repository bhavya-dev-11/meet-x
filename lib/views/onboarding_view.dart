// lib/views/onboarding_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetzone/controllers/onboarding_controller.dart';
import 'package:meetzone/theme.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  late OnboardingController _controller;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController();

    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 1400), vsync: this);
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 1600), vsync: this);

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext) {
    // Dark status bar icons on light pastel background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,   // Android
      statusBarBrightness: Brightness.light,      // iOS
    ));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.onboardBgStart,   // #F5F3FF
             
              AppColors.onboardBgMiddle,  // #E0F2FE
              AppColors.onboardBgEnd,     // #ECFDF5
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 20),
                    _buildIllustration(constraints, screenWidth, screenHeight),
                    const SizedBox(height: 16),
                    _buildHeadline(screenWidth),
                    const SizedBox(height: 12),
                    _buildSubtext(screenWidth),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(BoxConstraints c, double screenWidth, double screenHeight) {
    // Much smaller responsive sizing - 25% of screen height max
    final illustrationHeight = (screenHeight * 0.25).clamp(160.0, 220.0);
    final blobSize1 = (illustrationHeight * 0.35).clamp(50.0, 80.0);
    final blobSize2 = (illustrationHeight * 0.27).clamp(40.0, 60.0);
    final orbSize = (illustrationHeight * 0.65).clamp(100.0, 140.0);
    final badgeSize = (illustrationHeight * 0.16).clamp(30.0, 40.0);
    
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _slideController,
          curve: Curves.easeOutCubic,
        )),
        child: SizedBox(
          height: illustrationHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft purple blob
              Positioned(
                top: illustrationHeight * 0.14,
                left: 20,
                child: Container(
                  width: blobSize1,
                  height: blobSize1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primaryDark.withValues(alpha: 0.08),
                    ]),
                    borderRadius: BorderRadius.circular(blobSize1 / 2),
                  ),
                ),
              ),
              // Soft teal blob
              Positioned(
                top: illustrationHeight * 0.07,
                right: 30,
                child: Container(
                  width: blobSize2,
                  height: blobSize2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.accent.withValues(alpha: 0.18),
                      AppColors.accent.withValues(alpha: 0.08),
                    ]),
                    borderRadius: BorderRadius.circular(blobSize2 / 2),
                  ),
                ),
              ),

              // Central orb
              Center(
                child: Container(
                  width: orbSize,
                  height: orbSize,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFBEB), Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(orbSize / 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sound waves
                      Container(
                        width: orbSize * 0.7,
                        height: orbSize * 0.7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.22),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: orbSize * 0.5,
                        height: orbSize * 0.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.28),
                            width: 2,
                          ),
                        ),
                      ),

                      // Mic icon
                      Container(
                        width: orbSize * 0.3,
                        height: orbSize * 0.3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(orbSize * 0.15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(Icons.mic_rounded, color: Colors.white, size: orbSize * 0.16),
                      ),
                    ],
                  ),
                ),
              ),

              // Floating badges
              Positioned(
                bottom: illustrationHeight * 0.21,
                left: 40,
                child: _floatingBadge(Icons.lightbulb_rounded, AppColors.accent, badgeSize),
              ),
              Positioned(
                bottom: illustrationHeight * 0.18,
                right: 50,
                child: _floatingBadge(Icons.auto_awesome_rounded, AppColors.primary, badgeSize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floatingBadge(IconData icon, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.92), color.withValues(alpha: 0.98)],
        ),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.52),
    );
  }

  Widget _buildHeadline(double screenWidth) {
    final headlineFontSize = (screenWidth * 0.085).clamp(24.0, 36.0);
    
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        ),
        child: Text(
          'Understand your\nmeetings like\nnever before',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineXL.copyWith(
            color: AppColors.textOnLight,
            fontSize: headlineFontSize,
            height: 1.15,
            letterSpacing: -0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtext(double screenWidth) {
    final subtextFontSize = (screenWidth * 0.038).clamp(13.0, 16.0);
    
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'Record your conversations, upload when you\'re ready, and let AI extract key insights to help you make smarter decisions.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontSize: subtextFontSize,
              height: 1.55,
              color: AppColors.textMutedLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _controller.isLoading ? null : () => _controller.handleSignIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(29),
                    gradient: LinearGradient(
                      colors: _controller.isLoading
                          ? [AppColors.primary.withValues(alpha: 0.7), AppColors.primaryDark.withValues(alpha: 0.7)]
                          : [AppColors.primary, AppColors.primaryDark],
                    ),
                    boxShadow: _controller.isLoading
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.28),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                  ),
                  child: Center(
                    child: _controller.isLoading
                        ? const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.8,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            TextButton(
              onPressed: () => _controller.handleCreateAccount(context),
              child: Text(
                'I already have an account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMutedLight,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textMutedLight.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

