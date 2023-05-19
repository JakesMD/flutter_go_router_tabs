import "package:flutter/widgets.dart";
import "package:go_router/go_router.dart";

import "typedefs.dart";

/// A temperary class that will be converted into a [ShellRoute].
///
/// During the conversion the [TabShellRoute] will set the page builder of each
/// child route to the one defined by [childPageBuilder]. However it will not
/// override the page builder of a child if the page builder is given.
///
/// [childPageBuilder] comes with an additional direction parameter that
/// is used to set the direction of slide transitions. This direction parameter
/// is based on the previous and current sub-route index.
///
/// Both [builder] and [pageBuilder] come with an additional index parameter
/// that contains the index of the sub-route currently being displayed.
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

  /// The page builder for the sub-routes.
  ///
  /// Similar to [GoRoute.pageBuilder], but with an additional direction
  /// parameter. This direction parameter - used as the direction for
  /// transitions like slide transitions - is based on the index of the
  /// previously visited sub-route.
  final TabShellRouteChildPageBuilder? childPageBuilder;

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
  final List<RouteBase> routes;

  /// Creates a temperary class that will be converted into a [ShellRoute].
  TabShellRoute({
    this.observers,
    this.navigatorKey,
    this.builder,
    this.pageBuilder,
    this.childPageBuilder,
    this.routes = const [],
  }) : assert(builder != null || pageBuilder != null) {
    _routePaths = [
      for (final route in routes) _fetchRoutePaths([route])
    ];
  }

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
      if (route.runtimeType == GoRoute) {
        paths.add((route as GoRoute).path);
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

  /// Generates a new [GoRoute] with an updated builder and page builder.
  GoRoute _buildGoRoute(GoRoute route) {
    return GoRoute(
      path: route.path,
      name: route.name,
      parentNavigatorKey: route.parentNavigatorKey,
      redirect: route.redirect,
      builder: childPageBuilder == null ? route.builder : null,
      pageBuilder: route.pageBuilder ??
          (childPageBuilder != null && route.builder != null
              ? (context, state) => childPageBuilder!(
                    context,
                    state,
                    direction,
                    route.builder!(context, state),
                  )
              : null),
      routes: route.routes,
    );
  }

  /// Generates a new [ShellRoute] with an updated builder and page builder.
  ShellRoute _buildShellRoute(ShellRoute route) {
    return ShellRoute(
      navigatorKey: route.navigatorKey,
      observers: route.observers,
      builder: childPageBuilder == null ? route.builder : null,
      pageBuilder: route.pageBuilder ??
          (childPageBuilder != null && route.builder != null
              ? (context, state, child) => childPageBuilder!(
                    context,
                    state,
                    direction,
                    route.builder!(context, state, child),
                  )
              : null),
      routes: route.routes,
    );
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
      routes: routes.map<RouteBase>(
        (route) {
          if (route.runtimeType == GoRoute) {
            return _buildGoRoute(route as GoRoute);
          }
          return _buildShellRoute(route as ShellRoute);
        },
      ).toList(),
    );
  }
}
