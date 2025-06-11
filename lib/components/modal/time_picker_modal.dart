import 'package:flutter/material.dart';
import 'package:watermate/components/modal/modal_base.dart';

/// 时间选择器模态框
class TimePickerModal extends StatefulWidget {
  final TimeOfDay? initialTime;
  // final String title;
  final String? leftButtonText;
  final String? rightButtonText;

  const TimePickerModal({
    super.key,
    this.initialTime,
    // this.title = 'Select Time',
    this.leftButtonText = 'Cancel',
    this.rightButtonText = 'Confirm',
  });

  /// 显示时间选择器
  static Future<TimeOfDay?> show(
    BuildContext context, {
    TimeOfDay? initialTime,
    String title = 'Select Time',
    String? leftButtonText = 'Cancel',
    String? rightButtonText = 'Confirm',
  }) async {
    return await showDialog<TimeOfDay>(
      context: context,
      builder:
          (context) => TimePickerModal(
            initialTime: initialTime,
            // title: title,
            leftButtonText: leftButtonText,
            rightButtonText: rightButtonText,
          ),
    );
  }

  @override
  State<TimePickerModal> createState() => _TimePickerModalState();
}

class _TimePickerModalState extends State<TimePickerModal> {
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAM;

  @override
  void initState() {
    super.initState();
    final time = widget.initialTime ?? TimeOfDay.now();
    _selectedHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    _selectedMinute = time.minute;
    _isAM = time.period == DayPeriod.am;
  }

  TimeOfDay get _selectedTime {
    int hour24 = _selectedHour;
    if (_isAM && _selectedHour == 12) {
      hour24 = 0;
    } else if (!_isAM && _selectedHour != 12) {
      hour24 = _selectedHour + 12;
    }
    return TimeOfDay(hour: hour24, minute: _selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      // title: widget.title,
      leftButtonText: widget.leftButtonText,
      rightButtonText: widget.rightButtonText,
      onLeftPressed: () => Navigator.of(context).pop(),
      onRightPressed: () => Navigator.of(context).pop(_selectedTime),
      content: SizedBox(
        height: 200,
        child: Row(
          children: [
            // 小时选择器
            Expanded(
              child: _buildScrollPicker(
                items: List.generate(12, (index) => (index + 1).toString()),
                selectedIndex: _selectedHour - 1,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedHour = index + 1;
                  });
                },
              ),
            ),

            // 分钟选择器
            Expanded(
              child: _buildScrollPicker(
                items: List.generate(
                  60,
                  (index) => index.toString().padLeft(2, '0'),
                ),
                selectedIndex: _selectedMinute,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedMinute = index;
                  });
                },
              ),
            ),

            // AM/PM 选择器
            Expanded(
              child: _buildScrollPicker(
                items: ['AM', 'PM'],
                selectedIndex: _isAM ? 0 : 1,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _isAM = index == 0;
                  });
                },
              ),
            ),
          ],
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
                color: Colors.grey[200],
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
