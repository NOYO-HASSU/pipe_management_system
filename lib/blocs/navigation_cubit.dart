import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  // 0: Dashboard, 1: Inventory, 2: New Sale, 3: History, 4: Reports
  NavigationCubit() : super(1);

  void setPage(int index) => emit(index);
}