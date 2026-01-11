import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Добавлен для доступа к AuthBloc
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/dependencies/dependencies_container.dart';
import '../../data/models/user_model.dart'; // Добавлен для UserRole
import '../bloc/auth_bloc.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для ручного ввода
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _clubNameController = TextEditingController();

  // Данные для выбора
  List<Map<String, dynamic>> _clubs = [];

  // Примерные списки для автодополнения
  final List<String> _countries = [
    'Казахстан',
    'Россия',
    'Беларусь',
    'Узбекистан',
    'Кыргызстан'
  ];
  final List<String> _cities = [
    'Алматы',
    'Астана',
    'Шымкент',
    'Москва',
    'Санкт-Петербург',
    'Ташкент',
    'Бишкек'
  ];

  // Состояние выбора
  int? _selectedClubId;
  bool _isManualClub = false; // Флаг: вводит ли юзер клуб вручную
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClubs();
    });
  }

  Future<void> _loadClubs() async {
    try {
      final repo = sl<AuthRepository>();
      final clubs = await repo.getClubs();
      if (mounted) {
        setState(() {
          _clubs = clubs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Не блокируем экран ошибкой, просто список будет пуст
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Валидация клуба: должен быть выбран ID ИЛИ введено название
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

        // Определяем имя клуба: либо из списка, либо введенное
        String? finalClubName;
        if (_isManualClub) {
          finalClubName = _clubNameController.text;
        } else {
          final selectedClub = _clubs.firstWhere((c) => c['id'] == _selectedClubId);
          finalClubName = selectedClub['name'];
        }

        // 1. Сохраняем данные в Supabase
        await repo.completeProfile(
          userId: userId,
          country: _countryController.text,
          city: _cityController.text,
          clubId: _isManualClub ? null : _selectedClubId, // ID null если ручной ввод
          clubName: finalClubName,
        );

        if (mounted) {
          // 2. Получаем текущее состояние AuthBloc, чтобы узнать роль пользователя
          final authState = context.read<AuthBloc>().state;

          if (authState is AuthSuccess && authState.role != null) {
            // 3. Навигация в зависимости от роли
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
            // Если по какой-то причине роль потерялась (маловероятно),
            // можно перенаправить на логин или попробовать получить роль заново.
            // Пока оставим редирект на логин как запасной вариант.
            context.go('/');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Виджет для поля с автодополнением (Страна/Город)
  Widget _buildAutocompleteField({
    required String label,
    required List<String> options,
    required TextEditingController controller,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        // Синхронизируем контроллеры
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
      appBar: AppBar(title: const Text('Заполнение профиля')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Расскажите немного о себе, чтобы мы могли найти вашу группу.'),
                const SizedBox(height: 20),

                // СТРАНА
                _buildAutocompleteField(
                  label: 'Страна',
                  options: _countries,
                  controller: _countryController,
                ),
                const SizedBox(height: 10),

                // ГОРОД
                _buildAutocompleteField(
                  label: 'Город',
                  options: _cities,
                  controller: _cityController,
                ),
                const SizedBox(height: 20),

                const Divider(),
                const SizedBox(height: 10),

                // КЛУБ (Переключатель)
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
                    decoration: const InputDecoration(
                      labelText: 'Название клуба',
                      hintText: 'Например: Tennis Center A',
                    ),
                    validator: (v) =>
                    _isManualClub && (v == null || v.isEmpty) ? 'Введите название' : null,
                  ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Сохранить и продолжить'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}