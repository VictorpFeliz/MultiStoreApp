import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/Models/cart_model.dart';

class CartController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToCart(CartModel cartItem, String userId) async {
    try {
      await _firestore.collection('cart').add({
        ...cartItem.toMap(),
        'userId': userId,
    });
    } catch (e) {
      throw Exception("Failed to add to cart: $e");
    }
  }

  Future<void> updateCartQuantity(String cartItemId, int quantity) async {
    try {
      final cartItemDoc = _firestore.collection('cart').doc(cartItemId);
      await cartItemDoc.update({'quantity': quantity});
    } catch (e) {
      throw Exception("Failed to update cart quantity: $e");
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _firestore.collection('cart').doc(cartItemId).delete();
    } catch (e) {
      throw Exception("Failed to remove from cart: $e");
    }
  }

  Stream<List<QueryDocumentSnapshot>> getUserCartItemsWithDocumentSnapshot(
      String userId) {
    return _firestore
        .collection('cart')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}