import '../models/user_model.dart';

abstract class AuthRepository {
  Future<void> signUp(RegistrationData data);
  Future<Map<String, dynamic>> signIn(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
}
