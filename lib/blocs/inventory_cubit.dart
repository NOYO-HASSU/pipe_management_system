import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/inventory_repository.dart';

abstract class InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<Map<String, dynamic>> products;
  final List<String> categories;

  InventoryLoaded(this.products, this.categories);
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
}

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository _repository;

  InventoryCubit({InventoryRepository? repository})
    : _repository = repository ?? InventoryRepository(),
      super(InventoryLoading());

  Future<void> loadInventory() async {
    emit(InventoryLoading());
    try {
      final products = await _repository.fetchProducts();
      final categories = await _repository.fetchCategories();
      emit(InventoryLoaded(products, categories));
    } catch (e) {
      emit(InventoryError('Failed to load products: $e'));
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      await loadInventory();
    } catch (e) {
      emit(InventoryError('Failed to delete product: $e'));
    }
  }

  Future<bool> addProduct(Map<String, dynamic> product) async {
    try {
      await _repository.addProduct(product);
      await loadInventory();
      return true;
    } catch (e) {
      emit(InventoryError('Failed to add product: $e'));
      return false;
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> product) async {
    try {
      await _repository.updateProduct(id, product);
      await loadInventory();
      return true;
    } catch (e) {
      emit(InventoryError('Failed to update product: $e'));
      return false;
    }
  }

  Future<bool> addCategory(String name) async {
    try {
      await _repository.addCategory(name);
      await loadInventory();
      return true;
    } catch (e) {
      emit(InventoryError('Failed to add category: $e'));
      return false;
    }
  }
}
