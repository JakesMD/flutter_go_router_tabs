A wrapper around the [go_router](https://pub.dev/packages/go_router) package that provides the current sub-route index of a ShellRoute and the direction user came from based on the previous index.

## :sparkles: Features
* Seamless intergration with existing GoRouter setups.
* Always know the current sub-route index of a ShellRoute no matter how deeply nested the currently displayed route is or how the user got there.
* Know which direction the user came from so you can build awesome transitions based on the index of the previous and current route.
* Nest navigation bars without an issue.
* An extension on GoRouter's CustomTransitionPage to allow for better control over your transitions.
* Built-in transition presets.

## :rocket: Getting started
Note: there's no need to install the `go_router` package seperately. This package exports `go_router` to avoid version conflicts. 

Install it:
``` dart
flutter pub add go_router_tabs
```

Import it:
``` dart
import 'package:go_router_tabs/go_router_tabs.dart';
```

Now check out the [example](https://github.com/JakesMD/flutter_go_router_tabs/tree/main/example) to see this awesome package in action!


## :joystick: Usage
### TabShellRoute
Because `TabShellRoute().toShellRoute` is a `ShellRoute` you can add it anywhere within your existing GoRouter routes list:
``` dart
GoRouter(
  routes: [
    TabShellRoute().toShellRoute,
  ],
)
```

Both the `builder` and `pageBuilder` give you the index of the currently displayed sub-route - it even works when the current route is nested deep within a sub-route:
``` dart
TabShellRoute(
  builder: (context, state, index, child) {
    return MyNavigationBarPage(
      selectedIndex: index,
      child: child,
    );
  },
)
```

The `childPageBuilder` is the page builder for the sub-routes. It gives you the direction - useful for slide transitions for example - based on the previous and current sub-route. The direction parameter is actually a `TextDirection Function()` and needs to be evoked inside any transitions builder to fetch the latest direction from the TabShellRoute. `childPageBuilder` will not override already defined page builders in the children.
``` dart
TabShellRoute(
  childPageBuilder: (context, state, direction, child) {
    return TabTransitionPage(
      key: state.pageKey, // IMPORTANT! DON'T FORGET!
      child: child,
      direction: direction,
      transitionsBuilder: TabTransitionPage.verticalSlideFadeTransition,
    );
  },
)
```

Now you can add GoRoutes, ShellRoutes or TabShellRoutes to `routes` like a normal ShellRoute:
```dart
TabShellRoute(
  builder: (context, state, index, child) {
    return MyNavigationBarPage(
      selectedIndex: index,
      child: child,
    );
  },
  childPageBuilder: (context, state, direction, child) {
    return TabTransitionPage(
      key: state.pageKey,
      child: child,
      direction: direction,
      transitionsBuilder: TabTransitionPage.verticalSlideFadeTransition,
    );
  },
  routes: [
    GoRoute(
      path: "/first",
      builder: (context, state) => const FirstPage(),
    ),
    GoRoute(
      path: "/second",
      builder: (context, state) => const SecondPage(),
    ),
    GoRoute(
      path: "/third",
      builder: (context, state) => const ThirdPage(),
    ),
  ],
).toShellRoute,
```

### TabTransitionPage
This package also comes with `TabTransitionPage`, an extension on GoRouter's `CustomTransitionPage`.

`TabTransitionPage` allows you to specify the in and out curves of a transition:
``` dart
TabTransitionPage(
  transitionInCurve: Curves.bounceOut,
  transitionOutCurve: Curves.bounceOut,
);
```

The `transitionsBuilder` comes with an additional `direction` parameter - useful for slide transitions. You'll need to pass in the `direction` parameter from the `childPageBuilder`.
``` dart
TabTransitionPage(
  direction: direction,
  transitionsBuilder: (context, animation, secondaryAnimation, direction, child) {
    final slideTween = Tween<Offset>(
      begin: direction == TextDirection.ltr
        ? const Offset(-1, 0)
        : const Offset(1, 0),
      end: const Offset(0, 0),
    );
    final secondarySlideTween = Tween<Offset>(
      begin: const Offset(0, 0),
      end: direction == TextDirection.ltr
        ? const Offset(1, 0)
        : const Offset(-1, 0),
    );
    return SlideTransition(
      position: slideTween.animate(animation),
      child: SlideTransition(
        position: secondarySlideTween.animate(secondaryAnimation),
        child: child,
      ),
    );
  },
);
```

DON'T FORGET TO PASS THE KEY! Otherwise the transition won't work properly.
```
TabTransitionPage(
  key: state.pageKey,
);
```

`TabTransitionPage` also comes with some handy transition presets:
``` dart
TabTransitionPage.horizontalPushTransition;
TabTransitionPage.verticalPushTransition;
TabTransitionPage.horizontalSlideFadeTransition;
TabTransitionPage.verticalSlideFadeTransition;
```

## :information_source: Additional Information
Please don't hesitate to report any issues or feature requests on [GitHub](https://github.com/JakesMD/flutter_go_router_tabs).