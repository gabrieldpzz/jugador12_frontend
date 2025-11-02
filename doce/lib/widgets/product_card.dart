import 'package:flutter/material.dart';
import '../models/product.dart';
import '../pages/product_detail_page.dart';

class ProductCard extends StatelessWidget {
  final Product p;
  const ProductCard({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 1, child: Image.network(p.imageUrl, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                '\$${p.price.toStringAsFixed(2)}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
