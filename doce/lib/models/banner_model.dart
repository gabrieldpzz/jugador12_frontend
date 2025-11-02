class BannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final int order;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.order,
  });

  factory BannerModel.fromJson(Map<String, dynamic> j) => BannerModel(
        id: j['id'] as int,
        title: (j['title'] ?? '') as String,
        subtitle: (j['subtitle'] ?? '') as String,
        imageUrl: j['image_url'] as String,
        order: j['order'] as int,
      );
}
