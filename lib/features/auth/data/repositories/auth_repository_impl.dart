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
      throw Exception(e.toString());
    }
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
}