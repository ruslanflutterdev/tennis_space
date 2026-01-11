import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfileData>((event, emit) async {
      emit(ProfileLoading());
      try {
        final results = await Future.wait([
          repository.getUserProfile(event.userId),
          repository.getClubs(),
        ]);

        emit(
          ProfileLoaded(
            profileData: results[0] as Map<String, dynamic>,
            clubs: results[1] as List<Map<String, dynamic>>,
          ),
        );
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<UpdateProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      try {
        await repository.updateProfile(
          userId: event.userId,
          lastName: event.lastName,
          firstName: event.firstName,
          middleName: event.middleName,
          birthDate: event.birthDate,
          gender: event.gender,
          country: event.country,
          city: event.city,
          clubId: event.clubId,
          clubName: event.clubName,
        );
        emit(ProfileSaved());
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
