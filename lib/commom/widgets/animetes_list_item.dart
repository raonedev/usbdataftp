import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const AnimatedListItem({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _blur;
  bool _played = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

//     _scale = TweenSequence<double>([
//   TweenSequenceItem(
//     tween: Tween(begin: 0.9, end: 1.05)
//         .chain(CurveTween(curve: Curves.easeOut)),
//     weight: 60,
//   ),
//   TweenSequenceItem(
//     tween: Tween(begin: 1.05, end: 0.95)
//         .chain(CurveTween(curve: Curves.easeIn)),
//     weight: 40,
//   ),
//   TweenSequenceItem(
//     tween: Tween(begin: 0.95, end: 1.0)
//         .chain(CurveTween(curve: Curves.easeInOut)),
//     weight: 40,
//   ),
// ]).animate(_controller);
    _scale =Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _blur = Tween<double>(begin: 8, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _start();
  }

  Future<void> _start() async {
    if (_played) return;
    _played = true;
    await Future.delayed(widget.delay);
    if (mounted) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.scale(
            scale: _scale.value,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: _blur.value,
                sigmaY: _blur.value,
              ),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
