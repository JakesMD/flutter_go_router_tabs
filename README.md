A [go_router](https://pub.dev/packages/go_router) package add-on to improve tabbed navigation. It features a special ShellRoute that provides both the selected navigation item index and transition direction - regardless of the current route's nesting level or the user's navigation path.

![An animation of a web app navigating between tabs using this package.](https://raw.githubusercontent.com/JakesMD/flutter_go_router_tabs/main/screenshots/preview.gif)

## :sparkles: Features
* Seamless integration with existing GoRouter setups.
* Provides the selected navigation item index no matter how deeply nested the current route is or how the user got there.
* Provides the direction the user came from so you can build awesome transitions based on the previous and current navigation item index.
* Nested navigation bar setups work without an issue.
* No need for global navigation bar controllers.
* Comes with an extension on GoRouter's CustomTransitionPage to allow for better control over your transitions.
* Comes with neat transition presets.

## :rocket: Getting started
Note: You'll need to install the `go_router` package seperately. This package **no longer** exports `go_router` to allow you to set a specific version of go_router in your app if required.

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
### :boom: Breaking Changes from 0.3.0!
These changes allow for custom GoRoutes or ShellRoutes:
* `childPageBuilder` has been renamed to `subPageBuilder`.
* `TabShellRoute` no longer sets the page builders of its sub-routes.
* Instead, the `subPageBuilder` and `direction` are passed into `routes` which is now a `List Function()`.
* See the Usage/TabShellRoute section for more details...

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
).toShellRoute
```

The `subPageBuilder` is an optional page builder for the sub-routes and is used to avoid duplicate code. It gives you the direction - useful for slide transitions for example - based on the previous and current sub-route. The direction parameter is actually a `TextDirection Function()` and needs to be evoked inside your transitions builder to fetch the latest direction from the TabShellRoute.
``` dart
TabShellRoute(
  subPageBuilder: (context, state, direction, child) {
    return TabTransitionPage(
      key: state.pageKey, // IMPORTANT! DON'T FORGET!
      child: child,
      direction: direction,
      transitionsBuilder: TabTransitionPage.verticalSlideFadeTransition,
    );
  },
).toShellRoute
```

`routes` is a builder that comes with sub page builder (which is defined by you in `subPageBuilder`) and direction parameters. Now you can add GoRoutes, ShellRoutes, TabShellRoutes or your own custom routes:
```dart
TabShellRoute(
  builder: (context, state, index, child) {
    return MyNavigationBarPage(
      selectedIndex: index,
      child: child,
    );
  },
  subPageBuilder: (context, state, direction, child) {
    return TabTransitionPage(
      key: state.pageKey,
      child: child,
      direction: direction,
      transitionsBuilder: TabTransitionPage.verticalSlideFadeTransition,
    );
  },
  routes: (subPageBuilder, direction) => [
    GoRoute(
      path: "/first",
      pageBuilder: (context, state) => subPageBuilder!(
        context,
        state,
        child: const FirstScreen(),
      ),
    ),
    CustomGoRoute(
      path: "/second",
      pageBuilder: (context, state) => subPageBuilder!(
        context,
        state,
        child: const SecondScreen(),
      ),
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

The `transitionsBuilder` comes with an additional `direction` parameter - useful for slide transitions. You'll need to pass in the `direction` parameter from the `subPageBuilder`.
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
Please don't hesitate to report any issues or feature requests on [GitHub](https://github.com/JakesMD/flutter_go_router_tabs/issues).