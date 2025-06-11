import 'package:flutter/material.dart';
import 'package:watermate/models/timed_reminder.dart';
import 'package:watermate/components/modal/modal_base.dart';

//小标题
class ReminderText extends StatelessWidget {
  final String text;
  const ReminderText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8CA0B3),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

//内容
class ReminderContent extends StatelessWidget {
  final String text;
  final bool isEnabled;

  const ReminderContent({
    super.key,
    required this.text,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: isEnabled ? const Color(0xFF2C3E50) : const Color(0xFF8CA0B3),
        fontWeight: isEnabled ? FontWeight.w500 : FontWeight.normal,
      ),
    );
  }
}

/// 定时提醒列表组件
///
class TimedReminderList extends StatelessWidget {
  final List<TimedReminder> reminders;
  final Function(TimedReminder) onToggle;

  const TimedReminderList({
    super.key,
    required this.reminders,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          reminders.asMap().entries.map((entry) {
            final index = entry.key;
            final reminder = entry.value;
            return Column(
              children: [
                GestureDetector(
                  onTap: () => onToggle(reminder),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          reminder.displayTime,
                          style: TextStyle(
                            color:
                                reminder.isEnabled
                                    ? const Color(0xFF2C3E50)
                                    : const Color(0xFF8CA0B3),
                            fontWeight:
                                reminder.isEnabled
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                      Icon(
                        reminder.isEnabled
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color:
                            reminder.isEnabled
                                ? const Color(0xFF6ED0FF)
                                : const Color(0xFFB0C4D6),
                      ),
                    ],
                  ),
                ),
                if (index < reminders.length - 1)
                  const Divider(color: Color(0xFFDFE6ED), height: 18),
              ],
            );
          }).toList(),
    );
  }
}

/// 自定义时间选择器组件
class CustomTimePickerWidget extends StatelessWidget {
  final Function(int hour, int minute, bool isAM) onConfirm;

  const CustomTimePickerWidget({super.key, required this.onConfirm});

  void _showDialog(BuildContext context) async {
    final result = await _CustomTimePickerModal.show(
      context,
      initialHour: 8,
      initialMinute: 0,
      initialIsAM: true,
    );

    if (result != null) {
      onConfirm(result['hour'], result['minute'], result['isAM']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDialog(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, color: Color(0xFF6ED0FF)),
          const SizedBox(width: 6),
          const Text(
            'Customize Time Point',
            style: TextStyle(color: Color(0xFF6ED0FF)),
          ),
        ],
      ),
    );
  }
}

/// 自定义时间选择器模态框
class _CustomTimePickerModal extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final bool initialIsAM;

  const _CustomTimePickerModal({
    super.key,
    required this.initialHour,
    required this.initialMinute,
    required this.initialIsAM,
  });

  /// 显示自定义时间选择器
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required int initialHour,
    required int initialMinute,
    required bool initialIsAM,
  }) async {
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => _CustomTimePickerModal(
            initialHour: initialHour,
            initialMinute: initialMinute,
            initialIsAM: initialIsAM,
          ),
    );
  }

  @override
  State<_CustomTimePickerModal> createState() => _CustomTimePickerModalState();
}

class _CustomTimePickerModalState extends State<_CustomTimePickerModal> {
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAM;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialHour;
    _selectedMinute = widget.initialMinute;
    _isAM = widget.initialIsAM;

    // 初始化滚动控制器
    _hourController = FixedExtentScrollController(
      initialItem: _selectedHour - 1,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
    _periodController = FixedExtentScrollController(initialItem: _isAM ? 0 : 1);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  Widget _buildScrollPicker({
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onSelectedItemChanged,
    required FixedExtentScrollController controller,
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
            controller: controller,
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

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      leftButtonText: 'cancel',
      rightButtonText: 'confirm',
      onLeftPressed: () => Navigator.of(context).pop(),
      onRightPressed:
          () => Navigator.of(context).pop({
            'hour': _selectedHour,
            'minute': _selectedMinute,
            'isAM': _isAM,
          }),
      content: SizedBox(
        height: 200,
        child: Row(
          children: [
            // 小时选择器
            Expanded(
              child: _buildScrollPicker(
                items: List.generate(12, (i) => '${i + 1}'),
                selectedIndex: _selectedHour - 1,
                controller: _hourController,
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
                items: List.generate(60, (i) => i.toString().padLeft(2, '0')),
                selectedIndex: _selectedMinute,
                controller: _minuteController,
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
                controller: _periodController,
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
}

/// 勿扰设置行组件
class DndRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showArrow;
  final VoidCallback? onArrowTap;

  const DndRow({
    super.key,
    required this.icon,
    required this.text,
    required this.value,
    required this.onChanged,
    this.showArrow = false,
    this.onArrowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF6ED0FF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(color: Color(0xFF2C3E50))),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFF6ED0FF),
        ),
        if (showArrow)
          GestureDetector(
            onTap: onArrowTap,
            child: const Icon(Icons.chevron_right, color: Color(0xFFB0C4D6)),
          ),
      ],
    );
  }
}
