import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/dependencies/dependencies_container.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/profile_completion_screen.dart';
import 'features/auth/presentation/screens/registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tdskgjxzjatyiryflyfb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRkc2tnanh6amF0eWlyeWZseWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc1MjAxMjIsImV4cCI6MjA4MzA5NjEyMn0.EHNkB5zrsrHd94s7fN800Yg1U7GTR1CwjF74c4uliv0',
  );

  await initInjection();

  runApp(const TennisSpaceApp());
}

class TennisSpaceApp extends StatelessWidget {
  const TennisSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: MaterialApp.router(
        routerConfig: _router,
        title: 'TennisSpace',
        theme: ThemeData(primarySwatch: Colors.green),
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegistrationScreen()),
    GoRoute(path: '/forgot_password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/profile_completion', builder: (context, state) => const ProfileCompletionScreen()),
    GoRoute(path: '/coach', builder: (context, state) => _buildRolePage(context, "Кабинет Тренера по теннису")),
    GoRoute(path: '/fitness', builder: (context, state) => _buildRolePage(context, "Кабинет Тренера ОФП")),
    GoRoute(path: '/child', builder: (context, state) => _buildRolePage(context, "Кабинет Ребенка")),
    GoRoute(path: '/parent', builder: (context, state) => _buildRolePage(context, "Кабинет Родителя")),
    GoRoute(path: '/admin', builder: (context, state) => _buildRolePage(context, "Кабинет Админа")),
  ],
);

Widget _buildRolePage(BuildContext context, String title) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            context.read<AuthBloc>().add(AuthSignOutRequested());
            context.go('/');
          },
        )
      ],
    ),
    body: Center(child: Text(title)),
  );
}