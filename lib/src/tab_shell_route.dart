import "package:flutter/widgets.dart";
import "package:go_router/go_router.dart";

import "typedefs.dart";

/// A temperary class that will be converted into a [ShellRoute].
///
/// The optional [subPageBuilder] is used to avoid duplicate code. It comes
/// with a direction parameter that is used to set the direction of slide
/// transitions. This direction parameter is based on the previous and current
/// sub-route index.
///
/// Both [builder] and [pageBuilder] come with an additional index parameter
/// that contains the index of the sub-route currently being displayed.
///
/// [routes] come with an additional sub page builder parameter that you
/// define in [subPageBuilder] as well as a direction parameter. This makes it
/// possible for you to use custom GoRoutes or ShellRoutes.
///
/// A [ShellRoute] is a route that displays a UI shell around the matching child
/// route.
///
/// When a ShellRoute is added to the list of routes on GoRouter or GoRoute, a
/// new Navigator is used to display any matching sub-routes instead of placing
/// them on the root Navigator.
///
/// To display a child route on a different Navigator, provide it with a
/// [parentNavigatorKey] that matches the key provided to either the [GoRouter]
/// or [ShellRoute] constructor.
class TabShellRoute {
  /// The widget builder for a shell route.
  ///
  /// Similar to [GoRoute.builder], but with additional parameters. The
  /// child parameter is the Widget built by calling the matching sub-route's
  /// builder. The index parameter is the the index of the sub-route in
  /// [TabShellRoute.routes] that is currently being displayed.
  final TabShellRouteBuilder? builder;

  /// The page builder for a shell route.
  ///
  /// Similar to [GoRoute.pageBuilder], but with additional parameters. The
  /// child parameter is the Widget built by calling the matching sub-route's
  /// builder. The index parameter is the the index of the sub-route in
  /// [TabShellRoute.routes] that is currently being displayed.
  ///
  /// This will override the child page builder of a parent TabShellRoute.
  final TabShellRoutePageBuilder? pageBuilder;

  /// An optional page builder for the sub-routes which is used to avoid
  /// duplicate code. It will be passed into [routes].
  ///
  /// Similar to [GoRoute.pageBuilder], but with an additional direction
  /// parameter. This direction parameter - used as the direction for
  /// transitions like slide transitions - is based on the index of the
  /// previously visited sub-route.
  final TabShellRouteSubPageBuilder? subPageBuilder;

  /// The observers for a shell route.
  ///
  /// The observers parameter is used by the [Navigator] built for this route.
  /// sub-route's observers.
  final List<NavigatorObserver>? observers;

  /// The [GlobalKey] to be used by the [Navigator] built for this route.
  /// All ShellRoutes build a Navigator by default. Child GoRoutes
  /// are placed onto this Navigator instead of the root Navigator.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The list of child routes associated with this route.
  ///
  /// It come with an additional sub page builder parameter that you
  /// define in [subPageBuilder] as well as a direction parameter. This makes it
  /// possible for you to use custom GoRoutes or ShellRoutes.
  final TabShellRouteRoutesBuilder routes;

  /// Creates a temperary class that will be converted into a [ShellRoute].
  TabShellRoute({
    this.observers,
    this.navigatorKey,
    this.builder,
    this.pageBuilder,
    this.subPageBuilder,
    required this.routes,
  }) : assert(builder != null || pageBuilder != null);

  /// A list containing a list of the top level route paths for each route.
  late List<List<String>> _routePaths;

  /// The index of the sub-route currently displayed.
  var _currentSubrouteIndex = 0;

  /// The index of the sub-route last displayed.
  var _previousSubrouteIndex = 0;

  /// Fetches a the top-level paths from a list of routes.
  List<String> _fetchRoutePaths(List<RouteBase> newRoutes) {
    var paths = <String>[];

    for (final route in newRoutes) {
      if (route is GoRoute) {
        paths.add(route.path);
      } else {
        paths.addAll(_fetchRoutePaths(route.routes));
      }
    }

    return paths;
  }

  /// Finds the index of the new route and updates [_currentSubrouteIndex] and
  /// [_previousSubrouteIndex] accordingly.
  void _updateSubrouteIndex(GoRouterState state) {
    int? bestRoutePathIndex;
    var highScore = 0;

    for (int i = 0; i < _routePaths.length; i++) {
      for (final path in _routePaths[i]) {
        final match = RegExp(path).matchAsPrefix(state.location);
        if ((match?.end ?? 0) > highScore) {
          highScore = match!.end;
          bestRoutePathIndex = i;
        }
      }
    }

    if (bestRoutePathIndex == null) return;
    _previousSubrouteIndex = _currentSubrouteIndex;
    _currentSubrouteIndex = bestRoutePathIndex;
  }

  /// Gets the direction of a transition.
  ///
  /// This needs to be a Function in order for a transition to fetch the latest
  /// direction on the fly.
  TextDirection direction() {
    return _currentSubrouteIndex >= _previousSubrouteIndex
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// Generates a [ShellRoute] from this [TabShellRoute].
  ShellRoute get toShellRoute {
    final newRoutes = routes(
      subPageBuilder != null
          ? (context, state, {required Widget child}) => subPageBuilder!(
                context,
                state,
                direction,
                child,
              )
          : null,
      direction,
    );

    _routePaths = [
      for (final route in newRoutes) _fetchRoutePaths([route])
    ];

    return ShellRoute(
      observers: observers,
      navigatorKey: navigatorKey,
      builder: builder != null
          ? (context, state, child) {
              _updateSubrouteIndex(state);
              return builder!(context, state, _currentSubrouteIndex, child);
            }
          : null,
      pageBuilder: pageBuilder != null
          ? (context, state, child) {
              _updateSubrouteIndex(state);
              return pageBuilder!(context, state, _currentSubrouteIndex, child);
            }
          : null,
      routes: newRoutes,
    );
  }
}
