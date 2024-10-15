// ignore_for_file: unused_import, unused_field, library_private_types_in_public_api, use_build_context_synchronously

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

// Listas globales para almacenar productos favoritos y carrito
List<ProductModel> favoriteProducts = [];
List<CartModel> cartItems = []; // Definir cartItems como lista global

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late CartController _cartController;
  late FavoriteController _favoriteController;
  bool _isFavorite = false;
  String _userId = "guest";
    String? _favoriteId;

  @override
  void initState() {
    super.initState();
    _cartController = CartController();
    _favoriteController = FavoriteController();
    _getUser();
    _checkIfFavorite();
  }

  // Chequea si el producto ya está en favoritos
  void _checkIfFavorite() async {
    // ignore: unnecessary_null_comparison
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

  // Añadir o quitar de favoritos
  void _toggleFavorite() {
    setState(() {
      if (_isFavorite) {
        favoriteProducts.remove(widget.product);
      } else {
        favoriteProducts.add(widget.product);
      }
      _isFavorite = !_isFavorite;
    });
  }

  void _getUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      _checkIfFavorite();
    }
  }

  // Añadir al carrito
  void _addToCart() async{
    // Crear un nuevo objeto CartModel a partir del producto



    CartModel newCartItem = CartModel(
      productName: widget.product.productName,
      category: widget.product.category,
      productPrice: widget.product.price,
      imageUrl: widget.product.images.first, // Usar la primera imagen
      quantity: 1, // Iniciar con cantidad 1
      discount: widget.product.discount.toInt(),
      description: widget.product.description,
      productSize: int.parse(widget.product.size), // Convertir a int si es necesario
      productId: widget.product.id,
      userId: _userId,  // Cambiado _currentUser.uid a _userId
    );

    // Verificar si el producto ya está en el carrito
     try {
      await _cartController.addToCart(newCartItem, _userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: $e')),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto añadido al carrito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.productName),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: widget.product.images[0],
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.productName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '\$${widget.product.price}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (widget.product.discount > 0)
                        Text(
                          '-${widget.product.discount}%',
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cantidad disponible: ${widget.product.quantity}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tamaño: ${widget.product.size}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Botón de añadir al carrito
                  SizedBox(
                    width: double.infinity, // Botón ocupa todo el ancho
                    child: ElevatedButton.icon(
                      onPressed: _addToCart,
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Añadir al carrito'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16), // Botón más alto
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFavorite,
        backgroundColor: Colors.pink,
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : Colors.white,
        ),
      ),
    );
  }
}
