import 'package:flutter_application_1/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_application_1/features/catalog/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const product = Product(
    id: 1,
    title: 'Test',
    price: 10,
    description: '',
    category: '',
    imageUrl: '',
  );

  test('upsert agrega e incrementa cantidades', () {
    var state = const CartState(status: CartStatus.ready, items: []);

    state = state.upsert(product, delta: 1);
    expect(state.totalItems, 1);
    expect(state.quantityFor(product.id), 1);
    expect(state.totalPrice, 10);

    state = state.upsert(product, delta: 1);
    expect(state.totalItems, 2);
    expect(state.quantityFor(product.id), 2);
    expect(state.totalPrice, 20);
  });

  test('decrement elimina el ítem al llegar a cero', () {
    var state = const CartState(status: CartStatus.ready, items: []);
    state = state.upsert(product, delta: 1);
    expect(state.items.length, 1);

    state = state.changeQuantity(product.id, delta: -1);
    expect(state.items, isEmpty);
    expect(state.totalItems, 0);
    expect(state.totalPrice, 0);
  });
}

