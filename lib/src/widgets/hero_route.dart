import 'package:flutter/material.dart';

/// A [PageRoute] with a semi transparent background.
///
/// Similar to calling [showDialog] except it can be used with a [Navigator] to
/// show a [Hero] animation.
class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({
    required this.builder,
    this.onBackgroundTap,
  }) : super();

  final WidgetBuilder builder;

  /// Called when the background is tapped.
  final VoidCallback? onBackgroundTap;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget child = builder(context);
    final Widget result = Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: child,
    );
    return result;
  }
}
