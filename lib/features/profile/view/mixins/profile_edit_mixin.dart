import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/profile_edit_screen.dart';
import '../../viewmodel/profile_bloc.dart';

mixin ProfileEditMixin on State<ProfileEditScreen> {
  final formKey = GlobalKey<FormState>();

  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final clubNameController = TextEditingController();

  DateTime? selectedDate;
  String? selectedGender;
  int? selectedClubId;
  bool isManualClub = false;

  final List<String> countries = [
    'Казахстан',
    'Россия',
    'Беларусь',
    'Узбекистан',
    'Кыргызстан',
  ];
  final List<String> cities = [
    'Алматы',
    'Астана',
    'Шымкент',
    'Москва',
    'Санкт-Петербург',
    'Ташкент',
    'Бишкек',
  ];
  final List<String> genders = ['Мужской', 'Женский'];

  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    countryController.dispose();
    cityController.dispose();
    clubNameController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  void onToggleManual() {
    setState(() {
      isManualClub = !isManualClub;
      selectedClubId = null;
      clubNameController.clear();
    });
  }

  void onClubSelected(int? value) {
    setState(() => selectedClubId = value);
  }

  void onGenderChanged(String? value) {
    setState(() => selectedGender = value);
  }

  void fillFields(
    Map<String, dynamic> profile,
    List<Map<String, dynamic>> clubs,
  ) {
    lastNameController.text = profile['last_name'] ?? '';
    firstNameController.text = profile['first_name'] ?? '';
    middleNameController.text = profile['middle_name'] ?? '';
    countryController.text = profile['country'] ?? '';
    cityController.text = profile['city'] ?? '';

    if (profile['birth_date'] != null) {
      selectedDate = DateTime.parse(profile['birth_date']);
    }

    final genderFromDb = profile['gender'] as String?;
    if (genderFromDb != null && genders.contains(genderFromDb)) {
      selectedGender = genderFromDb;
    } else {
      selectedGender = genderFromDb;
    }

    final clubId = profile['club_id'];
    final clubName = profile['club_name'];

    if (clubId != null) {
      final exists = clubs.any((c) => c['id'] == clubId);
      if (exists) {
        selectedClubId = clubId;
        isManualClub = false;
      } else {
        isManualClub = true;
        clubNameController.text = clubName ?? '';
      }
    } else {
      isManualClub = true;
      clubNameController.text = clubName ?? '';
    }
  }

  void save(String userId) {
    if (!formKey.currentState!.validate()) return;
    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите дату')));
      return;
    }

    String? finalClubName;
    if (isManualClub) {
      finalClubName = clubNameController.text;
    } else {
      finalClubName = null;
    }

    context.read<ProfileBloc>().add(
      UpdateProfileRequested(
        userId: userId,
        lastName: lastNameController.text,
        firstName: firstNameController.text,
        middleName: middleNameController.text.isEmpty
            ? null
            : middleNameController.text,
        birthDate: selectedDate!,
        gender: selectedGender!,
        country: countryController.text,
        city: cityController.text,
        clubId: isManualClub ? null : selectedClubId,
        clubName: finalClubName,
      ),
    );
  }
}
