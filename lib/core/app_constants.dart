class ApiConstants {
  ApiConstants._(); // Private constructor - can't be instantiated

  static const String baseUrl = 'https://lead-generation-mobile.onrender.com/';

  // ── AUTH ENDPOINTS ─────────────────────
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String verifyOtp = '/api/v1/auth/verify-email';
  static const String resendOtp = '/api/v1/auth/resend-otp';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String me = '/api/v1/auth/me';
  static const String logout = '/api/v1/auth/logout';
  static const String completeProfile = '/api/v1/auth/setup-profile';
  static const String setupBusiness = '/api/v1/auth/setup-business';

  // ── VISITING CARD ENDPOINTS ─────────────────────
  static const String scanVisitingCard = '/api/v1/visiting-cards/scan';
  static const String getVisitingCards = '/api/v1/visiting-cards';
}


