// To parse this JSON data, do
//
//     final cartModel = cartModelFromJson(jsonString);

import 'dart:convert';

CartModel cartModelFromJson(String str) => CartModel.fromJson(json.decode(str));

String cartModelToJson(CartModel data) => json.encode(data.toJson());

class CartModel {
  final String productName;
  final String category;
  final double productPrice;
  final String imageUrl;
  int quantity;
  final int discount;
  final String description;
  final int productSize;
  final String productId;
  final String userId;

  CartModel({
    required this.productName,
    required this.category,
    required this.productPrice,
    required this.imageUrl,
    required this.quantity,
    required this.discount,
    required this.description,
    required this.productSize,
    required this.productId,
    
    required this.userId, 
  });

  // Convert a CartModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'category': category,
      'productPrice': productPrice,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'discount': discount,
      'description': description,
      'productSize': productSize,
      'productId': productId,
    };
  }

  // Create a CartModel from a Firestore document
  static CartModel fromMap(Map<String, dynamic> map) {
    return CartModel(
      productName: map['productName'],
      category: map['category'],
      productPrice: map['productPrice']?.toDouble(),
      imageUrl: map['imageUrl'],
      quantity: map['quantity'],
      discount: map['discount'] ?? 0,
      description: map['description'],
      productSize: map['productSize'],
      productId: map['productId'],
      userId: map['userId'],
    );
  }

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        productName: json["ProductName"],
        category: json["Category"],
        productPrice: json["ProductPrice"]?.toDouble(),
        imageUrl: json["ImageUrl"],
        quantity: json["Quantity"],
        discount: json["Discount"],
        description: json["Description"],
        productSize: json["ProductSize"],
        productId: json["ProductId"],
        userId:  json["UserId"],
      );

  Map<String, dynamic> toJson() => {
        "ProductName": productName,
        "Category": category,
        "ProductPrice": productPrice,
        "ImageUrl": imageUrl,
        "Quantity": quantity,
        "Discount": discount,
        "Description": description,
        "ProductSize": productSize,
        "ProductId": productId,
        "UserId" : userId
      };
}
