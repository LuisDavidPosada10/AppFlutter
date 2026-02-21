import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/routes.dart';
import 'package:flutter_application_1/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlobalAppBar({super.key, required this.title, this.showBack = false});

  final String title;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;

    return AppBar(
      title: Text(title),
      leading: showBack ? const BackButton() : null,
      actions: [
        IconButton(
          tooltip: 'Carrito',
          onPressed: routeName == AppRoutes.cart
              ? null
              : () => Navigator.of(context).pushNamed(AppRoutes.cart),
          icon: BlocSelector<CartBloc, CartState, int>(
            selector: (state) => state.totalItems,
            builder: (context, totalItems) => _CartIconBadge(count: totalItems),
          ),
        ),
      ],
    );
  }
}

class _CartIconBadge extends StatelessWidget {
  const _CartIconBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const Icon(Icons.shopping_cart_outlined);

    final colors = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart_outlined),
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors.error,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colors.surface, width: 2),
            ),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onError,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

