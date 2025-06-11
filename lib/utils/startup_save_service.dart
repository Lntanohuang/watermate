import 'package:flutter/material.dart';
import 'package:watermate/database/database_manager.dart';
import 'package:watermate/utils/toast_utils.dart';

/// 启动页面保存服务类
/// 提供统一的数据保存功能，包含加载状态管理和错误处理
class StartupSaveService {
  /// 保存目标饮水量到数据库
  ///
  /// [context] 页面上下文，用于显示提示信息
  /// [targetWaterIntake] 目标饮水量（毫升）
  /// [onLoadingChanged] 加载状态变化回调
  /// [onSuccess] 保存成功回调
  /// [onError] 保存失败回调
  static Future<bool> saveTargetWaterIntake({
    required BuildContext context,
    required int targetWaterIntake,
    Function(bool isLoading)? onLoadingChanged,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    // 设置加载状态
    onLoadingChanged?.call(true);

    try {
      // 保存目标饮水量到数据库
      final db = await DatabaseManager.instance.database;
      await db.userDao.updateTargetWaterIntake(targetWaterIntake);

      print('Target water intake saved to database: ${targetWaterIntake}ml');

      // 显示成功提示
      if (context.mounted) {
        ToastUtils.showSuccess(
          context,
          'Target water intake saved: ${targetWaterIntake}ml',
        );
      }

      // 延迟一下让用户看到成功提示
      await Future.delayed(const Duration(milliseconds: 500));

      // 调用成功回调
      onSuccess?.call();

      return true;
    } catch (e) {
      final errorMessage = 'Failed to save target water intake: $e';
      print(errorMessage);

      // 显示错误提示
      if (context.mounted) {
        ToastUtils.showError(context, 'Failed to save: $e');
      }

      // 调用错误回调
      onError?.call(errorMessage);

      return false;
    } finally {
      // 重置加载状态
      onLoadingChanged?.call(false);
    }
  }

  /// 保存提醒时间到数据库
  ///
  /// [context] 页面上下文，用于显示提示信息
  /// [startMinutes] 开始时间（分钟数）
  /// [endMinutes] 结束时间（分钟数）
  /// [onLoadingChanged] 加载状态变化回调
  /// [onSuccess] 保存成功回调
  /// [onError] 保存失败回调
  static Future<bool> saveReminderTime({
    required BuildContext context,
    required int startMinutes,
    required int endMinutes,
    Function(bool isLoading)? onLoadingChanged,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    // 设置加载状态
    onLoadingChanged?.call(true);

    try {
      // 保存提醒时间到数据库
      final db = await DatabaseManager.instance.database;
      await db.userDao.updateReminderTime(startMinutes, endMinutes);

      print(
        'Reminder time saved to database: ${_formatTime(startMinutes)} - ${_formatTime(endMinutes)}',
      );

      // 显示成功提示
      if (context.mounted) {
        ToastUtils.showSuccess(
          context,
          'Reminder time saved: ${_formatTime(startMinutes)} - ${_formatTime(endMinutes)}',
        );
      }

      // 延迟一下让用户看到成功提示
      await Future.delayed(const Duration(milliseconds: 500));

      // 调用成功回调
      onSuccess?.call();

      return true;
    } catch (e) {
      final errorMessage = 'Failed to save reminder time: $e';
      print(errorMessage);

      // 显示错误提示
      if (context.mounted) {
        ToastUtils.showError(context, 'Failed to save: $e');
      }

      // 调用错误回调
      onError?.call(errorMessage);

      return false;
    } finally {
      // 重置加载状态
      onLoadingChanged?.call(false);
    }
  }

  /// 格式化时间显示
  /// [minutes] 分钟数（0-1440）
  /// 返回格式化的时间字符串，如 "07:00"
  static String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  /// 批量保存启动页面数据
  ///
  /// [context] 页面上下文
  /// [targetWaterIntake] 目标饮水量（可选）
  /// [startMinutes] 提醒开始时间（可选）
  /// [endMinutes] 提醒结束时间（可选）
  /// [onLoadingChanged] 加载状态变化回调
  /// [onSuccess] 全部保存成功回调
  /// [onError] 保存失败回调
  static Future<bool> saveBatchData({
    required BuildContext context,
    int? targetWaterIntake,
    int? startMinutes,
    int? endMinutes,
    Function(bool isLoading)? onLoadingChanged,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    onLoadingChanged?.call(true);

    try {
      final db = await DatabaseManager.instance.database;

      // 保存目标饮水量
      if (targetWaterIntake != null) {
        await db.userDao.updateTargetWaterIntake(targetWaterIntake);
        print('Target water intake saved: ${targetWaterIntake}ml');
      }

      // 保存提醒时间
      if (startMinutes != null && endMinutes != null) {
        await db.userDao.updateReminderTime(startMinutes, endMinutes);
        print(
          'Reminder time saved: ${_formatTime(startMinutes)} - ${_formatTime(endMinutes)}',
        );
      }

      // 显示成功提示
      if (context.mounted) {
        ToastUtils.showSuccess(context, 'Settings saved successfully');
      }

      await Future.delayed(const Duration(milliseconds: 500));
      onSuccess?.call();

      return true;
    } catch (e) {
      final errorMessage = 'Failed to save settings: $e';
      print(errorMessage);

      if (context.mounted) {
        ToastUtils.showError(context, 'Failed to save: $e');
      }

      onError?.call(errorMessage);
      return false;
    } finally {
      onLoadingChanged?.call(false);
    }
  }
}
