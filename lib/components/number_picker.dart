import 'package:flutter/material.dart';

/// 带刻度的数字选择器组件
/// 允许用户通过水平滑动选择一个数值范围内的数字
class TickNumberPicker extends StatefulWidget {
  /// 最小可选值
  final int minValue;

  /// 最大可选值
  final int maxValue;

  /// 初始选中值
  final int initialValue;

  /// 值变化时的回调函数
  final ValueChanged<int> onChanged;

  /// 显示的单位文本
  final String unit;

  /// 主要颜色（用于高亮选中项）
  final Color? primaryColor;

  /// 次要颜色（用于未选中项）
  final Color? secondaryColor;

  /// 组件高度
  final double height;

  const TickNumberPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    required this.onChanged,
    this.unit = '',
    this.primaryColor,
    this.secondaryColor,
    this.height = 140,
  });

  @override
  State<TickNumberPicker> createState() => _TickNumberPickerState();
}

/// TickNumberPicker的状态类
/// 管理数字选择器的滚动和值选择逻辑
class _TickNumberPickerState extends State<TickNumberPicker> {
  /// 滚动控制器
  late ScrollController _scrollController;

  /// 当前选中的值
  late int _selectedValue;

  /// 是否正在拖动标志
  bool _isDragging = false;

  /// 是否正在调整到最近刻度标志，防止递归调用
  bool _isSnapping = false;

  /// 刻度间距（单位像素）
  final double _itemExtent = 7.0;

  /// 初始化状态
  /// 设置初始选中值和滚动控制器
  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _scrollController = ScrollController(
      initialScrollOffset: (_selectedValue - widget.minValue) * _itemExtent,
    );
    _scrollController.addListener(_updateValueFromScroll);
  }

  /// 当widget更新时调用
  /// 如果初始值变化，更新选中值并滚动到对应位置
  @override
  void didUpdateWidget(TickNumberPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _selectedValue) {
      _selectedValue = widget.initialValue;
      _animateToValue(_selectedValue);
    }
  }

  /// 释放资源
  /// 移除滚动监听器并释放控制器
  @override
  void dispose() {
    _scrollController.removeListener(_updateValueFromScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 根据滚动位置更新选中值
  /// 当用户拖动滚动时调用
  void _updateValueFromScroll() {
    if (!_isDragging) return;

    final double offset = _scrollController.offset;
    final int newValue = widget.minValue + (offset / _itemExtent).round();

    // 确保值在范围内
    final int clampedValue = newValue.clamp(widget.minValue, widget.maxValue);

    if (clampedValue != _selectedValue) {
      setState(() {
        _selectedValue = clampedValue;
      });
      widget.onChanged(_selectedValue);
    }
  }

  /// 滚动停止时自动对齐到最近的刻度值
  void _snapToNearestValue() {
    // 如果已经在调整中，不再重复调用
    if (_isSnapping) return;

    // 设置标志，防止递归调用
    _isSnapping = true;

    final double targetOffset =
        (_selectedValue - widget.minValue) * _itemExtent;

    _scrollController
        .animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        )
        .then((_) {
          // 动画完成后重置标志
          _isSnapping = false;
        });
  }

  /// 动画滚动到指定值
  void _animateToValue(int value) {
    final double targetOffset = (value - widget.minValue) * _itemExtent;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  /// 构建数字选择器UI
  @override
  Widget build(BuildContext context) {
    final int itemCount = widget.maxValue - widget.minValue + 1;
    final double screenWidth = MediaQuery.of(context).size.width;

    // 获取颜色
    final Color primaryColor = const Color.fromARGB(255, 68, 179, 223);
    final Color secondaryColor = const Color(0xFF79C1DE);

    return SizedBox(
      height: widget.height,
      width: screenWidth,
      child: Stack(
        children: [
          // 刻度和数字列表
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  _isDragging = true;
                } else if (notification is ScrollEndNotification) {
                  _isDragging = false;
                  // 避免在已经在调整中的情况下重复调用
                  if (!_isSnapping) {
                    _snapToNearestValue();
                  }
                }
                return true;
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: itemCount,
                itemExtent: _itemExtent,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth / 2 - _itemExtent / 2,
                ),
                itemBuilder: (context, index) {
                  final int value = widget.minValue + index;
                  final bool isSelected = value == _selectedValue;
                  final bool isMajorTick = value % 5 == 0;
                  return SizedBox(
                    height: widget.height,
                    child: Column(
                      children: [
                        // 居中对齐部分，包含刻度线
                        SizedBox(
                          height: widget.height - 40, // 预留足够下方空间给数字
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 刻度线
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height:
                                    isSelected ? 30 : (isMajorTick ? 20 : 10),
                                width: isSelected ? 5 : (isMajorTick ? 3 : 2),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? primaryColor
                                          : (isMajorTick
                                              ? secondaryColor
                                              : secondaryColor.withOpacity(
                                                0.5,
                                              )),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 数字标注
                        SizedBox(
                          height: 40,
                          width: 60,
                          child: Center(
                            child:
                                value % 10 == 0
                                    ? Text(
                                      value.toString(),
                                      style: TextStyle(
                                        
                                        color:
                                            isSelected
                                                ? primaryColor
                                                : secondaryColor,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                      ),
                                      textDirection: TextDirection.ltr,
                                    )
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // 中心选择框
          Positioned(
            left: screenWidth / 2 - 25,
            top: 0,
            child: Container(
              height: 30,
              width: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF79C1DE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_selectedValue',
                      style: const TextStyle(
                        
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'kg',
                      style: TextStyle( color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
