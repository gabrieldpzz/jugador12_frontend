import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/size_option.dart';
import '../services/product_service.dart';
import '../services/local_cart.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductDetails? _details;           // cache o fresh
  Future<ProductDetails>? _future;    // para manejo de estado
  SizeOption? _selected;

  @override
  void initState() {
    super.initState();
    _future = _loadCacheThenRefresh();
  }

  Future<ProductDetails> _loadCacheThenRefresh() async {
    final cached = await ProductService.getDetailsCached(widget.product.id);
    if (mounted) setState(() => _details = cached);

    try {
      final fresh = await ProductService.refreshDetails(widget.product.id);
      final changed = _hasChanged(_details, fresh);
      if (changed && mounted) setState(() => _details = fresh);
    } catch (_) {/* ignorar */}
    return _details!;
  }

  bool _hasChanged(ProductDetails? a, ProductDetails b) {
    if (a == null) return true;
    if (a.description != b.description) return true;
    if (a.sizes.length != b.sizes.length) return true;
    for (int i = 0; i < a.sizes.length; i++) {
      final x = a.sizes[i], y = b.sizes[i];
      if (x.id != y.id || x.stock != y.stock || x.label != y.label || x.type != y.type) {
        return true;
      }
    }
    return false;
  }

  Future<void> _pullToRefresh() async {
    final fresh = await ProductService.refreshDetails(widget.product.id);
    if (mounted) setState(() => _details = fresh);
  }

  Future<void> _handleAddToCart() async {
    if (_selected == null) return;

    final p = widget.product;
    final size = _selected!;
    final image = (p.images.isNotEmpty ? p.images.first : p.imageUrl);

    await LocalCart().addOrIncrease(CartItem(
      productId: p.id,
      name: p.name,
      imageUrl: image,
      price: p.price,
      sizeId: size.id,
      sizeLabel: size.label,
      qty: 1,
    ));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Añadido: ${p.name} - talla ${size.label}')),
    );

    // Ir al carrito (opcional)
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final details = _details;

    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator.adaptive(
        onRefresh: _pullToRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Carrusel de imágenes
            SliverToBoxAdapter(
              child: _ImagesCarousel(images: widget.product.images.isNotEmpty
                  ? widget.product.images
                  : [widget.product.imageUrl]),
            ),

            // Nombre y precio
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  '\$${p.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),

            // Tallas + descripción
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: (details == null)
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _buildSizesAndDescription(details),
              ),
            ),
          ],
        ),
      ),

      // Botón
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: (_selected != null) ? _handleAddToCart : null,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('AGREGAR AL CARRITO'),
        ),
      ),
    );
  }

  Widget _buildSizesAndDescription(ProductDetails d) {
    final sizes = d.sizes;
    final description = d.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sizes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Sin tallas disponibles'),
          )
        else
          Wrap(
            spacing: 10, runSpacing: 10,
            children: sizes.map((s) {
              final disabled = s.stock <= 0;
              final selected = _selected?.id == s.id;
              return ChoiceChip(
                label: Text(s.label),
                selected: selected,
                onSelected: disabled ? null : (v) => setState(() => _selected = v ? s : null),
                avatar: disabled ? const Icon(Icons.block, size: 16) : null,
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : null,
                  decoration: disabled ? TextDecoration.lineThrough : null,
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                disabledColor: Theme.of(context).disabledColor.withOpacity(.15),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                  ),
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 20),

        const Text('Descripción', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(color: Colors.black54, height: 1.3)),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ImagesCarousel extends StatefulWidget {
  final List<String> images;
  const _ImagesCarousel({required this.images});

  @override
  State<_ImagesCarousel> createState() => _ImagesCarouselState();
}

class _ImagesCarouselState extends State<_ImagesCarousel> {
  final PageController _pc = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imgs = widget.images.where((e) => e.isNotEmpty).toList();
    if (imgs.isEmpty) {
      return AspectRatio(aspectRatio: 3/4, child: Container(color: Colors.black12));
    }
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3/4,
          child: PageView.builder(
            controller: _pc,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: imgs.length,
            itemBuilder: (_, i) => Image.network(imgs[i], fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(imgs.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
