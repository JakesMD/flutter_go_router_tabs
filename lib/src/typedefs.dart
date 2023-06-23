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

typedef TabShellRouteSubPageBuilder<T> = Page<T> Function(
  BuildContext context,
  GoRouterState state,
  TextDirection Function() direction,
  Widget child,
);

typedef TabShellRouteRoutesBuilder = List<RouteBase> Function(
  Page Function(
    BuildContext context,
    GoRouterState state, {
    required Widget child,
  })? subPageBuilder,
  TextDirection Function() direction,
);
