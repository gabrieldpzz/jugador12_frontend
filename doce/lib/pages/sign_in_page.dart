import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../env.dart';
import 'otp_verify_page.dart';
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _sendOtpDetailed(String email) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/api/auth/send-otp');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (res.statusCode != 200) {
      // Puede venir 429 o 500; lo convertimos en error legible
      throw Exception('OTP error ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final pass  = _pass.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa correo y contraseña')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // 1) Login Firebase (para tu sesión cliente)
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // 2) Consultar tu API OTP:
      //    - si already_verified == true -> pasar directo
      //    - si no -> se ha enviado OTP y mandamos a verificar
      final otpResp = await _sendOtpDetailed(email);
      final already = (otpResp['already_verified'] == true);

      if (!mounted) return;
      if (already) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión iniciada')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Te enviamos un código para verificar tu correo')),
        );
        // Ir a verificación OTP
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OtpVerifyPage(email: email)),
        );
        if (!mounted) return;
        Navigator.pop(context, true); // volver al Home si se verificó
      }
    } on FirebaseAuthException catch (e) {
      final msg = e.message ?? 'Error de autenticación';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToSignUp() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _loading ? null : _signIn,
                    child: _loading
                        ? const SizedBox(height: 16, width:16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Entrar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading ? null : _goToSignUp,
              child: const Text('Crear cuenta'),
            )
          ],
        ),
      ),
    );
  }
}
