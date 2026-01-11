import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodel/profile_bloc.dart';
import '../widgets/location_club_section.dart';
import '../mixins/profile_completion_mixin.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen>
    with ProfileCompletionMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заполнение профиля')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaved) {
            navigateBasedOnRole();
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Расскажите немного о себе, чтобы мы могли найти вашу группу.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      LocationClubSection(
                        countryController: countryController,
                        cityController: cityController,
                        clubNameController: clubNameController,
                        countries: countries,
                        cities: cities,
                        clubs: state.clubs,
                        isManualClub: isManualClub,
                        selectedClubId: selectedClubId,
                        onToggleManual: onToggleManual,
                        onClubSelected: onClubSelected,
                      ),

                      const SizedBox(height: 40),

                      ElevatedButton(
                        onPressed: () =>
                            saveProfile(state.profileData, state.clubs),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Сохранить и продолжить'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(
            child: Text('Не удалось загрузить данные профиля'),
          );
        },
      ),
    );
  }
}
