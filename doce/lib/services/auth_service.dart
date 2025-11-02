import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../env.dart';

class AuthService {
  static final _fa = FirebaseAuth.instance;

  // Login con Firebase
  static Future<UserCredential> signIn(String email, String password) {
    return _fa.signInWithEmailAndPassword(email: email, password: password);
  }

  // Registro con Firebase
  static Future<UserCredential> signUp(String email, String password) {
    return _fa.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Pide OTP al backend
  static Future<SendOtpResult> sendOtp(String email) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/api/auth/send-otp');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}));

    if (res.statusCode == 200) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final already = (j['already_verified'] ?? false) == true;
      return SendOtpResult(ok: true, alreadyVerified: already, message: j['message']?.toString() ?? '');
    }

    if (res.statusCode == 429) {
      final j = jsonDecode(res.body);
      return SendOtpResult(ok: false, rateLimited: true, message: j['message']?.toString() ?? 'Espera un momento.');
    }

    final msg = _safeMessage(res.body);
    return SendOtpResult(ok: false, message: msg);
  }

  // Verifica OTP
  static Future<bool> verifyOtp(String email, String code) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/api/auth/verify-otp');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}));

    if (res.statusCode == 200) return true;
    return false;
  }

  static String _safeMessage(String body) {
    try {
      final j = jsonDecode(body);
      return j['message']?.toString() ?? 'Error';
    } catch (_) {
      return 'Error';
    }
  }
}

class SendOtpResult {
  final bool ok;
  final bool alreadyVerified;
  final bool rateLimited;
  final String message;

  SendOtpResult({
    required this.ok,
    this.alreadyVerified = false,
    this.rateLimited = false,
    this.message = '',
  });
}
