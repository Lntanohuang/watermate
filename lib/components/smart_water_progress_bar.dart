import 'package:flutter/material.dart';
import 'package:watermate/database/database_manager.dart';
import 'package:watermate/utils/user_setup_manager.dart';

/// 智能水量进度条组件
/// 根据用户的性别、体重、运动量智能计算默认目标饮水量
class SmartDraggableWaterProgressBar extends StatefulWidget {
  final int? initialValue; // 如果提供了初始值，则使用它；否则使用智能计算的值
  final int minValue;
  final int maxValue;
  final double barHeight;
  final Color barColor;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final ValueChanged<int>? onChanged;

  const SmartDraggableWaterProgressBar({
    super.key,
    this.initialValue,
    this.minValue = 1000,
    this.maxValue = 5000,
    this.barHeight = 16,
    this.barColor = const Color(0xFF52ACD1),
    this.backgroundColor = const Color(0xFFE5F2F8),
    this.textStyle,
    this.onChanged,
  });

  @override
  State<SmartDraggableWaterProgressBar> createState() =>
      _SmartDraggableWaterProgressBarState();
}

class _SmartDraggableWaterProgressBarState
    extends State<SmartDraggableWaterProgressBar> {
  late double _percent;
  late int _currentValue;
  late int _smartRecommendedValue; // 保存智能推荐的值
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeValue();
  }

  /// 初始化值：优先使用提供的初始值，否则智能计算
  Future<void> _initializeValue() async {
    int targetValue;
    int smartValue;

    if (widget.initialValue != null) {
      // 使用提供的初始值
      targetValue = widget.initialValue!;
      // 但仍然计算智能推荐值用于按钮功能
      smartValue = await _calculateSmartTargetWaterIntake();
    } else {
      // 智能计算目标饮水量
      smartValue = await _calculateSmartTargetWaterIntake();
      targetValue = smartValue;
    }

    setState(() {
      _currentValue = targetValue.clamp(widget.minValue, widget.maxValue);
      _smartRecommendedValue = smartValue.clamp(
        widget.minValue,
        widget.maxValue,
      ); // 保存智能推荐值
      _percent =
          (widget.maxValue == widget.minValue)
              ? 0
              : ((_currentValue - widget.minValue) /
                      (widget.maxValue - widget.minValue))
                  .clamp(0.0, 1.0);
      _isLoading = false;
    });

    // 通知父组件初始值
    if (widget.onChanged != null) {
      widget.onChanged!(_currentValue);
    }
  }

  /// 智能计算目标饮水量
  Future<int> _calculateSmartTargetWaterIntake() async {
    try {
      // 首先尝试从数据库获取用户数据
      final db = await DatabaseManager.instance.database;
      final user = await db.userDao.getUser();

      if (user != null) {
        // 用户已存在，使用数据库中的目标饮水量
        return user.targetWaterIntake;
      } else {
        // 用户不存在，使用UserSetupManager中的临时数据计算
        return _calculateFromUserSetup();
      }
    } catch (e) {
      print('获取用户数据失败，使用默认计算: $e');
      return _calculateFromUserSetup();
    }
  }

  /// 根据UserSetupManager中的数据计算目标饮水量
  int _calculateFromUserSetup() {
    final userSetup = UserSetupManager();

    // 获取用户设置的数据
    final double weight = userSetup.weight;
    final String exerciseVolume = userSetup.exerciseVolume;
    final String gender = userSetup.gender;

    // 直接调用DatabaseManager的计算方法，保持一致性
    final int targetIntake = DatabaseManager.calculateTargetWaterIntake(
      weight: weight,
      gender: gender,
      exerciseVolume: exerciseVolume,
    );

    print(
      '智能计算目标饮水量: 体重${weight}kg, 性别$gender, 运动量$exerciseVolume = ${targetIntake}ml',
    );

    return targetIntake;
  }

  void _updateValue(Offset localPosition, double width) {
    double percent = (localPosition.dx / width).clamp(0.0, 1.0);
    int value =
        (percent * (widget.maxValue - widget.minValue)).round() +
        widget.minValue;

    setState(() {
      _percent = percent;
      _currentValue = value;
    });

    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  /// 应用智能推荐值
  void _applySmartRecommendation() {
    setState(() {
      _currentValue = _smartRecommendedValue;
      _percent =
          (widget.maxValue == widget.minValue)
              ? 0
              : ((_smartRecommendedValue - widget.minValue) /
                      (widget.maxValue - widget.minValue))
                  .clamp(0.0, 1.0);
    });

    if (widget.onChanged != null) {
      widget.onChanged!(_smartRecommendedValue);
    }

    // 显示提示信息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已应用智能推荐值: ${_smartRecommendedValue}ml'),
        backgroundColor: widget.barColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(widget.barColor),
              ),
              const SizedBox(height: 8),
              Text(
                '正在计算推荐饮水量...',
                style: TextStyle( color: widget.barColor),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 显示当前值和推荐标识
            Column(
              children: [
                Text(
                  '${_currentValue}ml',
                  style:
                      widget.textStyle ??
                      const TextStyle(
                        
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF79C1DE),
                      ),
                ),
                // 显示智能推荐按钮（当前值不等于推荐值时）
                if (_currentValue != _smartRecommendedValue)
                  const SizedBox(height: 8),
                if (_currentValue != _smartRecommendedValue) // 智能推荐按钮
                  GestureDetector(
                    onTap: _applySmartRecommendation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.barColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.barColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: widget.barColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '智能推荐',
                            style: TextStyle(
                              
                              color: widget.barColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // 进度条
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                _updateValue(details.localPosition, width);
              },
              onTapDown: (details) {
                _updateValue(details.localPosition, width);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.barHeight / 2),
                child: Stack(
                  children: [
                    // 背景
                    Container(
                      height: widget.barHeight,
                      color: widget.backgroundColor,
                    ),
                    // 进度
                    Container(
                      height: widget.barHeight,
                      width: width * _percent,
                      color: widget.barColor,
                    ),
                    // 滑块
                    Positioned(
                      left: (width * _percent) - (widget.barHeight * 0.6),
                      top: -(widget.barHeight * 0.2),
                      child: Container(
                        width: widget.barHeight * 1.2,
                        height: widget.barHeight * 1.2,
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

            // 范围提示
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.minValue}ml',
                  style: TextStyle( color: widget.barColor),
                ),
                Text(
                  '${widget.maxValue}ml',
                  style: TextStyle( color: widget.barColor),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
