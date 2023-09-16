import "package:flutter/widgets.dart";
import "package:go_router/go_router.dart";

import "typedefs.dart";

/// A Page with custom transition functionality.
///
/// It's an extension on GoRouter's [CustomTransitionPage] but allows you to
/// control the curve and direction of a transition.
class TabTransitionPage extends CustomTransitionPage {
  /// The curve to use when a page is transitioning onto the stage.
  final Curve transitionInCurve;

  /// The curve to use when a page is transitioning off the stage.
  final Curve transitionOutCurve;

  /// Slides both pages at the same speed and in the same direction.
  static Widget _pushTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    TextDirection direction,
    Axis axis,
    Widget child,
  ) {
    final slideTween = Tween<Offset>(
      begin: axis == Axis.horizontal
          ? direction == TextDirection.ltr
              ? const Offset(-1, 0)
              : const Offset(1, 0)
          : direction == TextDirection.ltr
              ? const Offset(0, -1)
              : const Offset(0, 1),
      end: const Offset(0, 0),
    );
    final secondarySlideTween = Tween<Offset>(
      begin: const Offset(0, 0),
      end: axis == Axis.horizontal
          ? direction == TextDirection.ltr
              ? const Offset(1, 0)
              : const Offset(-1, 0)
          : direction == TextDirection.ltr
              ? const Offset(0, 1)
              : const Offset(0, -1),
    );
    return SlideTransition(
      position: slideTween.animate(animation),
      child: SlideTransition(
        position: secondarySlideTween.animate(secondaryAnimation),
        child: child,
      ),
    );
  }

  /// Slides the incoming page over the outgoing page and slides the outgoing
  /// page at half the speed in the same direction while fading it out.
  static Widget _slideFadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    TextDirection direction,
    Axis axis,
    Widget child,
  ) {
    final slideTween = Tween<Offset>(
      begin: axis == Axis.horizontal
          ? direction == TextDirection.ltr
              ? const Offset(-1, 0)
              : const Offset(1, 0)
          : direction == TextDirection.ltr
              ? const Offset(0, -1)
              : const Offset(0, 1),
      end: const Offset(0, 0),
    );
    final secondarySlideTween = Tween<Offset>(
      begin: const Offset(0, 0),
      end: axis == Axis.horizontal
          ? direction == TextDirection.ltr
              ? const Offset(0.5, 0)
              : const Offset(-0.5, 0)
          : direction == TextDirection.ltr
              ? const Offset(0, 0.5)
              : const Offset(0, -0.5),
    );
    final secondaryFadeTween = Tween<double>(begin: 1, end: 0);

    return SlideTransition(
      position: slideTween.animate(animation),
      child: SlideTransition(
        position: secondarySlideTween.animate(secondaryAnimation),
        child: FadeTransition(
          opacity: secondaryFadeTween.animate(secondaryAnimation),
          child: child,
        ),
      ),
    );
  }

  /// Slides both pages at the same speed in the horizontal direction.
  static Widget horizontalPushTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    TextDirection direction,
    Widget child,
  ) {
    return _pushTransition(
      context,
      animation,
      secondaryAnimation,
      direction,
      Axis.horizontal,
      child,
    );
  }

  /// Slides both pages at the same speed in the vertical direction.
  static Widget verticalPushTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    TextDirection direction,
    Widget child,
  ) {
    return _pushTransition(
      context,
      animation,
      secondaryAnimation,
      direction,
      Axis.vertical,
      child,
    );
  }

  /// Slides the incoming page over the outgoing page and slides the outgoing
  /// page at half the speed in the same horizontal direction while fading it
  /// out.
  static Widget horizontalSlideFadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    TextDirection direction,
    Widget child,
  ) {
    return _slideFadeTransition(
      context,
      animation,
      secondaryAnimation,
      direction,
      Axis.horizontal,
      child,
    );
  }

  /// Slides the incoming page over the outgoing page and slides the outgoing
  /// page at half the speed in the same vertical direction while fading it
  /// out.
  static Widget verticalSlideFadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    TextDirection direction,
    Widget child,
  ) {
    return _slideFadeTransition(
      context,
      animation,
      secondaryAnimation,
      direction,
      Axis.vertical,
      child,
    );
  }

  /// A default direction for the transitions builder.
  static TextDirection defaultDirection() => TextDirection.ltr;

  /// Creates a Page with custom transition functionality.
  @Deprecated(
      "Use go_router's `StatefulShellRoute` instead (example: https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart).")
  TabTransitionPage({
    required super.key,
    required super.child,
    TextDirection Function() direction = TabTransitionPage.defaultDirection,
    TabTransitionsBuilder transitionsBuilder =
        TabTransitionPage.horizontalSlideFadeTransition,
    Duration transitionInDuration = const Duration(milliseconds: 300),
    Duration transitionOutDuration = const Duration(milliseconds: 300),
    this.transitionInCurve = Curves.easeOut,
    this.transitionOutCurve = Curves.easeOut,
    super.maintainState,
    super.fullscreenDialog,
    super.opaque,
    super.barrierDismissible,
    super.barrierColor,
    super.barrierLabel,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
          transitionDuration: transitionInDuration,
          reverseTransitionDuration: transitionOutDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return transitionsBuilder(
              context,
              CurvedAnimation(parent: animation, curve: transitionInCurve),
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: transitionOutCurve,
              ),
              direction(),
              child,
            );
          },
        );
}
