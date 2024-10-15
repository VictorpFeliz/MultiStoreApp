import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/Models/cart_model.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, CartModel>>(
        (ref) => CartNotifier());

class CartNotifier extends StateNotifier<Map<String, CartModel>> {
  CartNotifier() : super({});

  void addProductToCart(
      {required productName,
      required productPrice,
      required productCategory,
      required imageUrl,
      required quantity,
      required stock,
      required productId,
      required productSize,
      required discount,
      required String userId,
      required description}) {
    if (state.containsKey(productId)) {
      state = {
        ...state,
        productId: CartModel(
            productName: state[productId]!.productName,
            productPrice: state[productId]!.productPrice,
            category: state[productId]!.category,
            imageUrl: state[productId]!.imageUrl,
            quantity: state[productId]!.quantity++,
            productId: state[productId]!.productId,
            productSize: state[productId]!.productSize,
            discount: state[productId]!.discount,
            description: state[productId]!.description,
            userId: state[productId]!.userId)
      };
    } else {
      state = {
        ...state,
        productId: CartModel(
            productName: productName,
            productPrice: productPrice,
            category: productCategory,
            imageUrl: imageUrl,
            quantity: quantity,
            productId: productId,
            productSize: productSize,
            discount: discount,
            description: description,
            userId: userId
            )
      };
    }
  }

  void removeItem(String productId) {
    state.remove(productId);
    state = {...state};
  }

  void incrementItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity++;
    } else {
      return;
    }
    state = {...state};
  }

  void decrementItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity--;
    } else {
      return;
    }
    state = {...state};
  }

  double calculateTotal() {
    double totalAmout = 0.0;
    state.forEach((productId, cartItem) {
      totalAmout +=
          (cartItem.quantity * (cartItem.productPrice - cartItem.discount));
    });
    return totalAmout;
  }
}