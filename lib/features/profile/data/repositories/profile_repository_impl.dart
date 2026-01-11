import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient supabase;

  ProfileRepositoryImpl(this.supabase);

  @override
  Future<List<Map<String, dynamic>>> getClubs() async {
    final List<dynamic> data = await supabase
        .from('clubs')
        .select('id, name')
        .order('name', ascending: true);
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return await supabase.from('profiles').select().eq('id', userId).single();
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required String lastName,
    required String firstName,
    String? middleName,
    required DateTime birthDate,
    required String gender,
    required String country,
    required String city,
    int? clubId,
    String? clubName,
  }) async {
    final updates = {
      'last_name': lastName,
      'first_name': firstName,
      'middle_name': middleName,
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
      'country': country,
      'city': city,
      'club_id': clubId,
      'club_name': clubName,
    };
    await supabase.from('profiles').update(updates).eq('id', userId);
  }
}
