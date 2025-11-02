import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../env.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/category_strip.dart';
import '../widgets/product_card.dart';

// nuevas páginas
import 'cart_page.dart';
import 'sign_in_page.dart';

/// Modelo mínimo para banners
class _BannerItem {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final int order;

  _BannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.order,
  });

  factory _BannerItem.fromJson(Map<String, dynamic> j) => _BannerItem(
        id: j['id'] as int,
        title: (j['title'] ?? '') as String,
        subtitle: (j['subtitle'] ?? '') as String,
        imageUrl: j['image_url'] as String,
        order: j['order'] as int,
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<_BannerItem>> _futureBanners;
  late Future<List<Product>> _futureProducts;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _futureBanners = _fetchBanners(limit: 2);
    _futureProducts = ProductService.fetch(limit: 6);
  }

  Future<void> _reload() async {
    setState(() {
      _futureBanners = _fetchBanners(limit: 2);
      _futureProducts = ProductService.fetch(limit: 6);
    });
    await Future.wait([_futureBanners, _futureProducts]);
  }

  // ---- BANNERS ----
  Future<List<_BannerItem>> _fetchBanners({int limit = 2}) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/api/banners?limit=$limit');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al cargar banners');
    }
    final data = json.decode(res.body) as List<dynamic>;
    return data
        .map((e) => _BannerItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Categorías demo
  List<Map<String, dynamic>> get _mockCategories => [
        {'name': 'Actual', 'icon': Icons.checkroom},
        {'name': 'Retro', 'icon': Icons.history},
        {
          'name': 'Barcelona',
          'logo_url':
              'https://upload.wikimedia.org/wikipedia/sco/thumb/4/47/FC_Barcelona_%28crest%29.svg/1010px-FC_Barcelona_%28crest%29.svg.png'
        },
        {
          'name': 'Real Madrid',
          'logo_url':
              'https://upload.wikimedia.org/wikipedia/sco/thumb/5/56/Real_Madrid_CF.svg/1464px-Real_Madrid_CF.svg.png'
        },
        {
          'name': 'Argentina',
          'logo_url':
              'https://upload.wikimedia.org/wikipedia/fr/thumb/c/c4/Logo_de_l%27%C3%A9quipe_d%27Argentine_de_football.svg/692px-Logo_de_l%27%C3%A9quipe_d%27Argentine_de_football.svg.png'
        },
        {
          'name': 'España',
          'logo_url':
              'https://upload.wikimedia.org/wikipedia/commons/6/6a/Escudo_selecci%C3%B3n_espa%C3%B1ola.png'
        },
      ];

  void _onNavTap(int i) async {
    setState(() => _navIndex = i);
    switch (i) {
      case 0:
        break;
      case 1:
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favoritos (próximamente)')),
        );
        break;
      case 2:
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CartPage()),
        );
        break;
      case 3:
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SignInPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jugador12'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage()));
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Carrito'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: _reload,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: TextField(
                  readOnly: true,
                  onTap: () {},
                  decoration: InputDecoration(
                    hintText: 'Buscar producto',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: FutureBuilder<List<_BannerItem>>(
                  future: _futureBanners,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const _BannerSkeleton();
                    }
                    if (snap.hasError) {
                      return const _BannerError(msg: 'Error al cargar banners');
                    }
                    final items = snap.data ?? const <_BannerItem>[];
                    if (items.isEmpty) {
                      return const _BannerError(msg: 'Sin banners');
                    }
                    return _BannerCarousel(items: items);
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: CategoryStrip(items: _mockCategories)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Productos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('Ver más')),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              sliver: FutureBuilder<List<Product>>(
                future: _futureProducts,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                  if (snap.hasError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Error al cargar productos',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    );
                  }
                  final products = (snap.data ?? const <Product>[]).take(6).toList();
                  for (final p in products) {
                    ProductService.getDetailsCached(p.id);
                  }
                  if (products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Sin productos'),
                      ),
                    );
                  }
                  return SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: .72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) => ProductCard(p: products[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reload,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// ===== Banners helpers =====
class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton();

  @override
  Widget build(BuildContext context) => Container(
        height: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
}

class _BannerError extends StatelessWidget {
  final String msg;
  const _BannerError({required this.msg});

  @override
  Widget build(BuildContext context) => Container(
        height: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          msg,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
}

class _BannerCarousel extends StatefulWidget {
  final List<_BannerItem> items;
  const _BannerCarousel({required this.items});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final items = widget.items;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: ClipRRect(
            borderRadius: radius,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final b = items[i];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      b.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(.05),
                            Colors.black.withOpacity(.55),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 14,
                      right: 16,
                      child: Text(
                        b.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 14,
                      right: 16,
                      child: Text(
                        b.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ],
    );
  }
}
