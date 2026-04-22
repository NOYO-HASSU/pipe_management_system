import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'blocs/navigation_cubit.dart';
import 'core/colors.dart';
import 'screens/main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Allow the app to continue when a local .env file is not present.
  }

  const definedSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const definedSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  final supabaseUrl = definedSupabaseUrl.isNotEmpty
      ? definedSupabaseUrl
      : (dotenv.env['SUPABASE_URL'] ??
            'https://akwbxjyubtqkxftbhnut.supabase.co');
  final supabaseAnonKey = definedSupabaseAnonKey.isNotEmpty
      ? definedSupabaseAnonKey
      : (dotenv.env['SUPABASE_ANON_KEY'] ??
            'sb_publishable_ctp5VTFJgeKcXs0Gs_gI9Q_RO0KPKzN');

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const PipeManagerApp());
}

class PipeManagerApp extends StatelessWidget {
  const PipeManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M&M Group',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,

colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryDark, primary: AppColors.primaryDark),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
//circular loading indicator theme
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryDark,
        ),
//alret dialg theme
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(04),
          ),
        ),

      ),
      // Provide the NavigationCubit to the entire app
      home: BlocProvider(
        create: (context) => NavigationCubit(),
        child: MainLayout(),
      ),
    );
  }
}
