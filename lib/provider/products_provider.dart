import 'package:flutter/material.dart';
import './product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];

  final String authToken;
  ProductsProvider(this.authToken, this._items);

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchAndSetProducts() async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBR4p1ySHpPexTEBGSeBIUB6WhNzkdP02U?auth=$authToken';
    //'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=AIzaSyBR4p1ySHpPexTEBGSeBIUB6WhNzkdP02U?auth=$authToken';
    // 'https://fluttertest-7ec69.firebaseio.com/products.json?auth=$authToken';
    try {
      final res = await http.get(url);
      print(json.decode(res.body));
      //final exractData = json.decode(res.body) as Map<String, dynamic>;
      //final List<Product> loadedProducts = [];
      // if (exractData == null) {
      //   return;
      // }
      // exractData.forEach((productId, productData) {
      //   loadedProducts.add(Product(
      //     id: productId,
      //     title: productData['title'],
      //     description: productData['description'],
      //     price: productData['price'],
      //     isFavorite: productData['isFavorite'],
      //     imageUrl: productData['imageUrl'],
      //   ));
      // });
      // _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
