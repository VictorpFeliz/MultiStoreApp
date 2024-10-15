import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_application_1/Models/product_model.dart';
import 'package:flutter_application_1/Views/screens/product_details_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: favoriteProducts.isEmpty
          ? const Center(child: Text('No tienes productos en favoritos'))
          : ListView.builder(
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return ListTile(
                  leading: Image.network(product.images[0]),
                  title: Text(product.productName),
                  subtitle: Text('\$${product.price}'),
                  onTap: () {
                    // Navegar a la pantalla de detalles del producto
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
