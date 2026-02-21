import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required CartLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final CartLocalDataSource _localDataSource;

  @override
  Future<void> clearCart() => _localDataSource.clearCart();

  @override
  Future<List<CartItem>> loadCart() => _localDataSource.loadCart();

  @override
  Future<void> saveCart(List<CartItem> items) {
    final models = items.map(CartItemModel.fromDomain).toList(growable: false);
    return _localDataSource.saveCart(models);
  }
}

