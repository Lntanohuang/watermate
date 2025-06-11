import 'package:flutter/material.dart';

/// 饮水进度圆圈绘制器
class WaterProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  WaterProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 绘制背景圆圈
    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius - 1, backgroundPaint);

    // 绘制进度圆圈（从下往上填充）
    if (progress > 0) {
      final progressPaint =
          Paint()
            ..color = progressColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round;

      // 计算弧度，从底部开始（-π/2 + π = π/2），顺时针绘制
      final startAngle = 3 * 3.14159 / 2; // 从底部开始
      final sweepAngle = 2 * 3.14159 * progress; // 根据进度计算弧度

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 1),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! WaterProgressPainter ||
        oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}
