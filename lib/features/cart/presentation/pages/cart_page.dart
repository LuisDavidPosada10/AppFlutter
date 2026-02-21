import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/routes.dart';
import 'package:flutter_application_1/core/formatters/money_formatter.dart';
import 'package:flutter_application_1/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_application_1/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_application_1/shared/widgets/global_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(title: 'Carrito', showBack: true),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.status == CartStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.items.isEmpty) {
            return const _EmptyCart();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;

              if (!isWide) {
                return Column(
                  children: [
                    Expanded(child: _CartItemsList(itemsCount: state.items.length)),
                    _CartFooter(total: state.totalPrice),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _CartItemsList(itemsCount: state.items.length),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 2,
                    child: _CartSummaryPanel(total: state.totalPrice),
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

class _CartItemsList extends StatelessWidget {
  const _CartItemsList({required this.itemsCount});

  final int itemsCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        Row(
          children: [
            Text('Tu selección', style: titleStyle),
            const Spacer(),
            Text(
              '$itemsCount items',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 14),
        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _CartItemCard(productId: item.product.id);
              },
            );
          },
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (prev, next) => prev.items != next.items,
      builder: (context, state) {
        CartItem? item;
        for (final e in state.items) {
          if (e.product.id == productId) {
            item = e;
            break;
          }
        }
        if (item == null) return const SizedBox.shrink();
        final cartBloc = context.read<CartBloc>();

        return Dismissible(
          key: ValueKey(productId),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Eliminar',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          onDismissed: (_) => cartBloc.add(CartItemRemoved(productId)),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CartItemImage(url: item.product.imageUrl, size: 92),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            Text(
                              MoneyFormatter.format(item.product.price),
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Text(
                              '•',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: colors.outline,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Text(
                              'Subtotal ${MoneyFormatter.format(item.subtotal)}',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _CartStepper(
                              quantity: item.quantity,
                              onDecrement: () => cartBloc.add(CartItemDecremented(productId)),
                              onIncrement: () => cartBloc.add(CartItemIncremented(productId)),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: () => cartBloc.add(CartItemRemoved(productId)),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Quitar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.onSurface,
                                side: BorderSide(color: colors.outlineVariant),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CartFooter extends StatelessWidget {
  const _CartFooter({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Text(
                  MoneyFormatter.format(total),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.checkout),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.onSurface,
                  foregroundColor: colors.surface,
                ),
                child: const Text('Ir a pagar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummaryPanel extends StatelessWidget {
  const _CartSummaryPanel({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Resumen',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Total', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const Spacer(),
                    Text(
                      MoneyFormatter.format(total),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.checkout),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.onSurface,
                      foregroundColor: colors.surface,
                    ),
                    child: const Text('Ir a pagar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 56, color: colors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Tu carrito está vacío',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Agrega productos desde el catálogo y vuelve acá para finalizar tu compra.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Seguir comprando'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemImage extends StatelessWidget {
  const _CartItemImage({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.image_not_supported_outlined, color: colors.onSurfaceVariant);
        },
      ),
    );
  }
}

class _CartStepper extends StatelessWidget {
  const _CartStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniIconButton(tooltip: 'Disminuir', onPressed: onDecrement, icon: Icons.remove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          _MiniIconButton(tooltip: 'Aumentar', onPressed: onIncrement, icon: Icons.add),
        ],
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.black,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          splashFactory: InkRipple.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return Colors.white.withValues(alpha: 0.12);
            if (states.contains(WidgetState.hovered)) return Colors.white.withValues(alpha: 0.08);
            if (states.contains(WidgetState.focused)) return Colors.white.withValues(alpha: 0.10);
            return null;
          }),
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
