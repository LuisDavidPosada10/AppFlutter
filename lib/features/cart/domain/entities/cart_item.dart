import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/features/catalog/domain/entities/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}

