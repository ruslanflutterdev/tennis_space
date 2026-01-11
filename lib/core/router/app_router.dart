import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/view/screens/forgot_password_screen.dart';
import '../../features/auth/view/screens/login_screen.dart';
import '../../features/auth/view/screens/registration_screen.dart';
import '../../features/profile/view/screens/profile_completion_screen.dart';
import '../../features/profile/view/screens/profile_edit_screen.dart';
import '../dependencies/dependencies_container.dart';
import '../../features/profile/viewmodel/profile_bloc.dart';
import '../widgets/role_dashboard_placeholder.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/forgot_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: '/profile_completion',
      builder: (context, state) {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        return BlocProvider(
          create: (context) => sl<ProfileBloc>()..add(LoadProfileData(userId)),
          child: const ProfileCompletionScreen(),
        );
      },
    ),
    GoRoute(
      path: '/coach',
      builder: (context, state) =>
          const RoleDashboardPlaceholder(title: "Кабинет Тренера по теннису"),
    ),
    GoRoute(
      path: '/fitness',
      builder: (context, state) =>
          const RoleDashboardPlaceholder(title: "Кабинет Тренера ОФП"),
    ),
    GoRoute(
      path: '/child',
      builder: (context, state) =>
          const RoleDashboardPlaceholder(title: "Кабинет Ребенка"),
    ),
    GoRoute(
      path: '/parent',
      builder: (context, state) =>
          const RoleDashboardPlaceholder(title: "Кабинет Родителя"),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) =>
          const RoleDashboardPlaceholder(title: "Кабинет Админа"),
    ),

    GoRoute(
      path: '/profile_edit',
      builder: (context, state) {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        return BlocProvider(
          create: (context) => sl<ProfileBloc>()..add(LoadProfileData(userId)),
          child: const ProfileEditScreen(),
        );
      },
    ),
  ],
);
