import 'package:flutter/material.dart';

/// 基础模态框组件
/// 提供统一的背景图片和布局结构
class ModalBase extends StatelessWidget {
  // final String title;
  final Widget content;
  final String? leftButtonText;
  final String? rightButtonText;
  final VoidCallback? onLeftPressed;
  final VoidCallback? onRightPressed;
  final Color? leftButtonColor;
  final Color? rightButtonColor;

  const ModalBase({
    super.key,
    // required this.title,
    required this.content,
    this.leftButtonText,
    this.rightButtonText,
    this.onLeftPressed,
    this.onRightPressed,
    this.leftButtonColor,
    this.rightButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/png/modal_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部间距和标题
            // const SizedBox(height: 80),
            // Text(
            //   // title,
            //   style: const TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.w600,
            //     color: Color(0xFF2C3E50),
            //   ),
            // ),
            const SizedBox(height: 40),

            // 内容区域
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: content,
            ),

            // 底部间距
            // const SizedBox(height: 10),
            // 底部按钮
            if (leftButtonText != null || rightButtonText != null)
              Row(
                children: [
                  // 左按钮
                  if (leftButtonText != null)
                    Expanded(
                      child: GestureDetector(
                        onTap: onLeftPressed,
                        child: Container(
                          height: 56,
                          alignment: Alignment.center,
                          child: Text(
                            leftButtonText!,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    ),

                  // 分隔线
                  if (leftButtonText != null && rightButtonText != null)
                    Container(width: 1, height: 56, color: Color(0xFFEFEFEF)),

                  // 右按钮
                  if (rightButtonText != null)
                    Expanded(
                      child: GestureDetector(
                        onTap: onRightPressed,
                        child: Container(
                          height: 56,
                          alignment: Alignment.center,
                          child: Text(
                            rightButtonText!,
                            style: TextStyle(
                              color: rightButtonColor ?? Color(0xFF6ED0FF),
                            ),
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
