import 'dart:convert';
import 'dart:io';
import 'package:aythentication/models/http_exception.dart';
import 'package:aythentication/provider/product.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBR4p1ySHpPexTEBGSeBIUB6WhNzkdP02U';
    //'https://apptest.dokandemo.com/wp-json/wp/v2/users/register';
    try {
      final response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );

      if (urlSegment == 'signInWithPassword') {
        final newProduct = Product(
          email: email,
          password: password,
        );
        _items.add(newProduct);
        notifyListeners();
      }
      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      // print(json.decode(response.body));
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> updateProduct(String email, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.email != email);
    //if (prodIndex >= 0) {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBR4p1ySHpPexTEBGSeBIUB6WhNzkdP02U?auth=$token';
    await http.patch(url,
        body: json.encode({
          'email': newProduct.email,
          'password': newProduct.password,
        }));
    _items[prodIndex] = newProduct;
    notifyListeners();
    // } else {
    print(email);
    // }
  }

  Product findById(String email) {
    return _items.firstWhere((prod) => prod.email == email);
  }
}

// /
