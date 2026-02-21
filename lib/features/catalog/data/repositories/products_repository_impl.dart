import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl({required ProductsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ProductsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Product>> getProducts() async {
    return _remoteDataSource.getProducts();
  }
}

