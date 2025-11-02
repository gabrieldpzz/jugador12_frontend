class Product {
  final int id;
  final String name;
  final String imageUrl;          // thumbnail (primera imagen)
  final List<String> images;      // galería
  final double price;
  final String? team;
  final String? category;
  final String? description;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.images,
    required this.price,
    this.team,
    this.category,
    this.description,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }

  factory Product.fromJson(Map<String, dynamic> j) {
    final imgs = (j['images'] as List?)?.map((e) {
      if (e is String) return e;
      if (e is Map && e['src'] != null) return e['src'] as String;
      return null;
    }).whereType<String>().toList() ?? const <String>[];

    return Product(
      id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
      name: (j['name'] ?? '') as String,
      imageUrl: (j['image_url'] ?? (imgs.isNotEmpty ? imgs.first : '')) as String,
      images: imgs,
      price: _toDouble(j['price']),
      team: j['team'] as String?,
      category: j['category'] as String?,
      description: j['description'] as String?,
    );
  }
}
