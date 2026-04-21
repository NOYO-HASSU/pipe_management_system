import 'package:flutter_bloc/flutter_bloc.dart';

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
  CartCubit() : super(CartLoading());

  final List<Map<String, dynamic>> _mockProducts = [
    {'id': '1', 'name': 'Galvanized Steel Pipe 2"', 'sku': 'GS-200-S40', 'price': 45.00, 'stock': 124, 'stockStatus': 'IN STOCK'},
    {'id': '2', 'name': 'PVC Schedule 40 - 1.5"', 'sku': 'PVC-150-S40', 'price': 12.50, 'stock': 842, 'stockStatus': 'IN STOCK'},
    {'id': '3', 'name': 'Copper Tubing Type L - 0.75"', 'sku': 'COP-075-TL', 'price': 89.20, 'stock': 12, 'stockStatus': 'LOW STOCK'},
    {'id': '4', 'name': 'Seamless Black Pipe 4"', 'sku': 'SBP-400-H', 'price': 156.00, 'stock': 0, 'stockStatus': 'OUT OF STOCK'},
  ];

  List<CartItem> _cartItems = [];

  void loadPosData() async {
    emit(CartLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Initial mock cart state based on the image
    _cartItems = [
      CartItem(product: _mockProducts[0], quantity: 10),
      CartItem(product: _mockProducts[1], quantity: 50),
      CartItem(product: _mockProducts[2], quantity: 2),
    ];
    _emitUpdate();
  }

  void updateQuantity(String productId, int delta) {
    final index = _cartItems.indexWhere((item) => item.product['id'] == productId);
    if (index >= 0) {
      _cartItems[index].quantity += delta;
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

  void _emitUpdate() {
    double subtotal = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
    double tax = subtotal * 0.08; // 8% tax from image
    double surcharge = 25.00; // Fixed surcharge from image
    double total = subtotal + tax + surcharge;

    emit(CartLoaded(
      products: _mockProducts,
      cartItems: List.from(_cartItems), // Clone to trigger state update
      subtotal: subtotal,
      tax: tax,
      surcharge: surcharge,
      total: total,
    ));
  }
}