import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final int productId;
  final String name;
  final String imageUrl;
  final double price;
  final int sizeId;
  final String sizeLabel;
  final int qty;

  CartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.sizeId,
    required this.sizeLabel,
    required this.qty,
  });

  CartItem copyWith({int? qty}) => CartItem(
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        price: price,
        sizeId: sizeId,
        sizeLabel: sizeLabel,
        qty: qty ?? this.qty,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'imageUrl': imageUrl,
        'price': price,
        'sizeId': sizeId,
        'sizeLabel': sizeLabel,
        'qty': qty,
      };

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        productId: j['productId'] as int,
        name: j['name'] as String,
        imageUrl: j['imageUrl'] as String? ?? '',
        price: (j['price'] as num).toDouble(),
        sizeId: j['sizeId'] as int,
        sizeLabel: j['sizeLabel'] as String,
        qty: j['qty'] as int,
      );
}

class LocalCart {
  static const _storageKey = 'cart_v1';
  static final LocalCart _instance = LocalCart._();
  LocalCart._();
  factory LocalCart() => _instance;

  Future<List<CartItem>> items() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(CartItem.fromJson).toList();
  }

  Future<void> _save(List<CartItem> list) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_storageKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<void> addOrIncrease(CartItem item) async {
    final list = await items();
    final idx = list.indexWhere((e) =>
        e.productId == item.productId &&
        e.sizeId == item.sizeId);
    if (idx >= 0) {
      final updated = list[idx].copyWith(qty: list[idx].qty + item.qty);
      list[idx] = updated;
    } else {
      list.add(item);
    }
    await _save(list);
  }

  Future<void> updateQty(int productId, int sizeId, int qty) async {
    final list = await items();
    final idx = list.indexWhere((e) => e.productId == productId && e.sizeId == sizeId);
    if (idx >= 0) {
      if (qty <= 0) {
        list.removeAt(idx);
      } else {
        list[idx] = list[idx].copyWith(qty: qty);
      }
      await _save(list);
    }
  }

  Future<void> remove(int productId, int sizeId) async {
    final list = await items();
    list.removeWhere((e) => e.productId == productId && e.sizeId == sizeId);
    await _save(list);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_storageKey);
  }

    Future<double> total() async {
    final list = await items();
    // Fuerza el tipo del acumulador (double) y del elemento (CartItem)
    return list.fold<double>(
      0.0,
      (double sum, CartItem e) => sum + (e.price * e.qty),
    );
  }

}
