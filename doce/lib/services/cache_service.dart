import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _prefix = 'product_details_';
  static const _ttlSeconds = 3600; // 1 hora (puedes ajustar)

  static Future<Map<String, dynamic>?> readProductDetails(int productId) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('$_prefix$productId');
    if (raw == null) return null;

    final obj = json.decode(raw) as Map<String, dynamic>;
    final ts = (obj['ts'] as int? ?? 0);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final fresh = (now - ts) <= _ttlSeconds; // true si está dentro del TTL

    return {
      'sizes': obj['sizes'],
      'description': obj['description'],
      'fresh': fresh,
    };
  }

  static Future<void> writeProductDetails({
    required int productId,
    required List<Map<String, dynamic>> sizes,
    required String description,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payload = {
      'sizes': sizes,
      'description': description,
      'ts': now,
    };
    await sp.setString('$_prefix$productId', json.encode(payload));
  }
}
