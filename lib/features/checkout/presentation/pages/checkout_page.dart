import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/routes.dart';
import 'package:flutter_application_1/core/formatters/money_formatter.dart';
import 'package:flutter_application_1/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_application_1/shared/widgets/global_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(title: 'Checkout', showBack: true),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const _EmptyCheckout();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final content = _CheckoutContent(
                formKey: _formKey,
                nameController: _nameController,
                cardController: _cardController,
                total: state.totalPrice,
                onPay: () async {
                  final valid = _formKey.currentState?.validate() ?? false;
                  if (!valid) return;

                  final navigator = Navigator.of(context);
                  final cartBloc = context.read<CartBloc>();

                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );
                  await Future<void>.delayed(const Duration(milliseconds: 900));
                  if (!mounted) return;
                  navigator.pop();

                  cartBloc.add(const CartCleared());
                  if (!mounted) return;
                  navigator.pushNamedAndRemoveUntil(
                    AppRoutes.paymentSuccess,
                    (route) => false,
                  );
                },
              );

              if (!isWide) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: content,
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _OrderSummary(itemsCount: state.totalItems, total: state.totalPrice),
                        const SizedBox(height: 12),
                        ...state.items.map((e) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      e.product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('x${e.quantity}'),
                                  const SizedBox(width: 12),
                                  Text(MoneyFormatter.format(e.subtotal)),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: content,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CheckoutContent extends StatelessWidget {
  const _CheckoutContent({
    required this.formKey,
    required this.nameController,
    required this.cardController,
    required this.total,
    required this.onPay,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController cardController;
  final double total;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pago',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Total: ${MoneyFormatter.format(total)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Nombre en la tarjeta'),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Ingresa tu nombre';
                  if (v.length < 3) return 'Nombre demasiado corto';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cardController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Últimos 4 dígitos'),
                maxLength: 4,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.length != 4) return 'Debe tener 4 dígitos';
                  if (int.tryParse(v) == null) return 'Solo números';
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onPay,
          icon: const Icon(Icons.lock_outline),
          label: const Text('Confirmar pago'),
        ),
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.itemsCount, required this.total});

  final int itemsCount;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(
              '$itemsCount items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Text(
              MoneyFormatter.format(total),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCheckout extends StatelessWidget {
  const _EmptyCheckout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 56),
            const SizedBox(height: 12),
            Text(
              'No hay productos para pagar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text('Agrega productos al carrito antes de ir al checkout.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              ),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Volver al catálogo'),
            ),
          ],
        ),
      ),
    );
  }
}
