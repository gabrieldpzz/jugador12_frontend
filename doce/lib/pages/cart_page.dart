import 'package:flutter/material.dart';
import '../services/local_cart.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<CartItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = LocalCart().items();
  }

  Future<void> _reload() async {
    final items = await LocalCart().items();
    setState(() {
      _future = Future.value(items);
    });
  }

  Future<void> _inc(CartItem it) async {
    await LocalCart().updateQty(it.productId, it.sizeId, it.qty + 1);
    await _reload();
  }

  Future<void> _dec(CartItem it) async {
    await LocalCart().updateQty(it.productId, it.sizeId, it.qty - 1);
    await _reload();
  }

  Future<void> _remove(CartItem it) async {
    await LocalCart().remove(it.productId, it.sizeId);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: FutureBuilder<List<CartItem>>(
        future: _future,
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Tu carrito está vacío'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: it.imageUrl.isNotEmpty
                            ? Image.network(it.imageUrl, width: 56, height: 56, fit: BoxFit.cover)
                            : Container(width:56, height:56, color: Colors.black12),
                      ),
                      title: Text(it.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('Talla ${it.sizeLabel} • \$${it.price.toStringAsFixed(2)}'),
                      trailing: SizedBox(
                        width: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () => _dec(it),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${it.qty}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            IconButton(
                              onPressed: () => _inc(it),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            IconButton(
                              onPressed: () => _remove(it),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              FutureBuilder<double>(
                future: LocalCart().total(),
                builder: (ctx, snap2) {
                  final total = (snap2.data ?? 0.0);
                  return SafeArea(
                    minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Total: \$${total.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                        FilledButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Checkout (próximamente)')),
                            );
                          },
                          child: const Text('PAGAR'),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
