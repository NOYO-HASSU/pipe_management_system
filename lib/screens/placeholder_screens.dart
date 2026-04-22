import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/sales_repository.dart';
import '../widgets/sale_receipt_dialog.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final SalesRepository _salesRepository = SalesRepository();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _historyFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _historyFuture = _salesRepository.fetchSalesHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _historyFuture = _salesRepository.fetchSalesHistory();
    });
  }

  Future<void> _openReceiptDialog(
    BuildContext context,
    Map<String, dynamic> sale,
  ) async {
    final saleId = sale['id']?.toString();
    if (saleId == null || saleId.isEmpty) {
      return;
    }

    final shouldReload = await SaleReceiptDialog.show(context, sale: sale);

    if (shouldReload != true) {
      return;
    }

    await _reload();
  }

  Future<void> _confirmDeleteSale(
    BuildContext context,
    Map<String, dynamic> sale,
  ) async {
    final saleId = sale['id']?.toString();
    if (saleId == null || saleId.isEmpty) {
      return;
    }

    final displayId = saleId.length > 8 ? saleId.substring(0, 8) : saleId;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Sale'),
          content: Text('Delete Sale #$displayId from history only?'),
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

    try {
      await _salesRepository.deleteSale(saleId);
      await _reload();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale deleted from history.')),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete sale: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load sales history: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: _reload, child: const Text('Retry')),
              ],
            ),
          );
        }

        final history = snapshot.data ?? [];
        if (history.isEmpty) {
          return const Center(
            child: Text(
              'No sales processed yet.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          );
        }

        final filteredHistory = _filterHistory(history);

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search by sale ID, customer, or date...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Showing ${filteredHistory.length} of ${history.length} sales',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              ...filteredHistory.map((sale) {
                final createdAt = _formatDateTime(
                  sale['createdAt']?.toString(),
                );
                final saleId = sale['id']?.toString() ?? '';
                final displayId = saleId.length > 8
                    ? saleId.substring(0, 8)
                    : saleId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sale #$displayId',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Customer: ${sale['customerName']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '$createdAt - ${sale['itemCount']} items - ${sale['unitCount']} units',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'RS ${(sale['total'] as num).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton.icon(
                              onPressed: saleId.isEmpty
                                  ? null
                                  : () => _openReceiptDialog(context, sale),
                              icon: const Icon(Icons.receipt_long, size: 18),
                              label: const Text('Print Receipt'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: saleId.isEmpty
                                  ? null
                                  : () => _confirmDeleteSale(context, sale),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: Colors.red.shade400,
                              tooltip: 'Delete sale history only',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (filteredHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No matching sales found.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterHistory(
    List<Map<String, dynamic>> history,
  ) {
    if (_searchQuery.isEmpty) {
      return history;
    }

    return history.where((sale) {
      final id = (sale['id'] ?? '').toString().toLowerCase();
      final customer = (sale['customerName'] ?? '').toString().toLowerCase();
      final createdAt = (sale['createdAt'] ?? '').toString().toLowerCase();
      return id.contains(_searchQuery) ||
          customer.contains(_searchQuery) ||
          createdAt.contains(_searchQuery);
    }).toList();
  }

  String _formatDateTime(String? isoValue) {
    if (isoValue == null || isoValue.isEmpty) {
      return 'Unknown time';
    }

    final parsed = DateTime.tryParse(isoValue)?.toLocal();
    if (parsed == null) {
      return isoValue;
    }

    final y = parsed.year.toString().padLeft(4, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    final hh = parsed.hour.toString().padLeft(2, '0');
    final mm = parsed.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Analytics & Reports Module Coming Soon",
        style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsView();
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  final SalesRepository _salesRepository = SalesRepository();
  final InventoryRepository _inventoryRepository = InventoryRepository();
  bool _isDeletingHistory = false;
  bool _isDeletingDashboardData = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danger Zone',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'These actions permanently remove data from your system.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _buildDangerCard(
            title: 'Delete All Sales History',
            description:
                'Removes every sales record and its items from the History screen.',
            buttonLabel: _isDeletingHistory
                ? 'Deleting...'
                : 'Delete Sales History',
            onPressed: _isDeletingHistory
                ? null
                : () => _confirmDeleteAllHistory(context),
          ),
          const SizedBox(height: 16),
          _buildDangerCard(
            title: 'Delete All Dashboard Data',
            description:
                'Removes all sales history and all products used to populate the dashboard.',
            buttonLabel: _isDeletingDashboardData
                ? 'Deleting...'
                : 'Delete Dashboard Data',
            onPressed: _isDeletingDashboardData
                ? null
                : () => _confirmDeleteAllDashboardData(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerCard({
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3D1D1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAllHistory(BuildContext context) async {
    final shouldDelete = await _showConfirmationDialog(
      context: context,
      title: 'Delete All Sales History',
      message:
          'Are you sure you want to delete all sales records from history? This action cannot be undone.',
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isDeletingHistory = true;
    });

    try {
      await _salesRepository.deleteAllSalesHistory();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All sales history has been deleted.')),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete sales history: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingHistory = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteAllDashboardData(BuildContext context) async {
    final shouldDelete = await _showConfirmationDialog(
      context: context,
      title: 'Delete All Dashboard Data',
      message:
          'Are you sure you want to delete all dashboard data? This will remove all sales history and all products, and it cannot be undone.',
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isDeletingDashboardData = true;
    });

    try {
      await _salesRepository.deleteAllSalesHistory();
      await _inventoryRepository.deleteAllProducts();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All dashboard data has been deleted.')),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete dashboard data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingDashboardData = false;
        });
      }
    }
  }

  Future<bool?> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
