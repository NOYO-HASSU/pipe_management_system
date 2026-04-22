import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/sales_repository.dart';

class CartItem {
  final Map<String, dynamic> product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product['price'] * quantity;
}

abstract class CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Map<String, dynamic>> products;
  final List<CartItem> cartItems;
  final double subtotal;
  final double tax;
  final double surcharge;
  final double total;

  CartLoaded({
    required this.products,
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.surcharge,
    required this.total,
  });
}

class CartCubit extends Cubit<CartState> {
  final SalesRepository _salesRepository;

  CartCubit({SalesRepository? salesRepository})
    : _salesRepository = salesRepository ?? SalesRepository(),
      super(CartLoading());

  List<Map<String, dynamic>> _products = [];
  List<CartItem> _cartItems = [];

  Future<void> loadPosData() async {
    emit(CartLoading());
    _products = await _salesRepository.fetchPosProducts();
    _cartItems = [];
    _emitUpdate();
  }

  void addToCart(Map<String, dynamic> product) {
    final stock = product['stock'] as int? ?? 0;
    if (stock <= 0) {
      return;
    }

    final index = _cartItems.indexWhere(
      (item) => item.product['id'] == product['id'],
    );

    if (index >= 0) {
      if (_cartItems[index].quantity < stock) {
        _cartItems[index].quantity += 1;
      }
    } else {
      _cartItems.add(CartItem(product: product, quantity: 1));
    }

    _emitUpdate();
  }

  void updateQuantity(String productId, int delta) {
    final index = _cartItems.indexWhere(
      (item) => item.product['id'] == productId,
    );
    if (index >= 0) {
      final stock = _cartItems[index].product['stock'] as int? ?? 0;
      final nextQuantity = _cartItems[index].quantity + delta;

      if (nextQuantity > stock) {
        return;
      }

      _cartItems[index].quantity = nextQuantity;
      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
      _emitUpdate();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product['id'] == productId);
    _emitUpdate();
  }

  Future<void> processSale({String? customerName}) async {
    if (state is! CartLoaded) {
      throw StateError('Cart is not ready yet.');
    }

    final current = state as CartLoaded;
    if (current.cartItems.isEmpty) {
      throw StateError('Cart is empty. Add items before processing sale.');
    }

    final payloadItems = current.cartItems
        .map(
          (item) => {
            'productId': item.product['id'],
            'name': item.product['name'],
            'sku': item.product['sku'],
            'unitPrice': item.product['price'],
            'quantity': item.quantity,
            'lineTotal': item.totalPrice,
          },
        )
        .toList();

    await _salesRepository.createSale(
      items: payloadItems,
      subtotal: current.subtotal,
      tax: current.tax,
      surcharge: current.surcharge,
      total: current.total,
      customerName: customerName,
    );

    await loadPosData();
  }

  void _emitUpdate() {
    double subtotal = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
    double tax = 0;
    double surcharge = 0;
    double total = subtotal;

    emit(
      CartLoaded(
        products: List.from(_products),
        cartItems: List.from(_cartItems),
        subtotal: subtotal,
        tax: tax,
        surcharge: surcharge,
        total: total,
      ),
    );
  }
}
