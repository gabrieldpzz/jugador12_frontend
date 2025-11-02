import 'package:flutter/material.dart';

class PromoBanner extends StatefulWidget {
  final List<String> images;
  const PromoBanner({super.key, required this.images});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final _controller = PageController(viewportFraction: 1);
  int _index = 0;

  @override
  Widget build(BuildContext context) {
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
              itemCount: widget.images.length,
              itemBuilder: (_, i) => Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.images[i], fit: BoxFit.cover),
                  Positioned(
                    left: 16, top: 16,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Text('Cashback 20%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (i) {
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
