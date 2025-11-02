class SizeOption {
  final int id;
  final String type;   // 'adult' | 'kid'
  final String label;  // 'S','M','L','10','12',...
  final int stock;     // 0 => agotada

  const SizeOption({
    required this.id,
    required this.type,
    required this.label,
    required this.stock,
  });

  factory SizeOption.fromJson(Map<String, dynamic> j) => SizeOption(
        id: j['id'] as int,
        type: (j['type'] ?? '') as String,
        label: (j['label'] ?? '') as String,
        stock: (j['stock'] ?? 0) as int,
      );
}
