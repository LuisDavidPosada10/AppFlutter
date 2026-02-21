import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_application_1/features/cart/domain/usecases/load_cart.dart';
import 'package:flutter_application_1/features/cart/domain/usecases/save_cart.dart';
import 'package:flutter_application_1/features/catalog/domain/entities/product.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({required LoadCart loadCart, required SaveCart saveCart})
      : _loadCart = loadCart,
        _saveCart = saveCart,
        super(const CartState()) {
    on<CartStarted>(_onStarted);
    on<CartProductAdded>(_onProductAdded);
    on<CartItemIncremented>(_onItemIncremented);
    on<CartItemDecremented>(_onItemDecremented);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCleared>(_onCleared);
  }

  final LoadCart _loadCart;
  final SaveCart _saveCart;

  Future<void> _onStarted(CartStarted event, Emitter<CartState> emit) async {
    final optimisticItems = state.items;
    emit(state.copyWith(status: CartStatus.loading, errorMessage: null));
    try {
      final items = await _loadCart();
      final merged = _mergeItems(items, optimisticItems);
      emit(state.copyWith(status: CartStatus.ready, items: merged));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onProductAdded(
    CartProductAdded event,
    Emitter<CartState> emit,
  ) async {
    final next = state.upsert(event.product, delta: 1);
    emit(next);
    await _persistIfReady(next, emit);
  }

  Future<void> _onItemIncremented(
    CartItemIncremented event,
    Emitter<CartState> emit,
  ) async {
    final next = state.changeQuantity(event.productId, delta: 1);
    emit(next);
    await _persistIfReady(next, emit);
  }

  Future<void> _onItemDecremented(
    CartItemDecremented event,
    Emitter<CartState> emit,
  ) async {
    final next = state.changeQuantity(event.productId, delta: -1);
    emit(next);
    await _persistIfReady(next, emit);
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final next = state.remove(event.productId);
    emit(next);
    await _persistIfReady(next, emit);
  }

  Future<void> _onCleared(CartCleared event, Emitter<CartState> emit) async {
    final next = state.copyWith(items: const []);
    emit(next);
    await _persistIfReady(next, emit);
  }

  Future<void> _persistIfReady(CartState next, Emitter<CartState> emit) async {
    if (next.status != CartStatus.ready) return;
    try {
      await _saveCart(next.items);
    } catch (e) {
      emit(next.copyWith(errorMessage: e.toString()));
    }
  }

  List<CartItem> _mergeItems(List<CartItem> loaded, List<CartItem> optimistic) {
    if (optimistic.isEmpty) return loaded;
    if (loaded.isEmpty) return optimistic;

    final map = <int, CartItem>{
      for (final e in loaded) e.product.id: e,
    };

    for (final e in optimistic) {
      final existing = map[e.product.id];
      if (existing == null) {
        map[e.product.id] = e;
      } else {
        map[e.product.id] = existing.copyWith(quantity: existing.quantity + e.quantity);
      }
    }

    return map.values.where((e) => e.quantity > 0).toList(growable: false);
  }
}
