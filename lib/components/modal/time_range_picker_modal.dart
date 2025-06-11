import 'package:flutter/material.dart';
import 'modal_base.dart';
import 'package:watermate/utils/toast_utils.dart';

/// 时间范围选择器模态框
class TimeRangePickerModal extends StatefulWidget {
  final int initialStartHour;
  final int initialStartMinute;
  final int initialEndHour;
  final int initialEndMinute;
  final String title;
  final String leftButtonText;
  final String rightButtonText;

  const TimeRangePickerModal({
    super.key,
    required this.initialStartHour,
    required this.initialStartMinute,
    required this.initialEndHour,
    required this.initialEndMinute,
    this.title = '选择时间范围',
    this.leftButtonText = 'Cancel',
    this.rightButtonText = 'Confirm',
  });

  /// 显示时间范围选择器
  static Future<Map<String, int>?> show(
    BuildContext context, {
    required int initialStartHour,
    required int initialStartMinute,
    required int initialEndHour,
    required int initialEndMinute,
    String title = 'Select Time Range',
    String leftButtonText = 'Cancel',
    String rightButtonText = 'Confirm',
  }) {
    return showDialog<Map<String, int>>(
      context: context,
      builder:
          (context) => TimeRangePickerModal(
            initialStartHour: initialStartHour,
            initialStartMinute: initialStartMinute,
            initialEndHour: initialEndHour,
            initialEndMinute: initialEndMinute,
            title: title,
            leftButtonText: leftButtonText,
            rightButtonText: rightButtonText,
          ),
    );
  }

  @override
  State<TimeRangePickerModal> createState() => _TimeRangePickerModalState();
}

class _TimeRangePickerModalState extends State<TimeRangePickerModal> {
  late int _selectedStartHour;
  late int _selectedStartMinute;
  late int _selectedEndHour;
  late int _selectedEndMinute;

  late FixedExtentScrollController _startHourController;
  late FixedExtentScrollController _startMinuteController;
  late FixedExtentScrollController _endHourController;
  late FixedExtentScrollController _endMinuteController;

  @override
  void initState() {
    super.initState();
    _selectedStartHour = widget.initialStartHour;
    _selectedStartMinute = widget.initialStartMinute;
    _selectedEndHour = widget.initialEndHour;
    _selectedEndMinute = widget.initialEndMinute;

    _startHourController = FixedExtentScrollController(
      initialItem: _selectedStartHour,
    );
    _startMinuteController = FixedExtentScrollController(
      initialItem: _selectedStartMinute,
    );
    _endHourController = FixedExtentScrollController(
      initialItem: _selectedEndHour,
    );
    _endMinuteController = FixedExtentScrollController(
      initialItem: _selectedEndMinute,
    );
  }

  @override
  void dispose() {
    _startHourController.dispose();
    _startMinuteController.dispose();
    _endHourController.dispose();
    _endMinuteController.dispose();
    super.dispose();
  }

  /// 构建滚动选择器
  Widget _buildScrollPicker({
    required List<String> items,
    required int selectedIndex,
    required Function(int) onSelectedItemChanged,
    required FixedExtentScrollController controller,
  }) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 50,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (context, index) {
            final isSelected = index == selectedIndex;
            return Center(
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color(0xFF6ED0FF).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    items[index],
                    style: TextStyle(
                      fontSize: isSelected ? 20 : 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isSelected
                              ? const Color(0xFF2C3E50)
                              : const Color(0xFF8CA0B3),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    return Column(
      children: [
        // 标题
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),

        // 开始时间标签
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Start Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),

        // 开始时间选择器
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDFE6ED)),
          ),
          child: Row(
            children: [
              // 开始小时
              _buildScrollPicker(
                items: List.generate(
                  24,
                  (index) => index.toString().padLeft(2, '0'),
                ),
                selectedIndex: _selectedStartHour,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedStartHour = index;
                  });
                },
                controller: _startHourController,
              ),
              const Text(
                ' : ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              // 开始分钟
              _buildScrollPicker(
                items: List.generate(
                  60,
                  (index) => index.toString().padLeft(2, '0'),
                ),
                selectedIndex: _selectedStartMinute,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedStartMinute = index;
                  });
                },
                controller: _startMinuteController,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 结束时间标签
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'End Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),

        // 结束时间选择器
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDFE6ED)),
          ),
          child: Row(
            children: [
              // 结束小时
              _buildScrollPicker(
                items: List.generate(
                  24,
                  (index) => index.toString().padLeft(2, '0'),
                ),
                selectedIndex: _selectedEndHour,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedEndHour = index;
                  });
                },
                controller: _endHourController,
              ),
              const Text(
                ' : ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              // 结束分钟
              _buildScrollPicker(
                items: List.generate(
                  60,
                  (index) => index.toString().padLeft(2, '0'),
                ),
                selectedIndex: _selectedEndMinute,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedEndMinute = index;
                  });
                },
                controller: _endMinuteController,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 选择预览
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6ED0FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, color: Color(0xFF6ED0FF), size: 16),
              const SizedBox(width: 8),
              Text(
                '${_selectedStartHour.toString().padLeft(2, '0')}:${_selectedStartMinute.toString().padLeft(2, '0')} - ${_selectedEndHour.toString().padLeft(2, '0')}:${_selectedEndMinute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      content: _buildContent(),
      leftButtonText: widget.leftButtonText,
      rightButtonText: widget.rightButtonText,
      onLeftPressed: () => Navigator.of(context).pop(),
      onRightPressed: () {
        // 验证时间范围是否有效
        final startMinutes = _selectedStartHour * 60 + _selectedStartMinute;
        final endMinutes = _selectedEndHour * 60 + _selectedEndMinute;

        if (startMinutes >= endMinutes) {
          ToastUtils.showWarning(
            context,
            '⚠️ Start time must be before end time',
          );
          return;
        }

        Navigator.of(context).pop({
          'startHour': _selectedStartHour,
          'startMinute': _selectedStartMinute,
          'endHour': _selectedEndHour,
          'endMinute': _selectedEndMinute,
        });
      },
    );
  }
}
