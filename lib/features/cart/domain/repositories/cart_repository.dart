import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> loadCart();
  Future<void> saveCart(List<CartItem> items);
  Future<void> clearCart();
}

