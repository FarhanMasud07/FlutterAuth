import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  final String email;
  final String password;
  // final String description;
  // final double price;
  // final String imageUrl;
  // bool isFavorite;

  Product({
    @required this.email,
    @required this.password,
    // @required this.description,
    // @required this.price,
    // @required this.imageUrl,
    //this.isFavorite = false,
  });
}
