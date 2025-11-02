import 'package:flutter/material.dart';
import '../services/otp_service.dart';

Future<bool> showOtpSheet(BuildContext context, OtpService service) async {
  final controller = TextEditingController();

  await service.sendOtp();

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16, top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Verificación por correo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Revisa tu correo y escribe el código de 6 dígitos.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Código',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final ok = await service.verifyOtp(controller.text.trim());
                      if (ok) {
                        Navigator.pop(ctx, true);
                      } else {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Código inválido o expirado')),
                        );
                      }
                    },
                    child: const Text('Confirmar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () async {
                await service.sendOtp();
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Hemos reenviado el código')),
                );
              },
              child: const Text('Reenviar código'),
            ),
            const SizedBox(height: 6),
          ],
        ),
      );
    },
  );

  return result == true;
}
