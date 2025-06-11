import 'package:flutter/material.dart';
import 'package:watermate/database/database_manager.dart';
import 'package:watermate/pages/home/home.dart';
import 'package:watermate/utils/user_setup_manager.dart';
import 'package:watermate/utils/toast_utils.dart';

/// 导航工具类
/// 提供带数据库初始化的页面跳转功能
class NavigationHelper {
  /// 确保用户数据完整，如果不完整则使用默认值
  static void _ensureUserDataComplete() {
    final userSetup = UserSetupManager();
    if (!userSetup.hasCompleteData) {
      // 用户跳过了引导，使用默认值
      if (!userSetup.hasGender) userSetup.setGender('male');
      if (!userSetup.hasWeight) userSetup.setWeight(70.0);
      if (!userSetup.hasExerciseVolume)
        userSetup.setExerciseVolume('light exercise');
    }
  }

  /// 跳转到首页并初始化数据库
  /// [context] 当前页面的上下文
  /// [clearStack] 是否清空导航栈，默认为true
  static Future<void> navigateToHomeWithDatabase(
    BuildContext context, {
    bool clearStack = true,
  }) async {
    try {
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Initializing...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
      );

      // 确保用户数据完整
      _ensureUserDataComplete();

      // 初始化数据库
      await DatabaseManager.instance.database;

      // 关闭加载指示器
      if (context.mounted) {
        Navigator.of(context).pop();

        // 跳转到首页
        if (clearStack) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } catch (e) {
      // 关闭加载指示器
      if (context.mounted) {
        Navigator.of(context).pop();

        // 显示错误信息
        ToastUtils.showError(context, 'Failed to initialize: $e');
      }
    }
  }

  /// 导航到指定页面并初始化数据库
  /// [context] 当前页面的上下文
  /// [destination] 目标页面
  /// [clearStack] 是否清空导航栈，默认为false
  static Future<void> navigateWithDatabase(
    BuildContext context,
    Widget destination, {
    bool clearStack = false,
  }) async {
    try {
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Initializing...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
      );

      // 确保用户数据完整
      _ensureUserDataComplete();

      // 初始化数据库
      await DatabaseManager.instance.database;

      // 关闭加载指示器
      if (context.mounted) {
        Navigator.of(context).pop();

        // 跳转到目标页面
        if (clearStack) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => destination),
            (route) => false,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      }
    } catch (e) {
      // 关闭加载指示器
      if (context.mounted) {
        Navigator.of(context).pop();

        // 显示错误信息
        ToastUtils.showError(context, 'Failed to initialize: $e');
      }
    }
  }
}
