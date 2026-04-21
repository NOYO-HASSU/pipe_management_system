import 'package:flutter_bloc/flutter_bloc.dart';

// States
abstract class DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final Map<String, dynamic> data;
  DashboardLoaded(this.data);
}
class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

// Cubit
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardLoading());

  void loadDashboardData() async {
    emit(DashboardLoading());
    try {
      // Simulating API call for Mock Data
      await Future.delayed(const Duration(milliseconds: 800));
      
      final mockData = {
        'totalSales': '1,240,500',
        'salesGrowth': '+12.5%',
        'totalProfit': '412,800',
        'profitGrowth': '+8.2%',
        'profitMargin': '33.2',
        'inStock': '8,421',
        'lowStock': 3,
      };
      
      emit(DashboardLoaded(mockData));
    } catch (e) {
      emit(DashboardError("Failed to fetch data"));
    }
  }
}