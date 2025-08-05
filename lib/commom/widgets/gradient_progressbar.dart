import 'package:flutter/material.dart';

class GradientProgressBar extends StatefulWidget {
  final double value; // From 0.0 to 1.0
  final double height;
  final BorderRadius borderRadius;
  final Duration duration;

  const GradientProgressBar({
    super.key,
    required this.value,
    this.height = 6.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<GradientProgressBar> createState() => _GradientProgressBarState();
}

class _GradientProgressBarState extends State<GradientProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value.clamp(0.0, 1.0);

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: _oldValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant GradientProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.value.clamp(0.0, 1.0);

    if (newValue != _oldValue) {
      _controller.reset();
      _animation = Tween<double>(
        begin: _oldValue,
        end: newValue,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward();

      _oldValue = newValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Gradient _getGradient(double value) {
    if (value > 0.8) {
      return const LinearGradient(
        colors: [Colors.blue, Colors.orange, Colors.red],
        stops: [0.5, 0.8, 1],
      );
    } else if (value > 0.5) {
      return const LinearGradient(
        colors: [Colors.blue, Colors.orange],
        stops: [0.5, 1],
      );
    } else {
      return const LinearGradient(
        colors: [Colors.blue, Colors.blueAccent],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade100,
        borderRadius: widget.borderRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRRect(
            borderRadius: widget.borderRadius,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final value = _animation.value;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: constraints.maxWidth * value,
                    decoration: BoxDecoration(
                      gradient: _getGradient(value),
                      borderRadius: widget.borderRadius,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
