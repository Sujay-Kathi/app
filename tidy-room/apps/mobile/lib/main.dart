import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/room/providers/room_provider.dart';
import 'features/tasks/providers/task_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/child/providers/child_provider.dart';
import 'features/store/providers/store_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F172A), // Dark background
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Supabase
  // TODO: Replace with your Supabase credentials
  await Supabase.initialize(
    url: 'https://nqlspwrcdbwhdtjyrhak.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xbHNwd3JjZGJ3aGR0anlyaGFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyNTkzNDMsImV4cCI6MjA3ODgzNTM0M30.q-kA6RFFjjsoQq_tzndUGr75JGZxZ6_O-cNP1GMkbZU',
  );

  runApp(const TidyRoomApp());
}

// Supabase client instance
final supabase = Supabase.instance.client;

class TidyRoomApp extends StatelessWidget {
  const TidyRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChildProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
      ],
      child: MaterialApp.router(
        title: 'Tidy Room Simulator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Changed to dark mode as default
        routerConfig: AppRouter.router,
      ),
    );
  }
}
