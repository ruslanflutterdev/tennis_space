import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/profile_bloc.dart';
import '../widgets/custom_autocomplete_field.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _clubNameController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  int? _selectedClubId;
  bool _isManualClub = false;

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
  final List<String> _genders = ['Мужской', 'Женский'];

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
            if (_lastNameController.text.isEmpty &&
                _firstNameController.text.isEmpty) {
              _fillFields(state.profileData, state.clubs);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Личные данные',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Фамилия *'),
                      validator: (v) => v!.isEmpty ? 'Введите фамилию' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Имя *'),
                      validator: (v) => v!.isEmpty ? 'Введите имя' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _middleNameController,
                      decoration: const InputDecoration(labelText: 'Отчество'),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedDate == null
                            ? 'Дата рождения *'
                            : 'Дата рождения: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _selectedDate = date);
                      },
                    ),
                    const Divider(),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      hint: const Text('Пол *'),
                      items: _genders
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedGender = v),
                      validator: (v) => v == null ? 'Выберите пол' : null,
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Местоположение и Клуб',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            _isManualClub
                                ? 'Введите название клуба'
                                : 'Выберите клуб из списка',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                        ),
                        validator: (v) =>
                            _isManualClub && (v == null || v.isEmpty)
                            ? 'Введите название'
                            : null,
                      ),

                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => _save(state.profileData['id']),
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

  void _fillFields(
    Map<String, dynamic> profile,
    List<Map<String, dynamic>> clubs,
  ) {
    _lastNameController.text = profile['last_name'] ?? '';
    _firstNameController.text = profile['first_name'] ?? '';
    _middleNameController.text = profile['middle_name'] ?? '';
    _countryController.text = profile['country'] ?? '';
    _cityController.text = profile['city'] ?? '';

    if (profile['birth_date'] != null) {
      _selectedDate = DateTime.parse(profile['birth_date']);
    }

    final genderFromDb = profile['gender'] as String?;
    if (genderFromDb != null && _genders.contains(genderFromDb)) {
      _selectedGender = genderFromDb;
    } else {
      _selectedGender = genderFromDb;
    }

    final clubId = profile['club_id'];
    final clubName = profile['club_name'];

    if (clubId != null) {
      final exists = clubs.any((c) => c['id'] == clubId);
      if (exists) {
        _selectedClubId = clubId;
        _isManualClub = false;
      } else {
        _isManualClub = true;
        _clubNameController.text = clubName ?? '';
      }
    } else {
      _isManualClub = true;
      _clubNameController.text = clubName ?? '';
    }
  }

  void _save(String userId) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите дату')));
      return;
    }

    String? finalClubName;
    if (_isManualClub) {
      finalClubName = _clubNameController.text;
    } else {
      finalClubName = null;
    }

    context.read<ProfileBloc>().add(
      UpdateProfileRequested(
        userId: userId,
        lastName: _lastNameController.text,
        firstName: _firstNameController.text,
        middleName: _middleNameController.text.isEmpty
            ? null
            : _middleNameController.text,
        birthDate: _selectedDate!,
        gender: _selectedGender!,
        country: _countryController.text,
        city: _cityController.text,
        clubId: _isManualClub ? null : _selectedClubId,
        clubName: finalClubName,
      ),
    );
  }
}
