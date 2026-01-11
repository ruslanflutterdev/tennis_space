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
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Произошла ошибка: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) throw Exception('Ошибка входа');

      final data = await supabase
          .from('profiles')
          .select('role, club_id')
          .eq('id', res.user!.id)
          .single();

      final role = _mapStringToRole(data['role'] as String);
      final clubId = data['club_id'];
      // Возвращаем Map, чтобы передать оба значения
      return {'role': role, 'clubId': clubId};
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
      case UserRole.tennisCoach:
        return 'tennisCoach';
      case UserRole.fitnessCoach:
        return 'fitnessCoach';
      case UserRole.child:
        return 'child';
      case UserRole.parent:
        return 'parent';
      case UserRole.admin:
        return 'admin';
    }
  }

  UserRole _mapStringToRole(String role) {
    switch (role) {
      case 'tennisCoach':
        return UserRole.tennisCoach;
      case 'fitnessCoach':
        return UserRole.fitnessCoach;
      case 'child':
        return UserRole.child;
      case 'parent':
        return UserRole.parent;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.child;
    }
  }

  // Метод для получения списка клубов
  @override
  Future<List<Map<String, dynamic>>> getClubs() async {
    try {
      final List<dynamic> data = await supabase
          .from('clubs')
          .select('id, name')
          .order('name', ascending: true);

      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Не удалось загрузить клубы: $e');
    }
  }

  @override
  Future<void> completeProfile({
    required String userId,
    required String country,
    required String city,
    int? clubId,
    String? clubName,
  }) async {
    try {
      final updates = {
        'country': country,
        'city': city,
        'club_name': clubName,
        'club_id': clubId,
      };

      await supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Ошибка сохранения профиля: $e');
    }
  }
}
