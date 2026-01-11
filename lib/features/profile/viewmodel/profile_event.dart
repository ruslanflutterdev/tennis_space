part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfileData extends ProfileEvent {
  final String userId;
  LoadProfileData(this.userId);
}

class UpdateProfileRequested extends ProfileEvent {
  final String userId;
  final String lastName;
  final String firstName;
  final String? middleName;
  final DateTime birthDate;
  final String gender;
  final String country;
  final String city;
  final int? clubId;
  final String? clubName;

  UpdateProfileRequested({
    required this.userId,
    required this.lastName,
    required this.firstName,
    this.middleName,
    required this.birthDate,
    required this.gender,
    required this.country,
    required this.city,
    this.clubId,
    this.clubName,
  });
}
