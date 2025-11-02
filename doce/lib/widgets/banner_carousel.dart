import 'package:flutter/material.dart';
import '../models/banner_model.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerModel> items;
  const BannerCarousel({super.key, required this.items});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final radius = BorderRadius.circular(16);

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
                    Image.network(b.imageUrl, fit: BoxFit.cover),
                    Container(decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(.05), Colors.black.withOpacity(.55)],
                      ),
                    )),
                    Positioned(
                      left: 16, top: 14,
                      child: Text(
                        b.subtitle,
                        style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Positioned(
                      left: 16, bottom: 14,
                      child: Text(
                        b.title,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
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
                color: active ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ],
    );
  }
}
