import 'package:supabase_flutter/supabase_flutter.dart';

class SalesRepository {
  final SupabaseClient _client;

  SalesRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPosProducts() async {
    final rows = await _client
        .from('products')
        .select('id, name, sku, retail_price, stock')
        .order('name', ascending: true);

    return (rows as List<dynamic>).map((dynamic row) {
      final data = row as Map<String, dynamic>;
      final stock = _toInt(data['stock']);

      return {
        'id': data['id']?.toString() ?? '',
        'name': data['name'] ?? '',
        'sku': data['sku'] ?? '',
        'price': _toDouble(data['retail_price']),
        'stock': stock,
        'stockStatus': stock <= 0
            ? 'OUT OF STOCK'
            : (stock <= 20 ? 'LOW STOCK' : 'IN STOCK'),
      };
    }).toList();
  }

  Future<void> createSale({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double surcharge,
    required double total,
    String? customerName,
  }) async {
    final saleResponse = await _client
        .from('sales')
        .insert({
          'customer_name': customerName?.trim().isEmpty ?? true
              ? null
              : customerName!.trim(),
          'subtotal': subtotal,
          'tax': tax,
          'surcharge': surcharge,
          'total': total,
        })
        .select('id')
        .single();

    final saleId = saleResponse['id']?.toString();
    if (saleId == null || saleId.isEmpty) {
      throw StateError('Could not create sale record.');
    }

    final saleItemsPayload = items.map((item) {
      return {
        'sale_id': saleId,
        'product_id': item['productId'],
        'product_name': item['name'],
        'sku': item['sku'],
        'unit_price': item['unitPrice'],
        'quantity': item['quantity'],
        'line_total': item['lineTotal'],
      };
    }).toList();

    await _client.from('sale_items').insert(saleItemsPayload);

    for (final item in items) {
      final productId = item['productId']?.toString();
      final quantity = _toInt(item['quantity']);
      if (productId == null || productId.isEmpty || quantity <= 0) {
        continue;
      }

      final productRow = await _client
          .from('products')
          .select('stock')
          .eq('id', productId)
          .single();

      final currentStock = _toInt(productRow['stock']);
      final nextStock = (currentStock - quantity).clamp(0, 1 << 31);

      await _client
          .from('products')
          .update({'stock': nextStock})
          .eq('id', productId);
    }
  }

  Future<List<Map<String, dynamic>>> fetchSalesHistory() async {
    final salesRows = await _client
        .from('sales')
        .select(
          'id, customer_name, subtotal, tax, surcharge, total, created_at',
        )
        .order('created_at', ascending: false);

    final saleItemsRows = await _client
        .from('sale_items')
        .select(
          'sale_id, product_id, product_name, sku, unit_price, quantity, line_total',
        );

    final Map<String, int> itemCountBySale = {};
    final Map<String, int> unitCountBySale = {};
    final Map<String, List<Map<String, dynamic>>> detailsBySale = {};

    for (final dynamic row in saleItemsRows as List<dynamic>) {
      final data = row as Map<String, dynamic>;
      final saleId = data['sale_id']?.toString() ?? '';
      if (saleId.isEmpty) continue;
      itemCountBySale[saleId] = (itemCountBySale[saleId] ?? 0) + 1;
      unitCountBySale[saleId] =
          (unitCountBySale[saleId] ?? 0) + _toInt(data['quantity']);
      detailsBySale.putIfAbsent(saleId, () => []).add({
        'productId': data['product_id']?.toString() ?? '',
        'productName': data['product_name']?.toString() ?? 'Unnamed Product',
        'sku': data['sku']?.toString() ?? '',
        'unitPrice': _toDouble(data['unit_price']),
        'quantity': _toInt(data['quantity']),
        'lineTotal': _toDouble(data['line_total']),
      });
    }

    return (salesRows as List<dynamic>).map((dynamic row) {
      final data = row as Map<String, dynamic>;
      final saleId = data['id']?.toString() ?? '';
      return {
        'id': saleId,
        'customerName': data['customer_name']?.toString() ?? 'Walk-in Customer',
        'subtotal': _toDouble(data['subtotal']),
        'tax': _toDouble(data['tax']),
        'surcharge': _toDouble(data['surcharge']),
        'total': _toDouble(data['total']),
        'itemCount': itemCountBySale[saleId] ?? 0,
        'unitCount': unitCountBySale[saleId] ?? 0,
        'details': detailsBySale[saleId] ?? const <Map<String, dynamic>>[],
        'createdAt': data['created_at']?.toString() ?? '',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchSaleItems() async {
    final rows = await _client
        .from('sale_items')
        .select(
          'product_id, product_name, sku, quantity, line_total, sales!inner(created_at)',
        );

    return (rows as List<dynamic>).map((dynamic row) {
      final data = row as Map<String, dynamic>;
      final saleData = data['sales'];
      final sale = saleData is Map<String, dynamic>
          ? saleData
          : saleData is List &&
                saleData.isNotEmpty &&
                saleData.first is Map<String, dynamic>
          ? saleData.first as Map<String, dynamic>
          : const <String, dynamic>{};

      return {
        'productId': data['product_id']?.toString() ?? '',
        'productName': data['product_name']?.toString() ?? '',
        'sku': data['sku']?.toString() ?? '',
        'quantity': _toInt(data['quantity']),
        'lineTotal': _toDouble(data['line_total']),
        'createdAt': sale['created_at']?.toString() ?? '',
      };
    }).toList();
  }

  Future<void> deleteSale(String saleId) async {
    await _client.from('sale_items').delete().eq('sale_id', saleId);
    await _client.from('sales').delete().eq('id', saleId);
  }

  Future<void> voidSale(String saleId) async {
    final items = await _client
        .from('sale_items')
        .select('product_id, quantity')
        .eq('sale_id', saleId);

    for (final dynamic row in items as List<dynamic>) {
      final data = row as Map<String, dynamic>;
      final productId = data['product_id']?.toString() ?? '';
      final quantity = _toInt(data['quantity']);

      if (productId.isEmpty || quantity <= 0) {
        continue;
      }

      final productRow = await _client
          .from('products')
          .select('stock')
          .eq('id', productId)
          .maybeSingle();

      final currentStock = _toInt(productRow?['stock']);
      final nextStock = currentStock + quantity;

      await _client
          .from('products')
          .update({'stock': nextStock})
          .eq('id', productId);
    }

    await _client.from('sale_items').delete().eq('sale_id', saleId);
    await _client.from('sales').delete().eq('id', saleId);
  }

  Future<void> deleteAllSalesHistory() async {
    final salesRows = await _client.from('sales').select('id');
    final saleIds = (salesRows as List<dynamic>)
        .map(
          (dynamic row) =>
              (row as Map<String, dynamic>)['id']?.toString() ?? '',
        )
        .where((id) => id.isNotEmpty)
        .toList();

    if (saleIds.isEmpty) {
      return;
    }

    await _client.from('sale_items').delete().inFilter('sale_id', saleIds);
    await _client.from('sales').delete().inFilter('id', saleIds);
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
}
