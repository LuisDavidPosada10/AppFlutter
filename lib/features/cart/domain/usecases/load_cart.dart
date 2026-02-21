import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class LoadCart {
  LoadCart(this._repository);

  final CartRepository _repository;

  Future<List<CartItem>> call() => _repository.loadCart();
}

