import 'package:flutter/material.dart';

class ControllerSection extends StatelessWidget {
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onDown;
  final VoidCallback onRotate;

  const ControllerSection({
    super.key,
    required this.onLeft,
    required this.onRight,
    required this.onDown,
    required this.onRotate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.arrow_left_rounded,
              onPressed: onLeft,
            ),
            _buildControlButton(
              icon: Icons.refresh_rounded,
              iconSize: 32,
              onPressed: onRotate,
            ),
            _buildControlButton(
              icon: Icons.arrow_right_rounded,
              onPressed: onRight,
            ),
          ],
        ),
        _buildControlButton(
          icon: Icons.arrow_drop_down_rounded,
          onPressed: onDown,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double buttonSize = 48,
    double iconSize = 36,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: const Color(0xFF262B39),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            icon,
            size: iconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
