import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class ApiService {
  static const String url = 'https://dummyjson.com/recipe';

  static Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List list = data['recipes'];
      return list.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data produk');
    }
  }
}
