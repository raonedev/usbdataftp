import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GradientProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0

  const GradientProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return SfLinearGauge(
      minimum: 0.0,
      maximum: 1.0,
      showLabels: false,
      showTicks: false,
      
      axisTrackStyle:  LinearAxisTrackStyle(
        thickness: 6,
        edgeStyle: LinearEdgeStyle.bothCurve,
        color: Colors.grey[300],
      ),

      barPointers: [
        LinearBarPointer(
          value: value.clamp(0.0, 1.0),
          thickness: 6,
          edgeStyle: LinearEdgeStyle.bothCurve,
          shaderCallback: (bounds) {
            // Dynamic gradient based on value
            if (value > 0.8) {
              return const LinearGradient(
                colors: [Colors.blue, Colors.orange, Colors.red],
                stops: [0.5, 0.8, 1.0],
              ).createShader(bounds);
            } else if (value > 0.5) {
              return const LinearGradient(
                colors: [Colors.blue, Colors.orange],
                stops: [0.5, 1.0],
              ).createShader(bounds);
            } else {
              return const LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
              ).createShader(bounds);
            }
          },
          animationDuration: 1300,
          enableAnimation: true,
        ),
      ],
      
    );
  }
}
