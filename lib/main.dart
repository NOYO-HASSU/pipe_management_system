import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'blocs/navigation_cubit.dart';
import 'core/colors.dart';
import 'screens/main_layout.dart';

void main() {
  runApp(const PipeManagerApp());
}

class PipeManagerApp extends StatelessWidget {
  const PipeManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PipeManager Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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