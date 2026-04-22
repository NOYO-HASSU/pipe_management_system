import 'package:flutter/material.dart';
import '../core/colors.dart';

class AddProductForm extends StatefulWidget {
  final Future<bool> Function(Map<String, dynamic> product) onSubmit;
  final Map<String, dynamic>? initialData;
  final List<String> categories;

  const AddProductForm({
    super.key,
    required this.onSubmit,
    required this.categories,
    this.initialData,
  });

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _purchaseController;
  late final TextEditingController _shopController;
  late final TextEditingController _retailController;
  late final TextEditingController _stockController;
  late final TextEditingController _maxStockController;
  late String? _selectedCategory;

  bool _isSubmitting = false;

  bool get _isEditMode => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;

    _nameController = TextEditingController(
      text: data?['name']?.toString() ?? '',
    );
    _skuController = TextEditingController(
      text: data?['sku']?.toString() ?? '',
    );
    _selectedCategory = data?['category']?.toString();
    _purchaseController = TextEditingController(
      text: _toFixed(data?['purchase'], 2),
    );
    _shopController = TextEditingController(text: _toFixed(data?['shop'], 2));
    _retailController = TextEditingController(
      text: _toFixed(data?['retail'], 2),
    );
    _stockController = TextEditingController(
      text: (data?['stock'] ?? '').toString(),
    );
    _maxStockController = TextEditingController(
      text: (data?['maxStock'] ?? '').toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _purchaseController.dispose();
    _shopController.dispose();
    _retailController.dispose();
    _stockController.dispose();
    _maxStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditMode ? 'Edit Product' : 'Add New Product',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isEditMode
                        ? 'Update inventory details'
                        : 'Register a new item to Warehouse Alpha',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(title: 'BASIC INFORMATION'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'PRODUCT NAME',
                    controller: _nameController,
                    hint: 'e.g., GI Pipe 4-inch Heavy Duty',
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'SKU',
                          controller: _skuController,
                          hint: 'e.g., GI-200-STD',
                          validator: _requiredValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _buildCategoryDropdown()),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle(title: 'FINANCIALS (PKR)'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'PURCHASE PRICE',
                          controller: _purchaseController,
                          hint: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _numberValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'SHOP PRICE',
                          controller: _shopController,
                          hint: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _numberValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'RETAIL PRICE',
                          controller: _retailController,
                          hint: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _numberValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle(title: 'STOCK CONTROL'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'STOCK QUANTITY',
                          controller: _stockController,
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: _intValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'MAX STOCK',
                          controller: _maxStockController,
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: _intValidator,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _isSubmitting
                        ? 'Saving...'
                        : (_isEditMode ? 'Update Product' : 'Save Product'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    final items = widget.categories.toSet().toList()..sort();
    final selected = items.contains(_selectedCategory)
        ? _selectedCategory
        : (items.isNotEmpty ? items.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CATEGORY',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: selected,
          items: items
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            return null;
          },
          hint: const Text(
            'Select category',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          isDense: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Invalid number';
    }
    return null;
  }

  String? _intValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Invalid integer';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payload = <String, dynamic>{
      'name': _nameController.text.trim(),
      'sku': _skuController.text.trim(),
      'category': (_selectedCategory ?? '').trim(),
      'purchase': double.parse(_purchaseController.text.trim()),
      'shop': double.parse(_shopController.text.trim()),
      'retail': double.parse(_retailController.text.trim()),
      'stock': int.parse(_stockController.text.trim()),
      'maxStock': int.parse(_maxStockController.text.trim()),
    };

    setState(() {
      _isSubmitting = true;
    });

    final success = await widget.onSubmit(payload);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not save product. Check RLS policies and SKU uniqueness.',
        ),
      ),
    );
  }

  String _toFixed(dynamic value, int fractionDigits) {
    if (value is num) {
      return value.toStringAsFixed(fractionDigits);
    }
    return '';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.9,
      ),
    );
  }
}
