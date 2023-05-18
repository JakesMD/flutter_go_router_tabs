import "package:flutter/widgets.dart";
import "package:go_router/go_router.dart";

typedef TabTransitionsBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  TextDirection direction,
  Widget child,
);

typedef TabShellRoutePageBuilder<T> = Page<T> Function(
  BuildContext context,
  GoRouterState state,
  int index,
  Widget child,
);

typedef TabShellRouteBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  int index,
  Widget child,
);

typedef TabShellRouteChildPageBuilder<T> = Page<T> Function(
  BuildContext context,
  GoRouterState state,
  TextDirection Function() direction,
  Widget child,
);
