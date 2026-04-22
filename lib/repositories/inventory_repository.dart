import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryRepository {
  final SupabaseClient _client;

  InventoryRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final rows = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((row) => _mapProductRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    await _client.from('products').insert(_toDatabasePayload(product));
  }

  Future<void> updateProduct(String id, Map<String, dynamic> product) async {
    await _client
        .from('products')
        .update(_toDatabasePayload(product))
        .eq('id', id);
  }

  Future<List<String>> fetchCategories() async {
    try {
      final rows = await _client
          .from('categories')
          .select('name')
          .order('name', ascending: true);

      return (rows as List<dynamic>)
          .map((row) => (row as Map<String, dynamic>)['name']?.toString() ?? '')
          .where((name) => name.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    } catch (_) {
      final productRows = await _client.from('products').select('category');
      return (productRows as List<dynamic>)
          .map(
            (row) =>
                (row as Map<String, dynamic>)['category']?.toString() ?? '',
          )
          .where((name) => name.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    }
  }

  Future<void> addCategory(String name) async {
    await _client.from('categories').upsert({'name': name.trim()});
  }

  Future<void> deleteAllProducts() async {
    final rows = await _client.from('products').select('id');
    final productIds = (rows as List<dynamic>)
        .map(
          (dynamic row) =>
              (row as Map<String, dynamic>)['id']?.toString() ?? '',
        )
        .where((id) => id.isNotEmpty)
        .toList();

    if (productIds.isEmpty) {
      return;
    }

    await _client.from('products').delete().inFilter('id', productIds);
  }

  Map<String, dynamic> _mapProductRow(Map<String, dynamic> row) {
    final stock = _toInt(row['stock']);
    final maxStock = _toInt(row['max_stock']);

    return {
      'id': row['id'],
      'name': row['name'] ?? '',
      'sku': row['sku'] ?? '',
      'category': row['category'] ?? '',
      'purchase': _toDouble(row['purchase_price']),
      'shop': _toDouble(row['shop_price']),
      'retail': _toDouble(row['retail_price']),
      'stock': stock,
      'maxStock': maxStock,
      'isLow': stock <= 20,
    };
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> _toDatabasePayload(Map<String, dynamic> product) {
    return {
      'name': (product['name'] ?? '').toString().trim(),
      'sku': (product['sku'] ?? '').toString().trim(),
      'category': (product['category'] ?? '').toString().trim(),
      'purchase_price': _toDouble(product['purchase']),
      'shop_price': _toDouble(product['shop']),
      'retail_price': _toDouble(product['retail']),
      'stock': _toInt(product['stock']),
      'max_stock': _toInt(product['maxStock']),
    };
  }
}
