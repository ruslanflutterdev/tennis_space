import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/viewmodel/auth_bloc.dart';

class RoleDashboardPlaceholder extends StatelessWidget {
  final String title;

  const RoleDashboardPlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Редактировать профиль',
            onPressed: () {
              context.push('/profile_edit');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
              context.go('/');
            },
          ),
        ],
      ),
      body: Center(child: Text(title)),
    );
  }
}
