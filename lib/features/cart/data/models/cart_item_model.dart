import 'package:flutter_application_1/features/cart/domain/entities/cart_item.dart';

import '../../../catalog/data/models/product_model.dart';

class CartItemModel extends CartItem {
  const CartItemModel({required super.product, required super.quantity});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(
        Map<String, dynamic>.from(json['product'] as Map),
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'product': (product as ProductModel).toJson(),
        'quantity': quantity,
      };

  static CartItemModel fromDomain(CartItem item) {
    final p = item.product;
    final model = p is ProductModel
        ? p
        : ProductModel(
            id: p.id,
            title: p.title,
            price: p.price,
            description: p.description,
            category: p.category,
            imageUrl: p.imageUrl,
          );
    return CartItemModel(product: model, quantity: item.quantity);
  }
}

