import 'package:flutter/material.dart';
import 'package:watermate/components/water_progress_painter.dart';
import 'package:watermate/components/basic.dart';

/// 带有饮水进度圆圈的日期组件
class DayWithProgress extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final double progress;

  const DayWithProgress({
    super.key,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 饮水进度圆圈
          SizedBox(
            width: 36,
            height: 36,
            child: CustomPaint(
              painter: WaterProgressPainter(
                progress: progress,
                backgroundColor: themeColor3.withOpacity(0.2),
                progressColor: themeColor3,
              ),
            ),
          ),
          // 日期背景圆圈（用于今日和选中状态）
          if (isToday || isSelected)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade100 : Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
            ),
          // 日期文字
          Text(
            '${day.day}',
            style: TextStyle(
              color:
                  isToday
                      ? Colors.blue
                      : (isSelected ? const Color(0xFF3A4D5C) : Colors.black),
              fontWeight:
                  (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
