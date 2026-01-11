import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/profile_completion_screen.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../../auth/data/models/user_model.dart';
import '../../viewmodel/profile_bloc.dart';

mixin ProfileCompletionMixin on State<ProfileCompletionScreen> {
  final formKey = GlobalKey<FormState>();

  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final clubNameController = TextEditingController();

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

  int? selectedClubId;
  bool isManualClub = false;

  @override
  void dispose() {
    countryController.dispose();
    cityController.dispose();
    clubNameController.dispose();
    super.dispose();
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

  void saveProfile(
    Map<String, dynamic> profileData,
    List<Map<String, dynamic>> clubs,
  ) {
    if (formKey.currentState!.validate()) {
      if (!isManualClub && selectedClubId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Выберите клуб')));
        return;
      }
      if (isManualClub && clubNameController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Введите название клуба')));
        return;
      }

      final userId = Supabase.instance.client.auth.currentUser!.id;

      String? finalClubName;
      if (isManualClub) {
        finalClubName = clubNameController.text;
      } else {
        final selectedClub = clubs.firstWhere((c) => c['id'] == selectedClubId);
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
          country: countryController.text,
          city: cityController.text,
          clubId: isManualClub ? null : selectedClubId,
          clubName: finalClubName,
        ),
      );
    }
  }

  void navigateBasedOnRole() {
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
}
