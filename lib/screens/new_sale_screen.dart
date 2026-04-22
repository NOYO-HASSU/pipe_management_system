import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/cart_cubit.dart';
import '../core/colors.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isProcessingSale = false;

  @override
  void dispose() {
    _customerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartCubit()..loadPosData(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CartLoaded) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Pane: Product Selection
                  Expanded(
                    flex: 6,
                    child: _buildProductSelectionPane(context, state),
                  ),
                  const SizedBox(width: 16),

                  // Right Pane: Active Cart
                  Expanded(flex: 4, child: _buildCartPane(context, state)),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildProductSelectionPane(BuildContext context, CartLoaded state) {
    final filteredProducts = _filterProducts(state.products);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // Very light gray from image
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "New Sale",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Select products to add to cart",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    _buildToggleButton("Retail", true),
                    _buildToggleButton("Shop", false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: "Search by pipe diameter, material, or SKU...",
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.grey,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),

          // Product List
          Expanded(
            child: ListView.separated(
              itemCount: filteredProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _ProductListItem(
                product: filteredProducts[index],
                onAdd: () {
                  context.read<CartCubit>().addToCart(filteredProducts[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterProducts(
    List<Map<String, dynamic>> products,
  ) {
    if (_searchQuery.isEmpty) {
      return products;
    }

    return products.where((product) {
      final name = (product['name'] ?? '').toString().toLowerCase();
      final sku = (product['sku'] ?? '').toString().toLowerCase();
      final stockStatus = (product['stockStatus'] ?? '').toString().toLowerCase();

      return name.contains(_searchQuery) ||
          sku.contains(_searchQuery) ||
          stockStatus.contains(_searchQuery);
    }).toList();
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 3,
                ),
              ]
            : [],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCartPane(BuildContext context, CartLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cart Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.shopping_bag,
                      color: AppColors.primaryDark,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Active Cart",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${state.cartItems.length} ITEMS",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // Cart Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.cartItems.length,
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1),
              ),
              itemBuilder: (context, index) =>
                  _CartListItem(item: state.cartItems[index]),
            ),
          ),

          // Summary Footer
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow(
                  "Subtotal",
                  "RS ${state.subtotal.toStringAsFixed(2)}",
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "RS ${state.total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Customer Assignment Input
                TextField(
                  controller: _customerController,
                  decoration: InputDecoration(
                    hintText: "Assign customer...",
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.person_outline, size: 18),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessingSale
                        ? null
                        : () => _confirmAndProcessSale(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isProcessingSale
                              ? "Processing Sale..."
                              : "Confirm & Process Sale",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Save as Quote",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAndProcessSale(BuildContext scopedContext) async {
    setState(() {
      _isProcessingSale = true;
    });

    try {
      await scopedContext.read<CartCubit>().processSale(
        customerName: _customerController.text.trim(),
      );

      if (!scopedContext.mounted || !mounted) {
        return;
      }

      _customerController.clear();
      ScaffoldMessenger.of(scopedContext).showSnackBar(
        const SnackBar(content: Text('Sale processed successfully.')),
      );
    } catch (e) {
      if (!scopedContext.mounted || !mounted) {
        return;
      }
      ScaffoldMessenger.of(
        scopedContext,
      ).showSnackBar(SnackBar(content: Text('Could not process sale: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingSale = false;
        });
      }
    }
  }
}

// --- Helper Widgets ---

class _ProductListItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAdd;

  const _ProductListItem({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = product['stock'] == 0;
    final bool isLowStock = product['stockStatus'] == 'LOW STOCK';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.architecture,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "SKU: ${product['sku']}",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "RS ${product['price'].toStringAsFixed(2)} / unit",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? Colors.grey.shade200
                      : (isLowStock
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFD1FAE5)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOutOfStock
                            ? Colors.grey
                            : (isLowStock
                                  ? Colors.red
                                  : AppColors.successGreen),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOutOfStock
                          ? "OUT OF STOCK"
                          : "${product['stock']} ${product['stockStatus']}",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isOutOfStock
                            ? Colors.grey.shade600
                            : (isLowStock
                                  ? Colors.red.shade700
                                  : Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: isOutOfStock ? null : onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartListItem extends StatelessWidget {
  final CartItem item;
  const _CartListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Retail Price: RS ${item.product['price'].toStringAsFixed(2)}",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => context.read<CartCubit>().updateQuantity(
                            item.product['id'],
                            -1,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Text(
                              "-",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          alignment: Alignment.center,
                          child: Text(
                            "${item.quantity}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => context.read<CartCubit>().updateQuantity(
                            item.product['id'],
                            1,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Text(
                              "+",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => context.read<CartCubit>().removeFromCart(
                      item.product['id'],
                    ),
                    child: const Text(
                      "Remove",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(
          "RS ${item.totalPrice.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
