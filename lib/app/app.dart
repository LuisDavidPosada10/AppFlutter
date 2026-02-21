import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/routes.dart';
import 'package:flutter_application_1/app/theme.dart';
import 'package:flutter_application_1/core/network/api_client.dart';
import 'package:flutter_application_1/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:flutter_application_1/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:flutter_application_1/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_application_1/features/cart/domain/usecases/load_cart.dart';
import 'package:flutter_application_1/features/cart/domain/usecases/save_cart.dart';
import 'package:flutter_application_1/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_application_1/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_application_1/features/catalog/data/datasources/products_remote_data_source.dart';
import 'package:flutter_application_1/features/catalog/data/repositories/products_repository_impl.dart';
import 'package:flutter_application_1/features/catalog/domain/repositories/products_repository.dart';
import 'package:flutter_application_1/features/catalog/domain/usecases/get_products.dart';
import 'package:flutter_application_1/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_application_1/features/catalog/presentation/pages/home_page.dart';
import 'package:flutter_application_1/features/checkout/presentation/pages/checkout_page.dart';
import 'package:flutter_application_1/features/checkout/presentation/pages/payment_success_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.sharedPreferences,
    this.productsRepositoryOverride,
    this.cartRepositoryOverride,
    this.httpClientOverride,
  });

  final SharedPreferences sharedPreferences;
  final ProductsRepository? productsRepositoryOverride;
  final CartRepository? cartRepositoryOverride;
  final http.Client? httpClientOverride;

  @override
  Widget build(BuildContext context) {
    final client = httpClientOverride ?? http.Client();
    final apiClient = ApiClient(client: client);

    final productsRepository = productsRepositoryOverride ??
        ProductsRepositoryImpl(
          remoteDataSource: ProductsRemoteDataSource(apiClient: apiClient),
        );

    final cartRepository = cartRepositoryOverride ??
        CartRepositoryImpl(
          localDataSource: CartLocalDataSource(sharedPreferences: sharedPreferences),
        );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProductsRepository>.value(value: productsRepository),
        RepositoryProvider<CartRepository>.value(value: cartRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CatalogBloc(
              getProducts: GetProducts(context.read<ProductsRepository>()),
            )..add(const CatalogStarted()),
          ),
          BlocProvider(
            create: (context) => CartBloc(
              loadCart: LoadCart(context.read<CartRepository>()),
              saveCart: SaveCart(context.read<CartRepository>()),
            )..add(const CartStarted()),
          ),
        ],
        child: MaterialApp(
          title: 'Prueba MPOS',
          theme: AppTheme.light(),
          initialRoute: AppRoutes.home,
          routes: {
            AppRoutes.home: (_) => const HomePage(),
            AppRoutes.cart: (_) => const CartPage(),
            AppRoutes.checkout: (_) => const CheckoutPage(),
            AppRoutes.paymentSuccess: (_) => const PaymentSuccessPage(),
          },
        ),
      ),
    );
  }
}

