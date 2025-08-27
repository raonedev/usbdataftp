import 'package:flutter/material.dart';

class AnimatedTurnOnButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  const AnimatedTurnOnButton({super.key, required this.onPressed,this.text='Turn on'});

  @override
  State<AnimatedTurnOnButton> createState() => _AnimatedTurnOnButtonState();
}

class _AnimatedTurnOnButtonState extends State<AnimatedTurnOnButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.01).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              padding: EdgeInsets.all(12), // space for border
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(colors: [
                  Colors.blue,
                  Colors.purple,
                ])
              ),
              alignment: Alignment.center,
              child: Text(
                widget.text,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
    );
  }
}

