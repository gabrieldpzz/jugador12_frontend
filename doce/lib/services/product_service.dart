import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../env.dart';
import '../models/product.dart';
import '../models/size_option.dart';
import 'cache_service.dart';

class ProductDetails {
  final List<SizeOption> sizes;
  final String description;
  final bool fromCache;
  const ProductDetails({
    required this.sizes,
    required this.description,
    required this.fromCache,
  });
}

class ProductService {
  static const _timeout = Duration(seconds: 8);

  // ----- LISTADO -----
  static Future<List<Product>> fetch({int limit = 6}) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/api/products?limit=$limit');
    try {
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      final body = json.decode(res.body);
      final list = (body is List) ? body : (body['data'] as List);
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      throw Exception('Sin conexión con la API (${uri.host})');
    } on FormatException catch (e) {
      throw Exception('JSON inválido: $e');
    }
  }

  // ----- DETALLE (cache-first + bg refresh implícito) -----
  static Future<ProductDetails> getDetailsCached(int productId) async {
    final cached = await CacheService.readProductDetails(productId);
    if (cached != null) {
      // refresco en segundo plano (no bloquea UI)
      _refreshDetailsInBackground(productId);
      final sizes = (cached['sizes'] as List<dynamic>)
          .map((e) => SizeOption.fromJson(e as Map<String, dynamic>)).toList();
      final desc = (cached['description'] as String?) ?? 'Sin descripción';
      return ProductDetails(sizes: sizes, description: desc, fromCache: true);
    }

    // sin cache: trae de red y persiste
    final fresh = await _fetchDetailsFromApi(productId);
    await CacheService.writeProductDetails(
      productId: productId,
      sizes: fresh.sizes.map((s) => {
        'id': s.id, 'type': s.type, 'label': s.label, 'stock': s.stock
      }).toList(),
      description: fresh.description,
    );
    return ProductDetails(sizes: fresh.sizes, description: fresh.description, fromCache: false);
  }

  // → MÉTODO QUE FALTABA: actualiza desde la API y guarda cache
  static Future<ProductDetails> refreshDetails(int productId) async {
    final fresh = await _fetchDetailsFromApi(productId);
    await CacheService.writeProductDetails(
      productId: productId,
      sizes: fresh.sizes.map((s) => {
        'id': s.id, 'type': s.type, 'label': s.label, 'stock': s.stock
      }).toList(),
      description: fresh.description,
    );
    return fresh;
  }

  // ----- Privados -----
  static Future<ProductDetails> _fetchDetailsFromApi(int productId) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/api/products/$productId');
    final res = await http.get(uri).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    final sizes = (data['sizes'] as List<dynamic>)
        .map((e) => SizeOption.fromJson(e as Map<String, dynamic>)).toList();
    final desc = (data['description'] ?? '').toString().trim();
    return ProductDetails(
      sizes: sizes,
      description: desc.isEmpty ? 'Sin descripción' : desc,
      fromCache: false,
    );
  }

  static void _refreshDetailsInBackground(int productId) async {
    try {
      final fresh = await _fetchDetailsFromApi(productId);
      await CacheService.writeProductDetails(
        productId: productId,
        sizes: fresh.sizes.map((s) => {
          'id': s.id, 'type': s.type, 'label': s.label, 'stock': s.stock
        }).toList(),
        description: fresh.description,
      );
    } catch (_) {/* best-effort */}
  }
}
