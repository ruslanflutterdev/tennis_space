enum UserRole { tennisCoach, fitnessCoach, child, parent, admin }

class RegistrationData {
  final String email;
  final String password;
  final UserRole role;
  final String lastName;
  final String firstName;
  final String? middleName;
  final DateTime birthDate;
  final String gender;

  RegistrationData({
    required this.email,
    required this.password,
    required this.role,
    required this.lastName,
    required this.firstName,
    this.middleName,
    required this.birthDate,
    required this.gender,
  });
}
