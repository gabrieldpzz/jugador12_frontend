import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class OtpService {
  final ApiClient _api;

  OtpService(this._api);

  Future<bool> sendOtp() async {
    final res = await _api.postJson('/api/auth/send-otp');
    return res.statusCode == 200;
  }

  Future<bool> verifyOtp(String code) async {
    final res = await _api.postJson('/api/auth/verify-otp', body: {'code': code});
    if (res.statusCode == 200) return true;

    // Manejo opcional de errores específicos:
    try {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['error'] == 'invalid_code') return false;
      if (data['error'] == 'expired_code') return false;
    } catch (_) {}
    return false;
  }
}
