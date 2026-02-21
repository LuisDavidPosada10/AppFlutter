import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.description,
    required super.category,
    required super.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num).toInt(),
      title: (json['title'] as String?)?.trim() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: (json['description'] as String?)?.trim() ?? '',
      category: (json['category'] as String?)?.trim() ?? '',
      imageUrl: (json['image'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'description': description,
        'category': category,
        'image': imageUrl,
      };
}

