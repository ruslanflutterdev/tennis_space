import 'package:supabase_flutter/supabase_flutter.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../models/user_model.dart';


class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient supabase;

  AuthRepositoryImpl(this.supabase);

  @override
  Future<void> signUp(RegistrationData data) async {
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: data.email,
        password: data.password,
      );

      if (res.user == null) throw Exception('Ошибка создания пользователя');
      final roleString = _mapRoleToString(data.role);

      await supabase.from('profiles').insert({
        'id': res.user!.id,
        'role': roleString,
        'last_name': data.lastName,
        'first_name': data.firstName,
        'middle_name': data.middleName,
        'birth_date': data.birthDate.toIso8601String(),
        'gender': data.gender,
      });
    } catch (e) {
      throw Exception('Ошибка регистрации: ${e.toString()}');
    }
  }

  @override
  Future<UserRole> signIn(String email, String password) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) throw Exception('Ошибка входа');

      final data = await supabase
          .from('profiles')
          .select('role')
          .eq('id', res.user!.id)
          .single();

      return _mapStringToRole(data['role'] as String);
    } catch (e) {
      throw Exception('Неверный логин или пароль');
    }
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Не удалось отправить письмо: ${e.toString()}');
    }
  }

  @override
  UserRole? getCurrentUserRole() {
    return null;
  }

  String _mapRoleToString(UserRole role) {
    switch (role) {
      case UserRole.tennisCoach: return 'tennis_coach';
      case UserRole.fitnessCoach: return 'fitness_coach';
      case UserRole.child: return 'child';
      case UserRole.parent: return 'parent';
      case UserRole.admin: return 'admin';
    }
  }

  UserRole _mapStringToRole(String role) {
    switch (role) {
      case 'tennis_coach': return UserRole.tennisCoach;
      case 'fitness_coach': return UserRole.fitnessCoach;
      case 'child': return UserRole.child;
      case 'parent': return UserRole.parent;
      case 'admin': return UserRole.admin;
      default: return UserRole.child;
    }
  }
}