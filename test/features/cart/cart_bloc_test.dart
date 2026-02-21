import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_application_1/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_application_1/features/cart/domain/usecases/load_cart.dart';
import 'package:flutter_application_1/features/cart/domain/usecases/save_cart.dart';
import 'package:flutter_application_1/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_application_1/features/catalog/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadCart extends Mock implements LoadCart {}

class _MockSaveCart extends Mock implements SaveCart {}

void main() {
  setUpAll(() {
    registerFallbackValue(<CartItem>[]);
  });

  late _MockSaveCart saveCart;

  const product = Product(
    id: 1,
    title: 'Test',
    price: 10,
    description: '',
    category: '',
    imageUrl: '',
  );

  test('initial state es initial', () {
    final bloc = CartBloc(loadCart: _MockLoadCart(), saveCart: _MockSaveCart());
    expect(bloc.state.status, CartStatus.initial);
    bloc.close();
  });

  blocTest<CartBloc, CartState>(
    'CartStarted emite loading y luego ready',
    build: () {
      final loadCart = _MockLoadCart();
      final saveCart = _MockSaveCart();
      when(() => loadCart()).thenAnswer((_) async => [const CartItem(product: product, quantity: 2)]);
      when(() => saveCart(any())).thenAnswer((_) async {});
      return CartBloc(loadCart: loadCart, saveCart: saveCart);
    },
    act: (bloc) => bloc.add(const CartStarted()),
    expect: () => [
      isA<CartState>().having((s) => s.status, 'status', CartStatus.loading),
      isA<CartState>()
          .having((s) => s.status, 'status', CartStatus.ready)
          .having((s) => s.totalItems, 'totalItems', 2),
    ],
  );

  blocTest<CartBloc, CartState>(
    'CartProductAdded persiste cuando está ready',
    build: () {
      final loadCart = _MockLoadCart();
      saveCart = _MockSaveCart();
      when(() => loadCart()).thenAnswer((_) async => const []);
      when(() => saveCart(any())).thenAnswer((_) async {});
      return CartBloc(loadCart: loadCart, saveCart: saveCart);
    },
    seed: () => const CartState(status: CartStatus.ready, items: []),
    act: (bloc) => bloc.add(const CartProductAdded(product)),
    expect: () => [
      isA<CartState>().having((s) => s.totalItems, 'totalItems', 1),
    ],
    verify: (bloc) {
      verify(() => saveCart(any())).called(1);
    },
  );
}
