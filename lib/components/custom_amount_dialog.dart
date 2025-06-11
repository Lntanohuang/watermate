import 'package:flutter/material.dart';

/// 自定义饮水量输入对话框组件
class CustomAmountDialog extends StatefulWidget {
  /// 初始值，如果当前选择的是自定义值，会预填充
  final int? initialValue;

  /// 最小值限制
  final int minValue;

  /// 最大值限制
  final int maxValue;

  const CustomAmountDialog({
    super.key,
    this.initialValue,
    this.minValue = 1,
    this.maxValue = 4000,
  });

  /// 显示自定义饮水量对话框
  /// 返回用户输入的饮水量，如果取消则返回null
  static Future<int?> show(
    BuildContext context, {
    int? initialValue,
    int minValue = 1,
    int maxValue = 4000,
  }) async {
    return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return CustomAmountDialog(
          initialValue: initialValue,
          minValue: minValue,
          maxValue: maxValue,
        );
      },
    );
  }

  @override
  State<CustomAmountDialog> createState() => _CustomAmountDialogState();
}

class _CustomAmountDialogState extends State<CustomAmountDialog> {
  late TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    // 如果有初始值，预填充输入框，否则使用默认值600
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue.toString();
    } else {
      _controller.text = '600';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 验证输入并返回结果
  void _handleConfirm() {
    final input = _controller.text.trim();

    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the amount of water intake.';
      });
      return;
    }

    final amount = int.tryParse(input);
    if (amount == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number.';
      });
      return;
    }

    if (amount < widget.minValue || amount > widget.maxValue) {
      setState(() {
        _errorMessage =
            'Please enter a number between ${widget.minValue} and ${widget.maxValue}.';
      });
      return;
    }

    // 验证通过，返回结果
    Navigator.of(context).pop(amount);
  }

  /// 取消操作
  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Custom Water Intake',
        style: TextStyle(
          
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please enter the amount of water intake (ml)',
            style: TextStyle( color: Color(0xFF6B7B8A)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'For example: 600',
              suffixText: 'ml',
              errorText: _errorMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E6ED)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF7BA1B7),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              // 清除错误信息
              if (_errorMessage != null) {
                setState(() {
                  _errorMessage = null;
                });
              }
            },
            onSubmitted: (value) {
              _handleConfirm();
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              'Range: ${widget.minValue}-${widget.maxValue}ml',
              style: const TextStyle( color: Color(0xFF6B7B8A)),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _handleCancel,
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF6B7B8A), fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7BA1B7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Confirm', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
