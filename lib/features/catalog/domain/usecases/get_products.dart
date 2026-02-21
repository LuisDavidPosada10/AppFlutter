import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProducts {
  GetProducts(this._repository);

  final ProductsRepository _repository;

  Future<List<Product>> call() => _repository.getProducts();
}

