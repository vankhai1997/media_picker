import 'package:flutter/material.dart';

class CustomDismissible extends StatefulWidget {
  const CustomDismissible({
    required this.child,
    this.onDismissed,
    required this.onDragging,
    this.dismissThreshold = 0.2,
    this.enabled = true,
  });

  final Widget child;
  final double dismissThreshold;
  final Function() onDragging;
  final VoidCallback? onDismissed;
  final bool enabled;

  @override
  _CustomDismissibleState createState() => _CustomDismissibleState();
}

class _CustomDismissibleState extends State<CustomDismissible>
    with SingleTickerProviderStateMixin {
  late AnimationController _animateController;
  late Animation<Offset> _moveAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Decoration> _opacityAnimation;

  double _dragExtent = 0;
  bool _dragUnderway = false;

  bool get _isActive => _dragUnderway || _animateController.isAnimating;

  @override
  void initState() {
    super.initState();

    _animateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _updateMoveAnimation();
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    //   SystemUiOverlay.top,
    //   SystemUiOverlay.bottom,
    // ]);
    _animateController.dispose();

    super.dispose();
  }

  void _updateMoveAnimation() {
    final double end = _dragExtent.sign;

    _moveAnimation = _animateController.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: Offset(0, end),
      ),
    );

    _scaleAnimation = _animateController.drive(Tween<double>(
      begin: 1,
      end: 0.5,
    ));

    _opacityAnimation = DecorationTween(
      begin: const BoxDecoration(
        color: Color(0x00000000),
      ),
      end: const BoxDecoration(
        color: Color(0x00000000),
      ),
    ).animate(_animateController);
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;

    widget.onDragging();

    if (_animateController.isAnimating) {
      _dragExtent =
          _animateController.value * context.size!.height * _dragExtent.sign;
      _animateController.stop();
    } else {
      _dragExtent = 0.0;
      _animateController.value = 0.0;
    }
    setState(_updateMoveAnimation);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isActive || _animateController.isAnimating) {
      return;
    }

    final double delta = details.primaryDelta!;
    final double oldDragExtent = _dragExtent;

    if (_dragExtent + delta < 0) {
      _dragExtent += delta;
    } else if (_dragExtent + delta > 0) {
      _dragExtent += delta;
    }

    if (oldDragExtent.sign != _dragExtent.sign) {
      setState(_updateMoveAnimation);
    }

    if (!_animateController.isAnimating) {
      _animateController.value = _dragExtent.abs() / context.size!.height;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isActive || _animateController.isAnimating) {
      return;
    }

    _dragUnderway = false;

    if (_animateController.isCompleted) {
      return;
    }

    if (!_animateController.isDismissed) {
      // if the dragged value exceeded the dismissThreshold, call onDismissed
      // else animate back to initial position.
      if (_animateController.value > widget.dismissThreshold) {
        // SystemChrome.setEnabledSystemUIMode(SystemUiMode.ma, overlays: [
        //   SystemUiOverlay.top,
        //   SystemUiOverlay.bottom,
        // ]);
        widget.onDismissed?.call();
      } else {
        _animateController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = DecoratedBoxTransition(
      decoration: _opacityAnimation,
      child: SlideTransition(
        position: _moveAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: widget.enabled ? _handleDragStart : null,
      onVerticalDragUpdate: widget.enabled ? _handleDragUpdate : null,
      onVerticalDragEnd: widget.enabled ? _handleDragEnd : null,
      child: content,
    );
  }
}
