import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/profile_bloc.dart';
import '../widgets/personal_data_section.dart';
import '../widgets/location_club_section.dart';
import '../mixins/profile_edit_mixin.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with ProfileEditMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактирование профиля')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaved) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Профиль обновлен')));
            context.pop();
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
            if (lastNameController.text.isEmpty &&
                firstNameController.text.isEmpty) {
              fillFields(state.profileData, state.clubs);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    PersonalDataSection(
                      lastNameController: lastNameController,
                      firstNameController: firstNameController,
                      middleNameController: middleNameController,
                      selectedDate: selectedDate,
                      selectedGender: selectedGender,
                      genders: genders,
                      onDateTap: pickDate,
                      onGenderChanged: onGenderChanged,
                    ),

                    const SizedBox(height: 30),

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
                      onPressed: () => save(state.profileData['id']),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Сохранить изменения'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('Загрузка данных...'));
        },
      ),
    );
  }
}
