import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/registration_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  await initInjection();

  runApp(const TennisSpaceApp());
}

class TennisSpaceApp extends StatelessWidget {
  const TennisSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(), // sl = service locator
      child: MaterialApp.router(
        routerConfig: _router,
        title: 'TennisSpace',
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/register',
  routes: [
    GoRoute(path: '/register', builder: (context, state) => const RegistrationPage()),
    // Пустые страницы ролей
    GoRoute(path: '/coach', builder: (context, state) => const Scaffold(body: Center(child: Text("Кабинет Тренера по теннису")))),
    GoRoute(path: '/fitness', builder: (context, state) => const Scaffold(body: Center(child: Text("Кабинет Тренера ОФП")))),
    GoRoute(path: '/child', builder: (context, state) => const Scaffold(body: Center(child: Text("Кабинет Ребенка")))),
    GoRoute(path: '/parent', builder: (context, state) => const Scaffold(body: Center(child: Text("Кабинет Родителя")))),
    GoRoute(path: '/admin', builder: (context, state) => const Scaffold(body: Center(child: Text("Кабинет Админа")))),
  ],
);