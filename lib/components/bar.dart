import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:watermate/pages/record/record.dart';
import 'package:watermate/pages/personal/personal_information.dart';
import 'package:watermate/pages/reminders/reminders.dart';
import 'package:watermate/pages/home/home.dart';
import 'package:watermate/pages/statistics/statistics.dart';
// import 'package:watermate/components/basic.dart';

const Color HomeTopBarIconsColor = Color(0xFF495464);
const double TopBarTextSize = 20.0;
const TextStyle TopBarTextStyle = TextStyle(
  fontSize: TopBarTextSize,
  fontWeight: FontWeight.w500,
  color: HomeTopBarIconsColor,
);

// 顶部导航栏组件
class HomeTopBar extends StatelessWidget {
  final VoidCallback? onRecordPageReturn; // 记录页面返回时的回调

  const HomeTopBar({super.key, this.onRecordPageReturn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: const Color(0xFFF8F9FB),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.person_outline,
              size: 32,
              color: HomeTopBarIconsColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const PersonalInformationPage(),
                ),
              );
            },
          ),
          Text('Leisurely Hydration', style: TopBarTextStyle),
          IconButton(
            icon: Icon(
              Icons.pie_chart_outline,
              size: 32,
              color: HomeTopBarIconsColor,
            ),
            onPressed: () async {
              // 等待RecordPage返回结果
              final result = await Navigator.push<bool>(
                context,
                CupertinoPageRoute(builder: (context) => const RecordPage()),
              );

              // 如果数据发生了变更，调用回调函数刷新Home页面数据
              if (result == true && onRecordPageReturn != null) {
                onRecordPageReturn!();
              }
            },
          ),
        ],
      ),
    );
  }
}

// 底部导航栏组件
class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  const BottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white, // 改为白色背景
        // 添加上方阴影效果
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // 阴影颜色，透明度10%
            offset: const Offset(0, -2), // 向上偏移2像素
            blurRadius: 8, // 模糊半径8像素
            spreadRadius: 0, // 扩散半径0
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomNavItem(
                context,
                'assets/images/png/button_icon/water_icon.png',
                'Water',
                0,
              ),
              _buildBottomNavItem(
                context,
                'assets/images/png/button_icon/reminders_icon.png',
                'Reminders',
                1,
              ),
              _buildBottomNavItem(
                context,
                'assets/images/png/button_icon/statistics_icon.png',
                'Statistics',
                2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    String icon,
    String label,
    int index,
  ) {
    final bool selected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (context) => RemindersPage()),
            );
          } else if (index == 2) {
            // done: 跳转统计页
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (context) => StatisticsPage()),
            );
          }
          // onTap(index);
        },

        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 28, //28
              height: 28,
              color: selected ? const Color(0xFF9EDCFF) : Colors.grey,
              errorBuilder: (context, error, stackTrace) {
                // 如果图标加载失败，显示默认图标
                return Icon(
                  _getDefaultIcon(index),
                  size: 28,
                  color: selected ? const Color(0xFF9EDCFF) : Colors.grey,
                );
              },
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? const Color(0xFF9EDCFF) : Colors.grey,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDefaultIcon(int index) {
    switch (index) {
      case 0:
        return Icons.water_drop_outlined;
      case 1:
        return Icons.notifications_outlined;
      case 2:
        return Icons.bar_chart_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}

// 返回按钮组件
class BackNavBar extends StatelessWidget {
  final VoidCallback? onTap;
  const BackNavBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFB0C4D6), size: 32),
        onPressed:
            onTap ??
            () {
              // 安全的返回操作
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
      ),
    );
  }
}

// 通用顶部导航栏组件
class CommonTopBar extends StatelessWidget {
  final String? title;
  final String? time;
  final VoidCallback? onBack;
  final bool showBackButton;
  // final double? fontSize;
  final Widget? right;
  const CommonTopBar({
    super.key,
    this.title,
    this.time,
    this.onBack,
    this.showBackButton = true,
    // this.fontSize = TopBarTextSize,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          if (showBackButton)
            SizedBox(width: 40, child: BackNavBar(onTap: onBack))
          else
            const SizedBox(height: 48), // 保持布局一致性
          const Spacer(),
          Text(
            title ?? '',
            textAlign: TextAlign.center,
            style: TopBarTextStyle,
          ),
          const Spacer(),
          if (time != null && time!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                time!,
                style: const TextStyle(color: Color(0xFF7BA1B7)),
              ),
            ),
          if (right != null) right!,
        ],
      ),
    );
  }
}

// 可拖动时间范围滑块组件
//TODO: 存入数据库
class DraggableTimeRangeSlider extends StatefulWidget {
  final int startMinutes; // 开始时间（分钟数，从0:00开始计算）
  final int endMinutes; // 结束时间（分钟数，从0:00开始计算）
  final int minTime; // 最小时间（分钟）
  final int maxTime; // 最大时间（分钟）
  final double barHeight;
  final Color barColor;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final Function(int startMinutes, int endMinutes)? onChanged;

