import 'package:flutter/material.dart';
import '../core/colors.dart';

class AddProductForm extends StatelessWidget {
  const AddProductForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Add New Product", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Register a new item to Warehouse Alpha", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
            ],
          ),
        ),
        const Divider(height: 1),
        
        // Scrollable Form Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: "BASIC INFORMATION"),
                const SizedBox(height: 16),
                _buildTextField("PRODUCT NAME", "e.g., GI Pipe 4-inch Heavy Duty"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField("CATEGORY", "Select...", isDropdown: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField("VARIANT / SIZE", "e.g., 4 inch / Sch 40")),
                  ],
                ),
                const SizedBox(height: 32),
                
                const _SectionTitle(title: "FINANCIALS (PKR)"),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("PURCHASE PRICE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("Rs. 0.00", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text("MARGIN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          Text("0%", style: TextStyle(fontSize: 18, color: AppColors.warningYellow, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField("SHOP PRICE", "Rs. 0.00", filled: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField("RETAIL PRICE", "Rs. 0.00", filled: true)),
                  ],
                ),
                const SizedBox(height: 32),
                
                const _SectionTitle(title: "STOCK CONTROL"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField("STOCK QUANTITY", "0")),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField("UNIT", "Meters", isDropdown: true)),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Bottom Action Buttons
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text("Cancel", style: TextStyle(color: AppColors.textPrimary)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 16)
                  ),
                  child: const Text("Save Product", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {bool isDropdown = false, bool filled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            suffixIcon: isDropdown ? const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary) : null,
            filled: filled,
            fillColor: filled ? AppColors.background : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: filled ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: filled ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1));
  }
}