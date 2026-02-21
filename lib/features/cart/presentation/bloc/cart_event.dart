part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

final class CartStarted extends CartEvent {
  const CartStarted();
}

final class CartProductAdded extends CartEvent {
  const CartProductAdded(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class CartItemIncremented extends CartEvent {
  const CartItemIncremented(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}

final class CartItemDecremented extends CartEvent {
  const CartItemDecremented(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}

final class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}

final class CartCleared extends CartEvent {
  const CartCleared();
}

