import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/navigation_cubit.dart';
import '../core/colors.dart';
import '../core/responsive.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, activeIndex) {
        return Drawer(
          backgroundColor: AppColors.background,
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("PipeManager", style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Warehouse Alpha", style: TextStyle(color: Colors.black, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerListTile(title: "Dashboard", icon: Icons.dashboard, index: 0, activeIndex: activeIndex),
                    _DrawerListTile(title: "Inventory", icon: Icons.inventory_2_outlined, index: 1, activeIndex: activeIndex),
                    _DrawerListTile(title: "New Sale", icon: Icons.shopping_cart_outlined, index: 2, activeIndex: activeIndex),
                    _DrawerListTile(title: "History", icon: Icons.history, index: 3, activeIndex: activeIndex),
                    _DrawerListTile(title: "Reports", icon: Icons.bar_chart, index: 4, activeIndex: activeIndex),
                  ],
                ),
              ),
              // Settings at the bottom
              _DrawerListTile(title: "Settings", icon: Icons.settings, index: 5, activeIndex: activeIndex),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final int index;
  final int activeIndex;

  const _DrawerListTile({
    required this.title,
    required this.icon,
    required this.index,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = index == activeIndex;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        onTap: () {
          context.read<NavigationCubit>().setPage(index);
          // If on mobile, close the drawer after clicking
          if (!Responsive.isDesktop(context) && !Responsive.isTablet(context)) {
            Navigator.pop(context);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        horizontalTitleGap: 0.0,
        leading: Icon(icon, color: isSelected ? Colors.black : Colors.grey, size: 20),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        tileColor: isSelected ? Colors.black.withOpacity(0.15) : Colors.transparent,
      ),
    );
  }
}