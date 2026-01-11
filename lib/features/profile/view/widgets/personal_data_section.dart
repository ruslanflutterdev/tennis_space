import 'package:flutter/material.dart';

class PersonalDataSection extends StatelessWidget {
  final TextEditingController lastNameController;
  final TextEditingController firstNameController;
  final TextEditingController middleNameController;
  final DateTime? selectedDate;
  final String? selectedGender;
  final List<String> genders;
  final VoidCallback onDateTap;
  final ValueChanged<String?> onGenderChanged;

  const PersonalDataSection({
    super.key,
    required this.lastNameController,
    required this.firstNameController,
    required this.middleNameController,
    required this.selectedDate,
    required this.selectedGender,
    required this.genders,
    required this.onDateTap,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Личные данные',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: lastNameController,
          decoration: const InputDecoration(labelText: 'Фамилия *'),
          validator: (v) => v!.isEmpty ? 'Введите фамилию' : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: firstNameController,
          decoration: const InputDecoration(labelText: 'Имя *'),
          validator: (v) => v!.isEmpty ? 'Введите имя' : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: middleNameController,
          decoration: const InputDecoration(labelText: 'Отчество'),
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            selectedDate == null
                ? 'Дата рождения *'
                : 'Дата рождения: ${selectedDate!.toLocal().toString().split(' ')[0]}',
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: onDateTap,
        ),
        const Divider(),
        DropdownButtonFormField<String>(
          initialValue: selectedGender,
          hint: const Text('Пол *'),
          items: genders
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: onGenderChanged,
          validator: (v) => v == null ? 'Выберите пол' : null,
        ),
      ],
    );
  }
}
