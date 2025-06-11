import 'package:flutter/material.dart';
// import 'package:watermate/components/basic.dart';

const Color themeColor3 = Color(0xFF79C1DE);

/// Toast工具类 - 提供统一的提示弹窗
class ToastUtils {
  /// 显示成功提示
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _showToast(
      context,
      message,
      backgroundColor: themeColor3, // 绿色
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  /// 显示错误提示
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(
      context,
      message,
      backgroundColor: const Color(0xFFE53935), // 红色
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  /// 显示警告提示
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _showToast(
      context,
      message,
      backgroundColor: const Color(0xFFFF9800), // 橙色
      icon: Icons.warning_outlined,
      duration: duration,
    );
  }

  /// 显示信息提示
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _showToast(
      context,
      message,
      backgroundColor: themeColor3,
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  /// 显示添加成功提示
  static void showAddSuccess(
    BuildContext context,
    String itemName,
    int amount, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSuccess(context, 'Added ${amount}ml $itemName', duration: duration);
  }

  /// 显示删除成功提示
  static void showDeleteSuccess(
    BuildContext context,
    String itemName, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSuccess(context, 'Deleted: $itemName', duration: duration);
  }

  /// 显示修改成功提示
  static void showUpdateSuccess(
    BuildContext context,
    String itemName, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSuccess(context, 'Updated: $itemName', duration: duration);
  }

  /// 显示自定义Toast
  static void showCustom(
    BuildContext context,
    String message, {
    Color backgroundColor = themeColor3,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showToast(
      context,
      message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
    );
  }

  /// 内部方法 - 显示Toast
  static void _showToast(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    IconData? icon,
    required Duration duration,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

/// 高级Toast工具类 - 提供更丰富的弹窗样式
// class AdvancedToastUtils {
//   /// 显示带动画的成功弹窗
//   static void showAnimatedSuccess(
//     BuildContext context,
//     String message, {
//     Duration duration = const Duration(seconds: 2),
//   }) {
//     _showAnimatedToast(
//       context,
//       message,
//       backgroundColor: const Color(0xFF4CAF50),
//       icon: Icons.check_circle,
//       duration: duration,
//     );
//   }

//   /// 显示带动画的错误弹窗
//   static void showAnimatedError(
//     BuildContext context,
//     String message, {
//     Duration duration = const Duration(seconds: 3),
//   }) {
//     _showAnimatedToast(
//       context,
//       message,
//       backgroundColor: const Color(0xFFE53935),
//       icon: Icons.error,
//       duration: duration,
//     );
//   }

//   /// 显示顶部弹窗
//   static void showTopToast(
//     BuildContext context,
//     String message, {
//     Color backgroundColor = const Color(0xFF7BA1B7),
//     IconData? icon,
//     Duration duration = const Duration(seconds: 2),
//   }) {
//     final overlay = Overlay.of(context);
//     late OverlayEntry overlayEntry;

//     overlayEntry = OverlayEntry(
//       builder:
//           (context) => Positioned(
//             top: MediaQuery.of(context).padding.top + 16,
//             left: 16,
//             right: 16,
//             child: Material(
//               color: Colors.transparent,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 decoration: BoxDecoration(
//                   color: backgroundColor,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (icon != null) ...[
//                       Icon(icon, color: Colors.white, size: 20),
//                       const SizedBox(width: 8),
//                     ],
//                     Expanded(
//                       child: Text(
//                         message,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//     );

//     overlay.insert(overlayEntry);

//     // 自动移除
//     Future.delayed(duration, () {
//       overlayEntry.remove();
//     });
//   }

//   /// 内部方法 - 显示带动画的Toast
//   static void _showAnimatedToast(
//     BuildContext context,
//     String message, {
//     required Color backgroundColor,
//     IconData? icon,
//     required Duration duration,
//   }) {
//     if (!context.mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (icon != null) ...[
//               TweenAnimationBuilder<double>(
//                 duration: const Duration(milliseconds: 300),
//                 tween: Tween(begin: 0.0, end: 1.0),
//                 builder: (context, value, child) {
//                   return Transform.scale(
//                     scale: value,
//                     child: Icon(icon, color: Colors.white, size: 20),
//                   );
//                 },
//               ),
//               const SizedBox(width: 8),
//             ],
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: backgroundColor,
//         duration: duration,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
// }
