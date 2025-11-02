import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_api.dart';
import 'otp_verify_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pass = _pass.text;

    if (name.isEmpty || email.isEmpty || pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre, correo y una contraseña (mín. 6).')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      await cred.user?.updateDisplayName(name);

      // Envía OTP vía backend
      await AuthApi.sendOtp(email);

      if (!mounted) return;
      // Navega a pantalla de verificación de OTP
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OtpVerifyPage(email: email)),
      );
    } on FirebaseAuthException catch (e) {
      final msg = e.message ?? 'Error al registrar';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
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
                    onPressed: _loading ? null : _createAccount,
                    child: _loading
                      ? const SizedBox(height: 16, width:16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Crear cuenta'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
