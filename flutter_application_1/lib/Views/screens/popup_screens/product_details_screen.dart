// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Models/cart_model.dart';
import 'package:flutter_application_1/Models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_application_1/Controllers/cart_controller.dart';
import 'package:flutter_application_1/Models/favorite_model.dart';
import 'package:flutter_application_1/Controllers/favorite_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late CartController _cartController;
  late FavoriteController _favoriteController;
  bool _isFavorite = false;
  String? _userId;
  String? _favoriteId;

  @override
  void initState() {
    super.initState();
    _cartController = CartController();
    _favoriteController = FavoriteController();
    _getUser();
  }

  // Get current user ID from FirebaseAuth and check if the product is already a favorite
  void _getUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      _checkIfFavorite();
    }
  }

  // Check if the product is already in the user's favorites
  void _checkIfFavorite() async {
    if (_userId == null) return;

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: _userId)
        .where('productId', isEqualTo: widget.product.id)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _isFavorite = true;
        _favoriteId = snapshot.docs.first.id; // Get the favorite document ID
      });
    }
  }

  // Add product to cart
  void _addToCart() async {
    if (_userId == null) return;

    final cartItem = CartModel(
      userId: _userId!,
      productId: widget.product.id,
      productName: widget.product.productName,
      productPrice: widget.product.price,
      quantity: 1,
      description: widget.product.description,
      category: widget.product.category, // Asegúrate de que 'category' esté presente
      productSize: int.parse(widget.product.size), // Asegúrate de que 'productSize' esté presente
      discount: widget.product.discount.toInt(),
      imageUrl: widget.product.images[0],
    );

    try {
      await _cartController.addToCart(cartItem, _userId.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: $e')),
      );
    }
  }

  // Add product to favorites
  void _addToFavorites() async {
    if (_userId == null) return;

    final favorite = FavoriteModel(
      userId: _userId!,
      productId: widget.product.id,
      productName: widget.product.productName,
      price: widget.product.price,
      imageUrl: widget.product.images[0],
    );

    try {
      final docRef = await _favoriteController.addToFavorites(favorite);
      setState(() {
        _isFavorite = true;
        _favoriteId = docRef.id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to favorites')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to favorites: $e')),
      );
    }
  }

  // Remove product from favorites
  void _removeFromFavorites() async {
    if (_favoriteId == null) return;

    try {
      await _favoriteController.removeFromFavorites(_favoriteId!);
      setState(() {
        _isFavorite = false;
        _favoriteId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing from favorites: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double discountedPrice = widget.product.price -
        (widget.product.price * (widget.product.discount / 100));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.productName),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            tooltip: _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
            onPressed: () {
              if (_isFavorite) {
                _removeFromFavorites();
              } else {
                _addToFavorites();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel for product images
            FlutterCarousel(
              options: FlutterCarouselOptions(
                height: 300,
                showIndicator: true,
                autoPlay: true,
                slideIndicator: CircularSlideIndicator(),
              ),
              items: widget.product.images.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.productName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Product Price with Discount
                  Row(
                    children: [
                      Text(
                        '\$${discountedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.product.discount > 0) ...[
                        const SizedBox(width: 10),
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${widget.product.discount}% off',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Product Description
                  const Text(
                    'Product Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // Product Category
                  Text(
                    'Category: ${widget.product.category}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // Product Size
                  Text(
                    'Size: ${widget.product.size}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _addToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Add to Cart',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}