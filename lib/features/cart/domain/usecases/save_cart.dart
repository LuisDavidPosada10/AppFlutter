import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class SaveCart {
  SaveCart(this._repository);

  final CartRepository _repository;

  Future<void> call(List<CartItem> items) => _repository.saveCart(items);
}

