import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../env.dart';

typedef OtpHandler = Future<void> Function(); // función que mostrará el UI de OTP

class ApiClient {
  final _auth = FirebaseAuth.instance;
  final String base = Env.apiBaseUrl;

  Future<http.Response> postJson(
    String path, {
    Map<String, dynamic>? body,
    OtpHandler? onRequireOtp,
  }) async {
    final token = await _ensureIdToken();
    final res = await http.post(
      Uri.parse('$base$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body ?? {}),
    );

    // Si el backend exige OTP
    if (res.statusCode == 403) {
      final data = _safeJson(res.body);
      if (data['requires_otp'] == true && onRequireOtp != null) {
        await onRequireOtp(); // abre UI para OTP y verifica
      }
    }

    return res;
  }

  Future<http.Response> get(
    String path, {
    OtpHandler? onRequireOtp,
  }) async {
    final token = await _ensureIdToken();
    final res = await http.get(
      Uri.parse('$base$path'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 403) {
      final data = _safeJson(res.body);
      if (data['requires_otp'] == true && onRequireOtp != null) {
        await onRequireOtp();
      }
    }

    return res;
  }

  Future<String> _ensureIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }
    return await user.getIdToken(true);
  }

  Map<String, dynamic> _safeJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
    }
}
