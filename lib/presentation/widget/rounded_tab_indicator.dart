import 'package:flutter/material.dart';

class RoundedTabIndicator extends Decoration {
  final Color color;
  final double radius;
  final double height;

  const RoundedTabIndicator({
    required this.color,
    this.radius = 4,
    this.height = 4,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RoundedPainter(this);
  }
}

class _RoundedPainter extends BoxPainter {
  final RoundedTabIndicator decoration;

  _RoundedPainter(this.decoration);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final rect = Offset(
      offset.dx,
      config.size!.height - decoration.height,
    ) &
    Size(config.size!.width, decoration.height);

    final paint = Paint()
      ..color = decoration.color
      ..style = PaintingStyle.fill;

    final rRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(decoration.radius),
    );

    canvas.drawRRect(rRect, paint);
  }
}