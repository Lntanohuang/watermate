import 'package:flutter/material.dart';

// TODO：时间选择器 好多个弹窗继承这个b
class CustomTimePickerDialog extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final DayPeriod initialPeriod;
  final void Function(int hour, int minute, DayPeriod period) onConfirm;
  final Widget? timePickerContent; // 自定义时间选择器内容
  final String leftText; // 取消按钮文本
  final String rightText; // 确认按钮文本

  const CustomTimePickerDialog({
    super.key,
    required this.initialHour,
    required this.initialMinute,
    required this.initialPeriod,
    required this.onConfirm,
    this.timePickerContent, // 可选的自定义时间选择器内容
    this.leftText = 'cancel', // 默认取消按钮文本
    this.rightText = 'confirm', // 默认确认按钮文本
  });

  @override
  State<CustomTimePickerDialog> createState() => _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<CustomTimePickerDialog> {
  late int selectedHour;
  late int selectedMinute;
  late DayPeriod selectedPeriod;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialHour;
    selectedMinute = widget.initialMinute;
    selectedPeriod = widget.initialPeriod;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: Container(
        height: 380,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/png/modal_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10), //TODO:调整大小
            // Container(
            //   height: 190,
            //   width: double.infinity,
            //   decoration: const BoxDecoration(
            //     color: Color(0xFFEAF7FB),
            //     image: DecorationImage(
            //       image: AssetImage('assets/images/png/modal/babe.png'),
            //       alignment: Alignment.topRight,
            //       scale: 0.5,
            //     ),
            //   ),
            //   child: Stack(
            //     children: [
            //       Positioned(
            //         left: 0,
            //         bottom: 0,
            //         child: Image.asset(
            //           'assets/images/png/modal/cloud.png',
            //           height: 50,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // 时间选择器内容
            if (widget.timePickerContent != null)
              Expanded(child: widget.timePickerContent!),
            // 底部按钮
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: Text(
                        widget.leftText,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 56, color: Color(0xFFEFEFEF)),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.onConfirm(
                        selectedHour,
                        selectedMinute,
                        selectedPeriod,
                      );
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: Text(
                        widget.rightText,
                        style: TextStyle(color: Color(0xFF6ED0FF)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
