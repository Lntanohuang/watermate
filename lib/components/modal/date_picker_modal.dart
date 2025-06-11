import 'package:flutter/material.dart';
import 'package:watermate/components/modal/modal_base.dart';

/// 日期选择器模态框
class DatePickerModal extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  // final String title;
  final String? leftButtonText;
  final String? rightButtonText;

  const DatePickerModal({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    // this.title = 'Select Date',
    this.leftButtonText = 'Cancel',
    this.rightButtonText = 'Confirm',
  });

  /// 显示日期选择器
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String title = 'Select Date',
    String? leftButtonText = 'Cancel',
    String? rightButtonText = 'Confirm',
  }) async {
    return await showDialog<DateTime>(
      context: context,
      builder:
          (context) => DatePickerModal(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            // title: title,
            leftButtonText: leftButtonText,
            rightButtonText: rightButtonText,
          ),
    );
  }

  @override
  State<DatePickerModal> createState() => _DatePickerModalState();
}

class _DatePickerModalState extends State<DatePickerModal> {
  late DateTime _selectedDate;
  late DateTime _firstDate;
  late DateTime _lastDate;

  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _firstDate = widget.firstDate ?? DateTime(2000);
    _lastDate = widget.lastDate ?? DateTime(2100);

    _selectedYear = _selectedDate.year;
    _selectedMonth = _selectedDate.month;
    _selectedDay = _selectedDate.day;
  }

  List<int> get _years {
    return List.generate(
      _lastDate.year - _firstDate.year + 1,
      (index) => _firstDate.year + index,
    );
  }

  List<int> get _days {
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    return List.generate(daysInMonth, (index) => index + 1);
  }

  void _updateSelectedDate() {
    // 确保选中的日期在当月有效范围内
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    if (_selectedDay > daysInMonth) {
      _selectedDay = daysInMonth;
    }

    _selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      // title: widget.title,
      leftButtonText: widget.leftButtonText,
      rightButtonText: widget.rightButtonText,
      onLeftPressed: () => Navigator.of(context).pop(),
      onRightPressed: () => Navigator.of(context).pop(_selectedDate),
      content: SizedBox(
        height: 200,
        child: Row(
          children: [
            // 月份选择器
            Expanded(
              flex: 2,
              child: _buildScrollPicker(
                items: _months,
                selectedIndex: _selectedMonth - 1,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedMonth = index + 1;
                    _updateSelectedDate();
                  });
                },
              ),
            ),

            // 日期选择器
            Expanded(
              child: _buildScrollPicker(
                items: _days.map((day) => day.toString()).toList(),
                selectedIndex: _selectedDay - 1,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedDay = index + 1;
                    _updateSelectedDate();
                  });
                },
              ),
            ),

            // 年份选择器
            Expanded(
              child: _buildScrollPicker(
                items: _years.map((year) => year.toString()).toList(),
                selectedIndex: _years.indexOf(_selectedYear),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedYear = _years[index];
                    _updateSelectedDate();
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
            left: 4,
            right: 4,
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
            controller: FixedExtentScrollController(
              initialItem: selectedIndex.clamp(0, items.length - 1),
            ),
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
                      fontSize: isSelected ? 16 : 14,
                      fontWeight:
                          isSelected ? FontWeight.w400 : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
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
