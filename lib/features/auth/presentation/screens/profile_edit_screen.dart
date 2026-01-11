import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/dependencies/dependencies_container.dart';
import '../bloc/auth_bloc.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _clubNameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;

  List<Map<String, dynamic>> _clubs = [];

  final List<String> _countries = ['Казахстан', 'Россия', 'Беларусь', 'Узбекистан', 'Кыргызстан'];
  final List<String> _cities = ['Алматы', 'Астана', 'Шымкент', 'Москва', 'Санкт-Петербург', 'Ташкент', 'Бишкек'];
  final List<String> _genders = ['Мужской', 'Женский'];

  int? _selectedClubId;
  bool _isManualClub = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _clubNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final repo = sl<AuthRepository>();

      final results = await Future.wait([
        repo.getClubs(),
        repo.getUserProfile(userId),
      ]);

      final clubs = results[0] as List<Map<String, dynamic>>;
      final profile = results[1] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _clubs = clubs;

          _lastNameController.text = profile['last_name'] ?? '';
          _firstNameController.text = profile['first_name'] ?? '';
          _middleNameController.text = profile['middle_name'] ?? '';

          if (profile['birth_date'] != null) {
            _selectedDate = DateTime.parse(profile['birth_date']);
          }

          final genderFromDb = profile['gender'] as String?;
          if (genderFromDb != null && _genders.contains(genderFromDb)) {
            _selectedGender = genderFromDb;
          } else {

            _selectedGender = genderFromDb;
          }
          _countryController.text = profile['country'] ?? '';
          _cityController.text = profile['city'] ?? '';
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

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите дату рождения')));
        return;
      }
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите пол')));
        return;
      }
      if (!_isManualClub && _selectedClubId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите клуб')));
        return;
      }
      if (_isManualClub && _clubNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите название клуба')));
        return;
      }

      setState(() => _isLoading = true);

      try {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final repo = sl<AuthRepository>();

        String? finalClubName;
        if (_isManualClub) {
          finalClubName = _clubNameController.text;
        } else {
          final selectedClub = _clubs.firstWhere((c) => c['id'] == _selectedClubId);
          finalClubName = selectedClub['name'];
        }

        await repo.updateProfile(
          userId: userId,
          lastName: _lastNameController.text,
          firstName: _firstNameController.text,
          middleName: _middleNameController.text.isEmpty ? null : _middleNameController.text,
          birthDate: _selectedDate!,
          gender: _selectedGender!,
          country: _countryController.text,
          city: _cityController.text,
          clubId: _isManualClub ? null : _selectedClubId,
          clubName: finalClubName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Профиль успешно обновлен')));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  Widget _buildAutocompleteField({
    required String label,
    required List<String> options,
    required TextEditingController controller,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue val) {
        if (val.text == '') return const Iterable<String>.empty();
        return options.where((opt) => opt.toLowerCase().contains(val.text.toLowerCase()));
      },
      onSelected: (String selection) => controller.text = selection,
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        if (controller.text.isNotEmpty && textController.text.isEmpty) {
          textController.text = controller.text;
        }
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          validator: (v) => v!.isEmpty ? 'Заполните поле' : null,
          onChanged: (val) => controller.text = val,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактирование профиля')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Личные данные', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
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
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
                validator: (v) => v == null ? 'Выберите пол' : null,
              ),

              const SizedBox(height: 30),
              const Text('Местоположение и Клуб', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              _buildAutocompleteField(
                label: 'Страна',
                options: _countries,
                controller: _countryController,
              ),
              const SizedBox(height: 10),

              _buildAutocompleteField(
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
                      _isManualClub ? 'Введите название клуба' : 'Выберите клуб из списка',
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
                    child: Text(_isManualClub ? 'Выбрать из списка' : 'Ввести вручную'),
                  ),
                ],
              ),

              if (!_isManualClub)
                DropdownButtonFormField<int>(
                  initialValue: _selectedClubId,
                  isExpanded: true,
                  hint: const Text('Выберите ваш клуб'),
                  items: _clubs.map((club) {
                    return DropdownMenuItem<int>(
                      value: club['id'] as int,
                      child: Text(club['name']),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedClubId = val),
                  validator: (v) => !_isManualClub && v == null ? 'Выберите клуб' : null,
                )
              else
                TextFormField(
                  controller: _clubNameController,
                  decoration: const InputDecoration(labelText: 'Название клуба'),
                  validator: (v) => _isManualClub && (v == null || v.isEmpty) ? 'Введите название' : null,
                ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Сохранить изменения'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}