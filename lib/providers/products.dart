import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  final String? authToken;
  final String? userId;
  Products(this.authToken, this.userId, this._items);

  final _url = 'https://garage-sale-app-fb6c9-default-rtdb.firebaseio.com/';
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavourite).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final url = filterByUser
        ? '${_url}products.json?auth=$authToken&orderBy="creatorId"&equalTo="$userId"'
        : '${_url}products.json?auth=$authToken';
    final favUrl = '${_url}userFavourites/$userId.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final responseFav = await http.get(Uri.parse(favUrl));
      final favData = json.decode(responseFav.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.insert(
            0,
            Product(
              id: prodId,
              title: prodData['title'],
              price: prodData['price'],
              description: prodData['description'],
              imageUrl: prodData['imageUrl'],
              isFavourite: favData == null
                  ? false
                  : favData['products'][prodId] ?? false,
            ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProducts(product) async {
    final url = '${_url}products.json?auth=$authToken';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'userId': userId,
        }),
      );

      final newProduct = Product(
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> updateProduct(String id, Product editedProduct) async {
    final url = '${_url}products/$id.json?auth=$authToken';
    try {
      await http.patch(
        Uri.parse(url),
        body: json.encode({
          'title': editedProduct.title,
          'description': editedProduct.description,
          'price': editedProduct.price,
          'imageUrl': editedProduct.imageUrl,
        }),
      );
      var prodIndex = _items.indexWhere((prod) => prod.id == id);
      _items[prodIndex] = editedProduct;
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = '${_url}products/$id.json?auth=$authToken';
    final existingProductId = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductId];
    _items.removeAt(existingProductId);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _items.insert(existingProductId, existingProduct);
      notifyListeners(); // Optimistic updating
      throw HttpException('Failed to delete product');
    }
  }
}
