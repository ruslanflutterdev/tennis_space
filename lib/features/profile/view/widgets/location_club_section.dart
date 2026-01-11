import 'package:flutter/material.dart';
import 'custom_autocomplete_field.dart';

class LocationClubSection extends StatelessWidget {
  final TextEditingController countryController;
  final TextEditingController cityController;
  final TextEditingController clubNameController;
  final List<String> countries;
  final List<String> cities;
  final List<Map<String, dynamic>> clubs;
  final bool isManualClub;
  final int? selectedClubId;
  final VoidCallback onToggleManual;
  final ValueChanged<int?> onClubSelected;

  const LocationClubSection({
    super.key,
    required this.countryController,
    required this.cityController,
    required this.clubNameController,
    required this.countries,
    required this.cities,
    required this.clubs,
    required this.isManualClub,
    required this.selectedClubId,
    required this.onToggleManual,
    required this.onClubSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Местоположение и Клуб',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        CustomAutocompleteField(
          label: 'Страна',
          options: countries,
          controller: countryController,
        ),
        const SizedBox(height: 10),
        CustomAutocompleteField(
          label: 'Город',
          options: cities,
          controller: cityController,
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                isManualClub
                    ? 'Введите название клуба'
                    : 'Выберите клуб из списка',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: onToggleManual,
              child: Text(
                isManualClub ? 'Выбрать из списка' : 'Ввести вручную',
              ),
            ),
          ],
        ),

        if (!isManualClub)
          DropdownButtonFormField<int>(
            initialValue: selectedClubId,
            isExpanded: true,
            hint: const Text('Выберите ваш клуб'),
            items: clubs.map((club) {
              return DropdownMenuItem<int>(
                value: club['id'] as int,
                child: Text(club['name']),
              );
            }).toList(),
            onChanged: onClubSelected,
            validator: (v) =>
                !isManualClub && v == null ? 'Выберите клуб' : null,
          )
        else
          TextFormField(
            controller: clubNameController,
            decoration: const InputDecoration(labelText: 'Название клуба'),
            validator: (v) => isManualClub && (v == null || v.isEmpty)
                ? 'Введите название'
                : null,
          ),
      ],
    );
  }
}
