import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/navigation_cubit.dart';
import '../core/colors.dart';
import '../core/responsive.dart';
import '../widgets/side_menu.dart';

// Import our screens
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'new_sale_screen.dart';
import 'placeholder_screens.dart'; // We'll create this next

class MainLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Responsive.isMobile(context) ? const SideMenu() : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context) || Responsive.isTablet(context))
              const Expanded(flex: 2, child: SideMenu()),
            
            Expanded(
              flex: 10,
              child: Column(
                children: [
                  _buildTopBar(context),
                  // Listen to NavigationCubit to swap screens dynamically
                  Expanded(
                    child: BlocBuilder<NavigationCubit, int>(
                      builder: (context, activeIndex) {
                        switch (activeIndex) {
                          case 0: return const DashboardScreen();
                          case 1: return const InventoryScreen();
                          case 2: return const NewSaleScreen();
                          case 3: return const HistoryScreen(); // Placeholder
                          case 4: return const ReportsScreen(); // Placeholder
                          case 5: return const SettingsScreen(); // Placeholder
                          default: return const DashboardScreen();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          if (!Responsive.isDesktop(context) && !Responsive.isTablet(context))
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          // Dynamic Title based on selected tab
          BlocBuilder<NavigationCubit, int>(
            builder: (context, activeIndex) {
              final titles = ["Executive Dashboard", "Inventory Management", "Point of Sale", "Sales History", "Reports", "Settings"];
              return Text(
                titles[activeIndex],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              );
            },
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: AppColors.primaryDark,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }
}