import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double height;
  final Gradient? gradient;
  final VoidCallback? onPressed;
  final Widget child;

  const MyElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius,
    this.width,
    this.height = 44.0,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(8);
    final isDisabled = onPressed == null;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade300])
            : (gradient ?? LinearGradient(colors: [Colors.cyan, Colors.purple])),
        borderRadius: borderRadius,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          surfaceTintColor: Colors.transparent, // avoid splash color on disabled
        ),
        child: child,
      ),
    );
  }
}
