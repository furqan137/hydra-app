import 'package:flutter/material.dart';

class PasswordStrengthBar extends StatelessWidget {
  final double strength;

  const PasswordStrengthBar({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (strength < 0.3) {
      color = Colors.red;
    } else if (strength < 0.7) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: strength,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Password strength indicator',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}
