import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env.dart';
import '../models/banner_model.dart';

class BannerService {
  static Future<List<BannerModel>> fetch({int limit = 2}) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/api/banners?limit=$limit');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al cargar banners');
    }
    final data = json.decode(res.body) as List<dynamic>;
    return data.map((e) => BannerModel.fromJson(e as Map<String, dynamic>)).toList();
    }
}
