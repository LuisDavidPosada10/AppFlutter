part of 'cart_bloc.dart';

enum CartStatus { initial, loading, ready, failure }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final CartStatus status;
  final List<CartItem> items;
  final String? errorMessage;

  int get totalItems => items.fold(0, (acc, e) => acc + e.quantity);
  double get totalPrice => items.fold(0, (acc, e) => acc + e.subtotal);

  int quantityFor(int productId) {
    final found = items.where((e) => e.product.id == productId).toList();
    if (found.isEmpty) return 0;
    return found.first.quantity;
  }

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  CartState upsert(Product product, {required int delta}) {
    final idx = items.indexWhere((e) => e.product.id == product.id);
    if (idx == -1) {
      final nextItems = List<CartItem>.from(items)..add(CartItem(product: product, quantity: delta));
      return copyWith(status: CartStatus.ready, items: nextItems, errorMessage: null);
    }

    final current = items[idx];
    final nextQuantity = current.quantity + delta;
    if (nextQuantity <= 0) {
      final nextItems = List<CartItem>.from(items)..removeAt(idx);
      return copyWith(status: CartStatus.ready, items: nextItems, errorMessage: null);
    }
    final nextItems = List<CartItem>.from(items)
      ..[idx] = current.copyWith(quantity: nextQuantity);
    return copyWith(status: CartStatus.ready, items: nextItems, errorMessage: null);
  }

  CartState changeQuantity(int productId, {required int delta}) {
    final idx = items.indexWhere((e) => e.product.id == productId);
    if (idx == -1) return this;
    final current = items[idx];
    return upsert(current.product, delta: delta);
  }

  CartState remove(int productId) {
    final nextItems = items.where((e) => e.product.id != productId).toList(growable: false);
    return copyWith(status: CartStatus.ready, items: nextItems, errorMessage: null);
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}

