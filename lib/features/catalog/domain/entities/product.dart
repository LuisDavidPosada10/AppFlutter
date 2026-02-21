import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;

  @override
  List<Object?> get props => [id, title, price, description, category, imageUrl];
}

