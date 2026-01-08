import 'package:meetzone/services/api_service.dart';
import 'package:riverpod/riverpod.dart';

class AuthRepository {
  Future<void> register({required String email, required String password}) async {
    await AuthService.register(email: email, password: password);
  }
}

final authRepositoryProvider = Provider((ref) => AuthRepository());

