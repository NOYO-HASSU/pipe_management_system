import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/inventory_cubit.dart';
import '../core/colors.dart';
import 'add_product_dialog.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InventoryCubit()..loadInventory(),
      // FIX 1: Wrap the entire screen in a scroll view to prevent height crashes
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildActionRow(),
            const SizedBox(height: 16),
            // FIX 2: Removed 'Expanded' so it doesn't crash on smaller screens
            _buildProductList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Products",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddProductDialog(context),
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Add New Product", style: TextStyle(fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by SKU or product name...",
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildDropdown("All Categories"),
          const SizedBox(width: 12),
          _buildDropdown("All Quality"),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.filter_list,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(7),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: const TextStyle(fontSize: 12)),
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          isDense: true,
          items: const [],
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Allows column to fit its children
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text("PRODUCT NAME", style: _headerStyle),
                ),
                Expanded(
                  flex: 2,
                  child: Text("CATEGORY/VARIANT", style: _headerStyle),
                ),
                Expanded(
                  flex: 1,
                  child: Text("PURCHASE\nPRICE", style: _headerStyle),
                ),
                Expanded(
                  flex: 1,
                  child: Text("SHOP\nPRICE", style: _headerStyle),
                ),
                Expanded(
                  flex: 1,
                  child: Text("RETAIL\nPRICE", style: _headerStyle),
                ),
                Expanded(
                  flex: 1,
                  child: Text("STOCK\nQTY", style: _headerStyle),
                ),
                SizedBox(
                  width: 68,
                  child: Text(
                    "ACTIONS",
                    style: _headerStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Body
          BlocBuilder<InventoryCubit, InventoryState>(
            builder: (context, state) {
              if (state is InventoryLoading) {
                return const Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is InventoryLoaded) {
                return ListView.separated(
                  shrinkWrap:
                      true, // FIX 3: Forces ListView to take only needed space
                  physics:
                      const NeverScrollableScrollPhysics(), // Disables nested scrolling
                  itemCount: state.products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _ProductRow(data: state.products[index]),
                );
              }
              return const SizedBox();
            },
          ),
          const Divider(height: 1),
          // Pagination Footer (Matches the image exactly)
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Showing 1-4 of 124 products",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.chevron_left,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    _buildPageNumber("1", isActive: true),
                    const SizedBox(width: 6),
                    _buildPageNumber("2"),
                    const SizedBox(width: 6),
                    _buildPageNumber("3"),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumber(String number, {bool isActive = false}) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryDark : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        number,
        style: TextStyle(
          fontSize: 11,
          color: isActive ? Colors.white : AppColors.textPrimary,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  void _showAddProductDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add Product",
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 10,
            child: Container(
              width: 500,
              color: Colors.white,
              child: const AddProductForm(),
            ),
          ),
        );
      },
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ProductRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.image, color: Colors.grey, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "SKU: ${data['sku']}",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: data['category'].contains('Premium')
                      ? const Color(0xFFE0E7FF)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  data['category'],
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "\$${data['purchase'].toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "\$${data['shop'].toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "\$${data['retail'].toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: data['isLow'] ? Colors.red : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(text: "${data['stock']} "),
                      const TextSpan(
                        text: "units",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: data['stock'] / data['maxStock'],
                    backgroundColor: AppColors.background,
                    color: data['isLow'] ? Colors.red : AppColors.primaryDark,
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () {},
                  color: AppColors.textSecondary,
                  splashRadius: 16,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () {},
                  color: Colors.red.shade400,
                  splashRadius: 16,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
