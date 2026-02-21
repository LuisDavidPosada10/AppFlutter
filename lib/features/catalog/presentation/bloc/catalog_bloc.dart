import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/features/catalog/domain/entities/product.dart';
import 'package:flutter_application_1/features/catalog/domain/usecases/get_products.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({required GetProducts getProducts})
      : _getProducts = getProducts,
        super(const CatalogState()) {
    on<CatalogStarted>(_onStarted);
    on<CatalogRefreshed>(_onRefreshed);
  }

  final GetProducts _getProducts;

  Future<void> _onStarted(
    CatalogStarted event,
    Emitter<CatalogState> emit,
  ) async {
    if (state.status == CatalogStatus.success && state.products.isNotEmpty) return;
    await _load(emit);
  }

  Future<void> _onRefreshed(
    CatalogRefreshed event,
    Emitter<CatalogState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<CatalogState> emit) async {
    emit(state.copyWith(status: CatalogStatus.loading, errorMessage: null));
    try {
      final products = await _getProducts();
      emit(state.copyWith(status: CatalogStatus.success, products: products));
    } catch (e) {
      emit(
        state.copyWith(
          status: CatalogStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

