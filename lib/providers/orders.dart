import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final _url = 'https://garage-sale-app-fb6c9-default-rtdb.firebaseio.com/';
  // ignore: prefer_final_fields
  List<OrderItem> _orders;
  final String? authToken;
  final String? userId;
  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = '${_url}orders/$userId.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      var extractedData = json.decode(response.body);
      final List<OrderItem> loadedOrders = [];
      if (extractedData == null) return;
      extractedData = extractedData as Map<String, dynamic>;
      extractedData.forEach(
        (orderId, orderData) {
          loadedOrders.insert(
            0,
            OrderItem(
              id: orderId,
              amount: orderData['amount'],
              products: (orderData['products'] as List<dynamic>)
                  .map((item) => CartItem(
                        id: item['id'],
                        price: item['price'],
                        quantity: item['quantity'],
                        title: item['title'],
                      ))
                  .toList(),
              dateTime: DateTime.parse(orderData['dateTime']),
            ),
          );
        },
      );
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = '${_url}orders/$userId.json?auth=$authToken';
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList()
          },
        ),
      );
      _orders.insert(
          0,
          OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timeStamp,
          ));
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }
}
