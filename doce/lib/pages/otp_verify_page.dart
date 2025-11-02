import 'package:flutter/material.dart';
import '../services/auth_api.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;
  const OtpVerifyPage({super.key, required this.email});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _code = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código OTP (6 dígitos).')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final ok = await AuthApi.verifyOtp(widget.email, code);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo verificado')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código inválido')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verificando OTP: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _loading = true);
    try {
      await AuthApi.sendOtp(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nuevo código enviado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo reenviar: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email;
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar correo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hemos enviado un código a:', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              maxLength: 6,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                counterText: '',
                labelText: 'Código OTP',
                hintText: 'Ingresa 6 dígitos',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _loading ? null : _verify,
                    child: _loading
                      ? const SizedBox(height: 16, width:16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Verificar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _loading ? null : _resend,
                child: const Text('Reenviar código'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
