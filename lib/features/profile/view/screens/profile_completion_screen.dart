import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../viewmodel/profile_bloc.dart';
import '../widgets/custom_autocomplete_field.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _clubNameController = TextEditingController();

  final List<String> _countries = [
    'Казахстан',
    'Россия',
    'Беларусь',
    'Узбекистан',
    'Кыргызстан',
  ];
  final List<String> _cities = [
    'Алматы',
    'Астана',
    'Шымкент',
    'Москва',
    'Санкт-Петербург',
    'Ташкент',
    'Бишкек',
  ];
  int? _selectedClubId;
  bool _isManualClub = false;

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    _clubNameController.dispose();
    super.dispose();
  }

  void _saveProfile(
    Map<String, dynamic> profileData,
    List<Map<String, dynamic>> clubs,
  ) {
    if (_formKey.currentState!.validate()) {
      if (!_isManualClub && _selectedClubId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Выберите клуб')));
        return;
      }
      if (_isManualClub && _clubNameController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Введите название клуба')));
        return;
      }
      final userId = Supabase.instance.client.auth.currentUser!.id;
      String? finalClubName;
      if (_isManualClub) {
        finalClubName = _clubNameController.text;
      } else {
        final selectedClub = clubs.firstWhere(
          (c) => c['id'] == _selectedClubId,
        );
        finalClubName = selectedClub['name'];
      }

      context.read<ProfileBloc>().add(
        UpdateProfileRequested(
          userId: userId,
          lastName: profileData['last_name'] ?? '',
          firstName: profileData['first_name'] ?? '',
          middleName: profileData['middle_name'],
          birthDate: DateTime.parse(profileData['birth_date']),
          gender: profileData['gender'] ?? 'M',
          country: _countryController.text,
          city: _cityController.text,
          clubId: _isManualClub ? null : _selectedClubId,
          clubName: finalClubName,
        ),
      );
    }
  }

  void _navigateBasedOnRole() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.role != null) {
      switch (authState.role!) {
        case UserRole.tennisCoach:
          context.go('/coach');
          break;
        case UserRole.fitnessCoach:
          context.go('/fitness');
          break;
        case UserRole.child:
          context.go('/child');
          break;
        case UserRole.parent:
          context.go('/parent');
          break;
        case UserRole.admin:
          context.go('/admin');
          break;
      }
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заполнение профиля')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaved) {
            _navigateBasedOnRole();
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
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Расскажите немного о себе, чтобы мы могли найти вашу группу.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      CustomAutocompleteField(
                        label: 'Страна',
                        options: _countries,
                        controller: _countryController,
                      ),
                      const SizedBox(height: 10),
                      CustomAutocompleteField(
                        label: 'Город',
                        options: _cities,
                        controller: _cityController,
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              _isManualClub
                                  ? 'Введите название клуба'
                                  : 'Выберите клуб из списка',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isManualClub = !_isManualClub;
                                _selectedClubId = null;
                                _clubNameController.clear();
                              });
                            },
                            child: Text(
                              _isManualClub
                                  ? 'Выбрать из списка'
                                  : 'Ввести вручную',
                            ),
                          ),
                        ],
                      ),

                      if (!_isManualClub)
                        DropdownButtonFormField<int>(
                          initialValue: _selectedClubId,
                          isExpanded: true,
                          hint: const Text('Выберите ваш клуб'),
                          items: state.clubs.map((club) {
                            return DropdownMenuItem<int>(
                              value: club['id'] as int,
                              child: Text(club['name']),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedClubId = val),
                          validator: (v) => !_isManualClub && v == null
                              ? 'Выберите клуб'
                              : null,
                        )
                      else
                        TextFormField(
                          controller: _clubNameController,
                          decoration: const InputDecoration(
                            labelText: 'Название клуба',
                            hintText: 'Например: Tennis Center A',
                          ),
                          validator: (v) =>
                              _isManualClub && (v == null || v.isEmpty)
                              ? 'Введите название'
                              : null,
                        ),

                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () =>
                            _saveProfile(state.profileData, state.clubs),
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
