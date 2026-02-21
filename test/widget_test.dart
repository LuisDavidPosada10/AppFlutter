import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/app/app.dart';
import 'package:flutter_application_1/features/catalog/domain/entities/product.dart';
import 'package:flutter_application_1/features/catalog/domain/repositories/products_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeProductsRepository implements ProductsRepository {
  @override
  Future<List<Product>> getProducts() async => const [];
}

void main() {
  testWidgets('Smoke test: opens home', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MyApp(
        sharedPreferences: prefs,
        productsRepositoryOverride: _FakeProductsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Catálogo'), findsOneWidget);
  });
}
