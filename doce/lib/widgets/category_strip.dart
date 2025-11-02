import 'package:flutter/material.dart';

/// Soporta:
/// {'name': 'Barcelona', 'logo_url': 'https://...png'}
/// {'name': 'Actual', 'icon': Icons.checkroom}
class CategoryStrip extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double boxSize;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const CategoryStrip({
    super.key,
    required this.items,
    this.boxSize = 60,
    this.radius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.primaryContainer;
    final fg = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: boxSize + 26 + 8,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (_, i) {
          final item = items[i];
          final name = (item['name'] ?? '') as String;
          final logoUrl = item['logo_url'] as String?;
          final iconData = item['icon'] as IconData?;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _CategoryContent(
                        logoUrl: logoUrl,
                        iconData: iconData,
                        color: fg,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: boxSize + 6,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryContent extends StatelessWidget {
  final String? logoUrl;
  final IconData? iconData;
  final Color color;

  const _CategoryContent({this.logoUrl, this.iconData, required this.color});

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return FittedBox(
        fit: BoxFit.contain,
        child: Image.network(
          logoUrl!,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.broken_image_outlined, color: color, size: 28),
        ),
      );
    }
    return Icon(iconData ?? Icons.circle, size: 28, color: color);
  }
}
