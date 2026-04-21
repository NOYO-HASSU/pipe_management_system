import 'package:flutter_bloc/flutter_bloc.dart';

abstract class InventoryState {}
class InventoryLoading extends InventoryState {}
class InventoryLoaded extends InventoryState {
  final List<Map<String, dynamic>> products;
  InventoryLoaded(this.products);
}

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit() : super(InventoryLoading());

  void loadInventory() async {
    emit(InventoryLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    
    final mockProducts = [
      {
        'name': 'GI Pipe - 2 Inch', 'sku': 'GI-200-STD', 'category': 'GI / Standard',
        'purchase': 45.00, 'shop': 58.50, 'retail': 65.00, 'stock': 1240, 'maxStock': 2000, 'isLow': false
      },
      {
        'name': 'UPVC Drainage Pipe', 'sku': 'UPVC-DR-110', 'category': 'UPVC / Premium',
        'purchase': 12.20, 'shop': 15.50, 'retail': 18.99, 'stock': 450, 'maxStock': 1000, 'isLow': false
      },
      {
        'name': 'PPR High Pressure 25mm', 'sku': 'PPR-HP-25', 'category': 'PPR / Premium',
        'purchase': 8.75, 'shop': 11.20, 'retail': 12.50, 'stock': 2100, 'maxStock': 3000, 'isLow': false
      },
      {
        'name': 'GI Elbow 90 Degree', 'sku': 'GI-EL-90', 'category': 'GI / Standard',
        'purchase': 3.40, 'shop': 4.80, 'retail': 5.50, 'stock': 12, 'maxStock': 100, 'isLow': true
      },
    ];
    emit(InventoryLoaded(mockProducts));
  }
}