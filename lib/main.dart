import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/dependencies/dependencies_container.dart';
import 'core/router/app_router.dart';
import 'features/auth/viewmodel/auth_bloc.dart';

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
        routerConfig: appRouter,
        title: 'TennisSpace',
        theme: ThemeData(primarySwatch: Colors.green),
      ),
    );
  }
}
