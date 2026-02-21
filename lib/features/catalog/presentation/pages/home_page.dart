import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/formatters/money_formatter.dart';
import 'package:flutter_application_1/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_application_1/features/catalog/domain/entities/product.dart';
import 'package:flutter_application_1/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_application_1/shared/widgets/global_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(title: 'Catálogo'),
      body: BlocBuilder<CatalogBloc, CatalogState>(
        builder: (context, state) {
          return switch (state.status) {
            CatalogStatus.initial => const Center(child: CircularProgressIndicator()),
            CatalogStatus.loading => const Center(child: CircularProgressIndicator()),
            CatalogStatus.failure => _CatalogError(
                message: state.errorMessage ?? 'No se pudo cargar el catálogo.',
                onRetry: () => context.read<CatalogBloc>().add(const CatalogRefreshed()),
              ),
            CatalogStatus.success => RefreshIndicator(
                onRefresh: () async {
                  context.read<CatalogBloc>().add(const CatalogRefreshed());
                },
                child: _CatalogContent(products: state.products),
              ),
          };
        },
      ),
    );
  }
}

class _CatalogContent extends StatelessWidget {
  const _CatalogContent({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return _ProductsGrid(products: products);
  }
}

class _ProductsGrid extends StatelessWidget {
  const _ProductsGrid({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width <= 499
            ? 1
            : width < 840
                ? 2
                : width < 1200
                    ? 3
                    : 4;

        final childAspectRatio = switch (columns) { 1 => 0.82, 2 => 0.74, 3 => 0.7, _ => 0.72 };

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) => _ProductCard(product: products[index]),
            ),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.01 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _ProductImage(url: widget.product.imageUrl)),
                const SizedBox(height: 12),
                Text(
                  (widget.product.category.isEmpty ? 'Producto' : widget.product.category).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.15),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      MoneyFormatter.format(widget.product.price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 12),
                BlocSelector<CartBloc, CartState, int>(
                  selector: (state) => state.quantityFor(widget.product.id),
                  builder: (context, quantity) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: quantity <= 0
                          ? SizedBox(
                              key: const ValueKey('add'),
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => context.read<CartBloc>().add(CartProductAdded(widget.product)),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('Agregar'),
                              ),
                            )
                          : _QuantityStepper(
                              key: const ValueKey('stepper'),
                              quantity: quantity,
                              onDecrement: () => context.read<CartBloc>().add(CartItemDecremented(widget.product.id)),
                              onIncrement: () => context.read<CartBloc>().add(CartItemIncremented(widget.product.id)),
                            ),
                    );
                  },
                ),
              ],
              ),
            ),
        ),
      ),
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'Ocurrió un problema',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    super.key,
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
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          _MiniIconButton(
            tooltip: 'Disminuir',
            onPressed: onDecrement,
            icon: Icons.remove,
          ),
          Expanded(
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          _MiniIconButton(
            tooltip: 'Aumentar',
            onPressed: onIncrement,
            icon: Icons.add,
          ),
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
