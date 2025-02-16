import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/Models/cart_model.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository();
});

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the cart items for the user
  Future<Map<String, CartModel>> getCartItems(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      if (snapshot.docs.isNotEmpty) {
        return {
          for (var doc in snapshot.docs) doc.id: CartModel.fromMap(doc.data())
        };
      }
      return {};
    } catch (e) {
      throw Exception('Failed to fetch cart items: $e');
    }
  }

  /// Add a product to the cart in Firestore
  Future<void> addProductToCart(String userId, CartModel cartItem) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItem.productId)
          .set(cartItem.toMap());
    } catch (e) {
      throw Exception('Failed to add product to Firebase cart: $e');
    }
  }

  Future<void> removeProductFromCart(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove product from Firebase cart: $e');
    }
  }

  Future<void> updateCartQuantity(
      String userId, String productId, int quantity) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .update({'quantity': quantity});
    } catch (e) {
      throw Exception('Failed to update Firebase cart quantity: $e');
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      final cartCollection =
          _firestore.collection('users').doc(userId).collection('cart');
      final cartSnapshot = await cartCollection.get();

      for (var doc in cartSnapshot.docs) {
        await cartCollection.doc(doc.id).delete();
      }
    } catch (e) {
      throw Exception('Failed to clear Firebase cart: $e');
    }
  }

  Stream<List<CartModel>> getCartItemsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CartModel.fromMap(doc.data())).toList();
    });
  }
}
