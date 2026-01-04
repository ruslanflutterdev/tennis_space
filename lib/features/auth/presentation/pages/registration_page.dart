import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/user_model.dart';
import '../bloc/auth_bloc.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();

  UserRole? _selectedRole;
  DateTime? _selectedDate;
  String? _selectedGender;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < 8) return 'Минимум 8 символов';
    if (!RegExp(r'''
(?=.*?[A-Z])''').hasMatch(value)) {
      return 'Нужна 1 заглавная буква';
    }
    if (!RegExp(r'''
(?=.*?[!@#$&*~])''').hasMatch(value)) {
      return 'Нужен 1 спецсимвол';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedRole != null && _selectedDate != null) {
      final data = RegistrationData(
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole!,
        lastName: _lastNameController.text,
        firstName: _firstNameController.text,
        middleName: _middleNameController.text.isEmpty ? null : _middleNameController.text,
        birthDate: _selectedDate!,
        gender: _selectedGender ?? 'M',
      );
      context.read<AuthBloc>().add(AuthSignUpRequested(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация TennisSpace')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            switch (state.role) {
              case UserRole.tennisCoach: context.go('/coach'); break;
              case UserRole.fitnessCoach: context.go('/fitness'); break;
              case UserRole.child: context.go('/child'); break;
              case UserRole.parent: context.go('/parent'); break;
              case UserRole.admin: context.go('/admin'); break;
            }
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<UserRole>(
                  initialValue: _selectedRole,
                  hint: const Text('Выберите роль'),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role.name));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedRole = v),
                  validator: (v) => v == null ? 'Обязательное поле' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Фамилия *'),
                  validator: (v) => v!.isEmpty ? 'Обязательное поле' : null,
                ),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Имя *'),
                  validator: (v) => v!.isEmpty ? 'Обязательное поле' : null,
                ),
                TextFormField(
                  controller: _middleNameController,
                  decoration: const InputDecoration(labelText: 'Отчество'),
                ),
                ListTile(
                  title: Text(_selectedDate == null ? 'Дата рождения *' : 'Дата: ${_selectedDate!.toLocal()}'.split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now()
                    );
                    if(date != null) setState(() => _selectedDate = date);
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  hint: const Text('Пол *'),
                  items: ['Мужской', 'Женский'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setState(() => _selectedGender = v),
                  validator: (v) => v == null ? 'Обязательное поле' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Почта *'),
                  validator: (v) => !v!.contains('@') ? 'Некорректная почта' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Пароль *'),
                  obscureText: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Зарегистрироваться'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}