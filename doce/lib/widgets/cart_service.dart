import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class CartService {
  final ApiClient _api;
  CartService(this._api);

  Future<bool> addItem({
    required int productId,
    required int sizeId,
    int quantity = 1,
    required Future<bool> Function() ensureOtp, // función que abre OTP si hace falta
  }) async {
    http.Response res = await _api.postJson(
      '/api/cart/items',
      body: {'product_id': productId, 'size_id': sizeId, 'qty': quantity},
      onRequireOtp: () async {
        final ok = await ensureOtp();
        if (!ok) {
          throw Exception('OTP requerido y no verificado');
        }
      },
    );

    // Si tras OTP todavía no fue 200, reintenta una sola vez:
    if (res.statusCode == 403) {
      final ok = await ensureOtp();
      if (!ok) return false;
      res = await _api.postJson(
        '/api/cart/items',
        body: {'product_id': productId, 'size_id': sizeId, 'qty': quantity},
      );
    }

    return res.statusCode == 200 || res.statusCode == 201;
  }
}
