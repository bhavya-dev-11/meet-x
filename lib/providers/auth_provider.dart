import 'package:riverpod/legacy.dart';

class AuthState {
  final bool isLoggedIn;
  final String? userEmail;
  final String? error;

  AuthState({this.isLoggedIn = false, this.userEmail, this.error});

  AuthState copyWith({bool? isLoggedIn, String? userEmail, String? error}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userEmail: userEmail ?? this.userEmail,
      error: error,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void logout() => state = AuthState();
  void login(String email) => state = state.copyWith(isLoggedIn: true, userEmail: email);
  void setError(String error) => state = state.copyWith(error: error);
}

