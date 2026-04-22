import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/inventory_cubit.dart';
import '../core/colors.dart';
import 'add_product_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All Categories';
  String _selectedQuality = 'All Quality';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InventoryCubit()..loadInventory(),
      child: Builder(
        builder: (context) {
          // Use a context that is under BlocProvider so button callbacks can read InventoryCubit.
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildActionRow(context),
                const SizedBox(height: 16),
                _buildProductList(),
              ],
            ),
          );
        },
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
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _showAddCategoryDialog(context),
              icon: const Icon(Icons.category_outlined, size: 18),
              label: const Text("Add Category", style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                side: const BorderSide(color: AppColors.primaryDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _showAddProductDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                "Add New Product",
                style: TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        final categories = state is InventoryLoaded
            ? state.categories
            : <String>[];
        final qualityOptions = ['All Quality', 'Low Stock', 'In Stock'];

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
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
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
              _buildDropdown(
                value: _selectedCategory,
                hint: 'All Categories',
                items: categories,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? 'All Categories';
                  });
                },
              ),
              const SizedBox(width: 12),
              _buildDropdown(
                value: _selectedQuality,
                hint: 'All Quality',
                items: qualityOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedQuality = value ?? 'All Quality';
                  });
                },
              ),
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
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final options = <String>[hint, ...items.where((item) => item != hint)];

    return SizedBox(
      width: 150,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(7),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: options.contains(value) ? value : hint,
            hint: Text(hint, style: const TextStyle(fontSize: 12)),
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
            isDense: true,
            isExpanded: false,
            items: options
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option, style: const TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  List<String> _currentCategories(BuildContext context, {String? include}) {
    final state = context.read<InventoryCubit>().state;
    final categories = <String>[
      if (state is InventoryLoaded) ...state.categories,
    ];

    final includeValue = include?.trim();
    if (includeValue != null &&
        includeValue.isNotEmpty &&
        !categories.contains(includeValue)) {
      categories.add(includeValue);
      categories.sort();
    }

    return categories;
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final cubit = context.read<InventoryCubit>();
    final controller = TextEditingController();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g., GI / Standard'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    final name = controller.text.trim();
    controller.dispose();

    if (shouldSave != true || name.isEmpty) {
      return;
    }

    final success = await cubit.addCategory(name);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Category added successfully.'
              : 'Could not add category. Ensure categories table and policies exist.',
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
                final filteredProducts = _filterProducts(state.products);

                return ListView.separated(
                  shrinkWrap:
                      true, // FIX 3: Forces ListView to take only needed space
                  physics:
                      const NeverScrollableScrollPhysics(), // Disables nested scrolling
                  itemCount: filteredProducts.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => _ProductRow(
                    data: filteredProducts[index],
                    onEdit: () {
                      _showEditProductDialog(context, filteredProducts[index]);
                    },
                    onDelete: () =>
                        _confirmDeleteProduct(context, filteredProducts[index]),
                  ),
                );
              }
              if (state is InventoryError) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<InventoryCubit>().loadInventory(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
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
                BlocBuilder<InventoryCubit, InventoryState>(
                  builder: (context, state) {
                    final total = state is InventoryLoaded
                        ? state.products.length
                        : 0;
                    final visible = state is InventoryLoaded
                        ? _filterProducts(state.products).length
                        : 0;
                    return Text(
                      'Showing $visible of $total products',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    );
                  },
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

  List<Map<String, dynamic>> _filterProducts(
    List<Map<String, dynamic>> products,
  ) {
    return products.where((product) {
      final name = (product['name'] ?? '').toString().toLowerCase();
      final sku = (product['sku'] ?? '').toString().toLowerCase();
      final category = (product['category'] ?? '').toString().toLowerCase();
      final stock = (product['stock'] as num?)?.toInt() ?? 0;
      final isLowStock = stock > 0 && stock <= 20;
      final selectedCategory = _selectedCategory.toLowerCase();

      final matchesCategory =
          selectedCategory == 'all categories' || category == selectedCategory;
      final matchesQuality =
          _selectedQuality == 'All Quality' ||
          (_selectedQuality == 'Low Stock' && isLowStock) ||
          (_selectedQuality == 'In Stock' && stock > 20);

      final matchesSearch =
          _searchQuery.isEmpty ||
          name.contains(_searchQuery) ||
          sku.contains(_searchQuery) ||
          category.contains(_searchQuery);

      return matchesSearch && matchesCategory && matchesQuality;
    }).toList();
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

  Future<void> _confirmDeleteProduct(
    BuildContext context,
    Map<String, dynamic> product,
  ) async {
    final id = product['id']?.toString();
    if (id == null || id.isEmpty) {
      return;
    }

    final name = product['name']?.toString() ?? 'this product';
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    context.read<InventoryCubit>().deleteProduct(id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product deleted.')));
  }

  void _showAddProductDialog(BuildContext context) {
    final cubit = context.read<InventoryCubit>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add Product",
      pageBuilder: (dialogContext, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 10,
            child: Container(
              width: 500,
              color: Colors.white,
              child: BlocProvider.value(
                value: cubit,
                child: AddProductForm(
                  categories: _currentCategories(context),
                  onSubmit: (product) {
                    return cubit.addProduct(product);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditProductDialog(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    final cubit = context.read<InventoryCubit>();
    final id = product['id']?.toString();
    if (id == null || id.isEmpty) {
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Edit Product",
      pageBuilder: (dialogContext, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 10,
            child: Container(
              width: 500,
              color: Colors.white,
              child: BlocProvider.value(
                value: cubit,
                child: AddProductForm(
                  categories: _currentCategories(
                    context,
                    include: product['category']?.toString(),
                  ),
                  initialData: product,
                  onSubmit: (updatedProduct) {
                    return cubit.updateProduct(id, updatedProduct);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductRow({
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

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
              "RS ${data['purchase'].toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "RS ${data['shop'].toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "RS ${data['retail'].toStringAsFixed(2)}",
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
                    value: (data['maxStock'] as num? ?? 0) <= 0
                        ? 0
                        : (data['stock'] as num? ?? 0) /
                              (data['maxStock'] as num),
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
                  onPressed: onEdit,
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
                  onPressed: onDelete,
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
