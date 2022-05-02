import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final _url = 'https://garage-sale-app-fb6c9-default-rtdb.firebaseio.com/';
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false,
  });

  void _setFavVal(bool newVal) {
    isFavourite = newVal;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url = '${_url}userFavourites/$userId/products/$id.json?auth=$token';
    try {
      final res = await http.put(Uri.parse(url),
          body: json.encode(
            isFavourite,
          ));

      if (res.statusCode >= 400) {
        _setFavVal(oldStatus);
      }
    } catch (error) {
      _setFavVal(oldStatus);
    }
  }
}
