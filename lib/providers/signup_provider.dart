import 'package:meetzone/data/repositories/auth_repository.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

final signupProvider = StateNotifierProvider<SignupNotifier, AsyncValue<void>>((ref) {
  return SignupNotifier(ref);
});

class SignupNotifier extends StateNotifier<AsyncValue<void>> {
  SignupNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> signup({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      state = AsyncValue.error('Passwords do not match', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).register(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