  const DraggableTimeRangeSlider({
    super.key,
    this.startMinutes = 300, // 默认5:00 (5*60)
    this.endMinutes = 900, // 默认15:00 (15*60)
    this.minTime = 0, // 0:00
    this.maxTime = 1440, // 24:00
    this.barHeight = 14,
    this.barColor = const Color(0xFF79C1DE),
    this.backgroundColor = const Color(0xFFE5F2F8),
    this.textStyle,
    this.onChanged,
  });

  @override
  State<DraggableTimeRangeSlider> createState() =>
      _DraggableTimeRangeSliderState();
}

class _DraggableTimeRangeSliderState extends State<DraggableTimeRangeSlider> {
  late int _startMinutes;
  late int _endMinutes;
  late double _startPercent;
  late double _endPercent;
  bool _isDraggingStart = false;
  bool _isDraggingEnd = false;

  @override
  void initState() {
    super.initState();
    _startMinutes = widget.startMinutes;
    _endMinutes = widget.endMinutes;
    _updatePercents();
  }

  void _updatePercents() {
    final timeRange = widget.maxTime - widget.minTime;
    _startPercent =
        timeRange == 0
            ? 0
            : ((_startMinutes - widget.minTime) / timeRange).clamp(0.0, 1.0);
    _endPercent =
        timeRange == 0
            ? 1
            : ((_endMinutes - widget.minTime) / timeRange).clamp(0.0, 1.0);
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  void _updateTime(Offset localPosition, double width, bool isStart) {
    double percent = (localPosition.dx / width).clamp(0.0, 1.0);
    int newTime =
        ((percent * (widget.maxTime - widget.minTime)) + widget.minTime)
            .round();

    setState(() {
      if (isStart) {
        _startMinutes = newTime.clamp(
          widget.minTime,
          _endMinutes - 15,
        ); // 至少保持15分钟间隔
      } else {
        _endMinutes = newTime.clamp(
          _startMinutes + 15,
          widget.maxTime,
        ); // 至少保持15分钟间隔
      }
      _updatePercents();
    });

    if (widget.onChanged != null) {
      widget.onChanged!(_startMinutes, _endMinutes);
    }
  }

  bool _isNearSlider(
    Offset position,
    double sliderPosition,
    double sliderSize,
  ) {
    return (position.dx - sliderPosition).abs() <= sliderSize;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double sliderSize = 24;
        final double startPosition = width * _startPercent;
        final double endPosition = width * _endPercent;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${_formatTime(_startMinutes)} - ${_formatTime(_endMinutes)}',
              style:
                  widget.textStyle ??
                  const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF79C1DE),
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onPanStart: (details) {
                final position = details.localPosition;
                if (_isNearSlider(position, startPosition, sliderSize)) {
                  _isDraggingStart = true;
                  _isDraggingEnd = false;
                } else if (_isNearSlider(position, endPosition, sliderSize)) {
                  _isDraggingStart = false;
                  _isDraggingEnd = true;
                } else {
                  _isDraggingStart = false;
                  _isDraggingEnd = false;
                }
              },
              onPanUpdate: (details) {
                if (_isDraggingStart) {
                  _updateTime(details.localPosition, width, true);
                } else if (_isDraggingEnd) {
                  _updateTime(details.localPosition, width, false);
                }
              },
              onPanEnd: (details) {
                _isDraggingStart = false;
                _isDraggingEnd = false;
              },
              onTapDown: (details) {
                final position = details.localPosition;
                if (_isNearSlider(position, startPosition, sliderSize)) {
                  _updateTime(position, width, true);
                } else if (_isNearSlider(position, endPosition, sliderSize)) {
                  _updateTime(position, width, false);
                }
              },
              child: Container(
                height: 35,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 背景滑轨
                    Container(
                      height: widget.barHeight,
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
                        borderRadius: BorderRadius.circular(
                          widget.barHeight / 2,
                        ),
                      ),
                    ),
                    // 选中范围
                    Positioned(
                      left: startPosition,
                      width: endPosition - startPosition,
                      child: Container(
                        height: widget.barHeight,
                        decoration: BoxDecoration(
                          color: widget.barColor,
                          borderRadius: BorderRadius.circular(
                            widget.barHeight / 2,
                          ),
                        ),
                      ),
                    ),
                    // 开始时间滑块
                    Positioned(
                      left: startPosition - sliderSize / 2,
                      child: Container(
                        width: sliderSize,
                        height: sliderSize,
                        decoration: BoxDecoration(
                          color: widget.barColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.barColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 结束时间滑块
                    Positioned(
                      left: endPosition - sliderSize / 2,
                      child: Container(
                        width: sliderSize,
                        height: sliderSize,
                        decoration: BoxDecoration(
                          color: widget.barColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.barColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
