import 'package:flutter/material.dart';

class GradientProgressBar extends StatelessWidget {
  final double value; // From 0.0 to 1.0
  final double height;
  final BorderRadius borderRadius;

  const GradientProgressBar({
    super.key,
    required this.value,
    this.height = 10.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);

    // Select gradient
    Gradient gradient;
    if (clampedValue > 0.8) {
      gradient = const LinearGradient(
        colors: [Colors.blue, Colors.orange, Colors.red],
        stops: [
          0.5,
          0.8,
          1,
        ]
      );
    } else if (clampedValue > 0.5) {
      gradient = const LinearGradient(
        colors: [Colors.blue, Colors.orange],
        stops: [
          0.5,
          1
        ]
      );
    } else {
      gradient = const LinearGradient(
        colors: [Colors.blue, Colors.blueAccent],
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade100,
        borderRadius: borderRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRRect(
            borderRadius: borderRadius,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: constraints.maxWidth * clampedValue,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: borderRadius,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
