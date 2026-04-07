# Carrito de compras (Flutter, BLoC, Clean Architecture)

Aplicación de catálogo + carrito + checkout con sincronización en tiempo real entre pantallas, persistencia local y diseño adaptable.

## Cómo ejecutar

- Requisitos:
  - Flutter estable instalado.
  - Dart incluido con Flutter.

- Web (Brave):
  - Opción 1 (web-server):
    - `flutter run -d web-server --web-hostname localhost --web-port 8081`
    - Abrir `http://localhost:8081` en Brave.
  - Opción 2 (variable para Brave):
    - En Windows PowerShell: `setx CHROME_EXECUTABLE "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"`
    - Luego: `flutter run -d chrome`

- Android:
  - Emulador/Dispositivo conectado.
  - `flutter run -d emulator-5554` (o el id de tu dispositivo).

- Pruebas:
  - `flutter test`

## Arquitectura

- Capas:
  - Presentación: páginas y BLoCs por feature.
  - Dominio: entidades, contratos de repositorio y casos de uso.
  - Datos: data sources (remoto/local), modelos y repositorios concretos.

- Dependencias dirigidas hacia adentro:
  - La presentación depende de dominio.
  - Los repositorios de datos implementan interfaces de dominio.
  - Las fuentes de datos quedan encapsuladas detrás de repositorios.

- Features:
  - Catalog: listado y carga de productos desde FakeStore API.
  - Cart: gestión de items, cantidades y totales; persistencia local.
  - Checkout: resumen, validación de formulario y flujo de confirmación.

Rutas relevantes:
- `lib/features/catalog/presentation/pages/home_page.dart`
- `lib/features/cart/presentation/pages/cart_page.dart`
- `lib/features/checkout/presentation/pages/checkout_page.dart`
- `lib/app/theme.dart`, `lib/app/routes.dart`, `lib/app/app.dart`

## Estado y sincronización (BLoC)

- CatalogBloc y CartBloc orquestan la carga de productos y el estado del carrito.
- Eventos y estados explícitos permiten:
  - Agregar, incrementar, decrementar y eliminar items.
  - Calcular subtotal por ítem y total general.
  - Reflejar de inmediato los cambios entre Home ↔ Carrito ↔ Checkout.
- El header global muestra el contador total y navega al carrito.

## Persistencia

- El carrito se guarda en `SharedPreferences`.
- Al iniciar la app, se lee el estado previo y el BLoC arranca con el carrito cargado.

## Decisiones clave

- BLoC por feature para mantener responsabilidades claras.
- Contratos en dominio; datos implementa API remota y almacenamiento local.
- FakeStore API con `core/network/api_client.dart` y modelos tipados.
- Formateo de dinero con `intl`.
- Tema Material 3, tipografía Montserrat y botones negros para CTAs.
- Microinteracciones sutiles: hover/pressed en botones y cards, animaciones cortas.

## Comportamiento tras el pago

- En Checkout se valida el formulario de pago.
- Al confirmar se muestra retroalimentación y se limpia el carrito.
- Se navega a una pantalla de éxito y el flujo vuelve listo para nueva compra.

## Pruebas

- Unit tests sobre estado del carrito y BLoC.
- Widget smoke test del Home.
- Ejecutar con `flutter test`.
