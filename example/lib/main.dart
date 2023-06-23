import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_tabs/go_router_tabs.dart';

void main() {
  runApp(const MyApp());
}

abstract class MyRoutePaths {
  static const favorite = "/favorite";
  static const bookmark = "/bookmark";
  static const explore = "/star/explore";
  static const commute = "/star/commute";
  static const alarm = "/star/alarm";
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: MyRoutePaths.favorite,
        routes: [
          TabShellRoute(
            builder: (context, state, index, child) => MyNavRailScreen(
              selectedIndex: index,
              child: child,
            ),
            subPageBuilder: (context, state, direction, child) {
              return TabTransitionPage(
                key: state.pageKey,
                child: child,
                direction: direction,
                transitionsBuilder:
                    TabTransitionPage.verticalSlideFadeTransition,
              );
            },
            routes: (subPageBuilder, direction) => [
              GoRoute(
                path: MyRoutePaths.favorite,
                pageBuilder: (context, state) => subPageBuilder!(
                  context,
                  state,
                  child: const MySubScreen("Favorite"),
                ),
              ),
              GoRoute(
                path: MyRoutePaths.bookmark,
                pageBuilder: (context, state) => subPageBuilder!(
                  context,
                  state,
                  child: const MySubScreen("Bookmark"),
                ),
              ),
              TabShellRoute(
                pageBuilder: (context, state, index, child) => subPageBuilder!(
                  context,
                  state,
                  child: MySubScreenWithBottomNav(
                    selectedIndex: index,
                    child: child,
                  ),
                ),
                subPageBuilder: (context, state, direction, child) {
                  return TabTransitionPage(
                    key: state.pageKey,
                    child: child,
                    direction: direction,
                    transitionsBuilder:
                        TabTransitionPage.horizontalSlideFadeTransition,
                  );
                },
                routes: (subPageBuilder, direction) => [
                  GoRoute(
                    path: MyRoutePaths.explore,
                    pageBuilder: (context, state) => subPageBuilder!(
                      context,
                      state,
                      child: const MySubScreen("Explore"),
                    ),
                  ),
                  GoRoute(
                    path: MyRoutePaths.commute,
                    pageBuilder: (context, state) => subPageBuilder!(
                      context,
                      state,
                      child: const MySubScreen("Commute"),
                    ),
                  ),
                  GoRoute(
                    path: MyRoutePaths.alarm,
                    pageBuilder: (context, state) => subPageBuilder!(
                      context,
                      state,
                      child: const MySubScreen("Alarm"),
                    ),
                  ),
                ],
              ).toShellRoute,
            ],
          ).toShellRoute,
        ],
      ),
    );
  }
}

class MyNavRailScreen extends StatelessWidget {
  final int selectedIndex;
  final Widget child;

  MyNavRailScreen({
    super.key,
    this.selectedIndex = 0,
    required this.child,
  });

  final routePaths = [
    MyRoutePaths.favorite,
    MyRoutePaths.bookmark,
    MyRoutePaths.explore,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) => context.go(routePaths[value]),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.favorite),
                label: Text("Favorite"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bookmark),
                label: Text("Bookmark"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star),
                label: Text("Star"),
              ),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class MySubScreen extends StatelessWidget {
  final String title;

  const MySubScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}

class MySubScreenWithBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Widget child;

  MySubScreenWithBottomNav({
    super.key,
    this.selectedIndex = 0,
    required this.child,
  });

  final routePaths = [
    MyRoutePaths.explore,
    MyRoutePaths.commute,
    MyRoutePaths.alarm,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) => context.go(routePaths[value]),
        selectedIndex: selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.commute),
            label: 'Commute',
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm),
            label: 'Alarm',
          ),
        ],
      ),
    );
  }
}
