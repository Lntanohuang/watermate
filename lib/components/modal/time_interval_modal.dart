import 'package:flutter/material.dart';
import 'package:watermate/components/modal/modal_base.dart';

/// 时间间隔选择器模态框
class TimeIntervalModal extends StatefulWidget {
  final int? initialInterval;
  // final String title;
  final String? leftButtonText;
  final String? rightButtonText;
  final List<int> intervals;

  const TimeIntervalModal({
    super.key,
    this.initialInterval,
    // this.title = 'Time Interval',
    this.leftButtonText = 'Cancel',
    this.rightButtonText = 'Confirm',
    this.intervals = const [15, 30, 60, 90, 180],
  });

  /// 显示时间间隔选择器
  static Future<int?> show(
    BuildContext context, {
    int? initialInterval,
    String title = 'Time Interval',
    String? leftButtonText = 'Cancel',
    String? rightButtonText = 'Confirm',
    List<int> intervals = const [15, 30, 60, 90, 180],
  }) async {
    return await showDialog<int>(
      context: context,
      builder:
          (context) => TimeIntervalModal(
            initialInterval: initialInterval,
            // title: title,
            leftButtonText: leftButtonText,
            rightButtonText: rightButtonText,
            intervals: intervals,
          ),
    );
  }

  @override
  State<TimeIntervalModal> createState() => _TimeIntervalModalState();
}

class _TimeIntervalModalState extends State<TimeIntervalModal> {
  late int _selectedInterval;

  @override
  void initState() {
    super.initState();
    _selectedInterval = widget.initialInterval ?? widget.intervals.first;
    // 确保初始值在可选列表中
    if (!widget.intervals.contains(_selectedInterval)) {
      _selectedInterval = widget.intervals.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      // title: widget.title,
      leftButtonText: widget.leftButtonText,
      rightButtonText: widget.rightButtonText,
      onLeftPressed: () => Navigator.of(context).pop(),
      onRightPressed: () => Navigator.of(context).pop(_selectedInterval),
      content: SizedBox(
        height: 200,
        child: _buildScrollPicker(
          items:
              widget.intervals
                  .map((interval) => '${interval} minutes')
                  .toList(),
          selectedIndex: widget.intervals.indexOf(_selectedInterval),
          onSelectedItemChanged: (index) {
            setState(() {
              _selectedInterval = widget.intervals[index];
            });
          },
        ),
      ),
    );
  }

  Widget _buildScrollPicker({
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return Container(
      height: 200,
      child: Stack(
        children: [
          // 选中项背景
          Positioned(
            top: 80,
            left: 8,
            right: 8,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // 滚动选择器
          ListWheelScrollView.useDelegate(
            itemExtent: 40,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelectedItemChanged,
            controller: FixedExtentScrollController(initialItem: selectedIndex),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (context, index) {
                final isSelected = index == selectedIndex;
                return Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    items[index],
                    style: TextStyle(
                      fontSize: isSelected ? 18 : 16,
                      fontWeight:
                          isSelected ? FontWeight.w400 : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
