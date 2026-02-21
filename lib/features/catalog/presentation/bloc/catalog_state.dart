part of 'catalog_bloc.dart';

enum CatalogStatus { initial, loading, success, failure }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  final CatalogStatus status;
  final List<Product> products;
  final String? errorMessage;

  CatalogState copyWith({
    CatalogStatus? status,
    List<Product>? products,
    String? errorMessage,
  }) {
    return CatalogState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, errorMessage];
}

