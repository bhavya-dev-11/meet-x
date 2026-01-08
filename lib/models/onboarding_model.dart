class OnboardingModel {
  final String headline;
  final String miniCardTitle;
  final String miniCardDuration;
  final String primaryButtonText;
  final String secondaryLinkText;

  OnboardingModel({
    required this.headline,
    required this.miniCardTitle,
    required this.miniCardDuration,
    required this.primaryButtonText,
    required this.secondaryLinkText,
  });

  factory OnboardingModel.defaultData() {
    return OnboardingModel(
      headline: 'Turn offline meetings\ninto insights',
      miniCardTitle: 'AI Summary',
      miniCardDuration: '20 min',
      primaryButtonText: 'Sign in',
      secondaryLinkText: 'Create new account',
    );
  }
}

