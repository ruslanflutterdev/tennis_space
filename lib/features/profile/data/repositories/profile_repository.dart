abstract class ProfileRepository {
  Future<List<Map<String, dynamic>>> getClubs();
  Future<Map<String, dynamic>> getUserProfile(String userId);
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
  });
}
