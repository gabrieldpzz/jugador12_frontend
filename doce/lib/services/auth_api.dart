import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env.dart';

class AuthApi {
  static Future<void> sendOtp(String email) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/api/auth/send-otp');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (res.statusCode != 200) {
      throw Exception('Error al enviar OTP: ${res.statusCode}');
    }
  }

  static Future<bool> verifyOtp(String email, String code) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/api/auth/verify-otp');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );
    if (res.statusCode == 200) {
      // Puedes validar body si tu API devuelve {"valid":true}
      return true;
    }
    return false;
  }
}
