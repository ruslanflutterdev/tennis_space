part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profileData;
  final List<Map<String, dynamic>> clubs;

  ProfileLoaded({required this.profileData, required this.clubs});

  @override
  List<Object?> get props => [profileData, clubs];
}

class ProfileSaved extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
