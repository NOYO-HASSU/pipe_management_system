import 'package:flutter/material.dart';
import '../core/colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Sales History Module Coming Soon", style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Analytics & Reports Module Coming Soon", style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("System Settings Module Coming Soon", style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
    );
  }
}