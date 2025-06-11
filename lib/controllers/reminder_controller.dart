import 'package:flutter/material.dart';
import 'package:watermate/models/timed_reminder.dart';
import 'package:watermate/models/reminder_settings.dart';
import 'package:watermate/services/reminder_service.dart';
import 'package:watermate/services/reminder_persistence_service.dart';
import 'package:watermate/components/modal/time_interval_modal.dart';
import 'package:watermate/components/modal/time_range_picker_modal.dart';
import 'package:watermate/utils/toast_utils.dart';
import 'package:watermate/database/database_manager.dart';

/// 提醒控制器类
/// 管理提醒页面的所有业务逻辑
class ReminderController {
  final ReminderService _reminderService = ReminderService();
  final ReminderPersistenceService _persistenceService =
      ReminderPersistenceService();

  // 状态变量
  bool allReminders = true;
  bool intervalRemind = true;
  bool dndTime = true;
  int reminderStartHour = 10;
  int reminderStartMinute = 0;
  int reminderEndHour = 22;
  int reminderEndMinute = 0;
  bool dndLunch = true;
  int lunchStartHour = 12;
  int lunchStartMinute = 0;
  int lunchEndHour = 13;
  int lunchEndMinute = 0;
  bool dndPlan = true;
  int reminderInterval = 60;
  List<TimedReminder> timedReminders = TimedReminder.createDefaultReminders();

  // 状态更新回调
  VoidCallback? onStateChanged;

  /// 初始化提醒服务
  Future<void> initialize() async {
    try {
      // 设置计划完成检查回调
      _reminderService.setDailyPlanCompletedChecker(_checkDailyPlanCompleted);

      // 从数据库加载设置
      await _loadReminderSettings();
      await _loadCustomReminders();

      // 初始化时检查是否需要启动定时提醒
      if (allReminders && intervalRemind) {
        _reminderService.startIntervalReminders(
          reminderInterval,
          dndTime: dndTime,
          reminderStartHour: reminderStartHour,
          reminderStartMinute: reminderStartMinute,
          reminderEndHour: reminderEndHour,
          reminderEndMinute: reminderEndMinute,
          dndLunch: dndLunch,
          lunchStartHour: lunchStartHour,
          lunchStartMinute: lunchStartMinute,
          lunchEndHour: lunchEndHour,
          lunchEndMinute: lunchEndMinute,
          dndPlan: dndPlan,
        );
      }
      // 初始化定时提醒
      if (allReminders) {
        _reminderService.scheduleAllTimedReminders(timedReminders);
      }
    } catch (e) {
      print('初始化提醒服务失败: $e');
    }
  }

  /// 检查当日饮水计划是否已完成
  Future<bool> _checkDailyPlanCompleted() async {
    try {
      final db = await DatabaseManager.instance.database;

      // 获取用户目标饮水量
      final user = await db.userDao.getUser();
      if (user == null) {
        print('用户信息不存在，跳过计划完成检查');
        return false;
      }

      // 获取今日饮水记录
      final todayIntake = await DatabaseManager.instance.getTodayWaterIntake();

      // 检查是否已达到目标
      final isCompleted = todayIntake.totalIntake >= user.targetWaterIntake;

      return isCompleted;
    } catch (e) {
      print('检查饮水计划完成状态失败: $e');
      return false; // 出错时不阻止提醒
    }
  }

  /// 从数据库加载提醒设置
  Future<void> _loadReminderSettings() async {
    try {
      final settings = await _persistenceService.getReminderSettings();
      if (settings != null) {
        allReminders = settings.allReminders;
        intervalRemind = settings.intervalRemind;
        reminderInterval = settings.reminderInterval;
        dndTime = settings.dndTime;
        reminderStartHour = settings.reminderStartHour;
        reminderStartMinute = settings.reminderStartMinute;
        reminderEndHour = settings.reminderEndHour;
        reminderEndMinute = settings.reminderEndMinute;
        dndLunch = settings.dndLunch;
        lunchStartHour = settings.lunchStartHour;
        lunchStartMinute = settings.lunchStartMinute;
        lunchEndHour = settings.lunchEndHour;
        lunchEndMinute = settings.lunchEndMinute;
        dndPlan = settings.dndPlan;
        print('已加载提醒设置：总开关=$allReminders, 间隔提醒=$intervalRemind');
      } else {
        // 如果没有设置，保存默认设置
        await _saveCurrentSettings();
      }
    } catch (e) {
      print('加载提醒设置失败: $e');
    }
  }

  /// 从数据库加载自定义提醒
  Future<void> _loadCustomReminders() async {
    try {
      final customReminders = await _persistenceService.getCustomReminders();
      if (customReminders.isNotEmpty) {
        // 将自定义提醒转换为TimedReminder
        timedReminders = _persistenceService.convertToTimedReminders(
          customReminders,
        );
        print('已加载自定义提醒: ${timedReminders.length}条');
      } else {
        // 如果没有自定义提醒，迁移默认提醒到数据库
        await _persistenceService.migrateDefaultReminders(timedReminders);
        print('已迁移默认提醒到数据库');
      }
    } catch (e) {
      print('加载自定义提醒失败: $e');
    }
  }

  /// 保存当前设置到数据库
  Future<void> _saveCurrentSettings() async {
    try {
      final settings = ReminderSettings.fromDateTime(
        allReminders: allReminders,
        intervalRemind: intervalRemind,
        reminderInterval: reminderInterval,
        dndTime: dndTime,
        reminderStartHour: reminderStartHour,
        reminderStartMinute: reminderStartMinute,
        reminderEndHour: reminderEndHour,
        reminderEndMinute: reminderEndMinute,
        dndLunch: dndLunch,
        lunchStartHour: lunchStartHour,
        lunchStartMinute: lunchStartMinute,
        lunchEndHour: lunchEndHour,
        lunchEndMinute: lunchEndMinute,
        dndPlan: dndPlan,
        lastUpdatedDateTime: DateTime.now(),
      );
      await _persistenceService.saveReminderSettings(settings);
    } catch (e) {
      print('保存提醒设置失败: $e');
    }
  }

  /// 释放资源
  void dispose() {
    _reminderService.dispose();
  }

  /// 更新提醒状态
  void updateReminderState() {
    // 处理间隔提醒
    if (allReminders && intervalRemind) {
      _reminderService.startIntervalReminders(
        reminderInterval,
        dndTime: dndTime,
        reminderStartHour: reminderStartHour,
        reminderStartMinute: reminderStartMinute,
        reminderEndHour: reminderEndHour,
        reminderEndMinute: reminderEndMinute,
        dndLunch: dndLunch,
        lunchStartHour: lunchStartHour,
        lunchStartMinute: lunchStartMinute,
        lunchEndHour: lunchEndHour,
        lunchEndMinute: lunchEndMinute,
        dndPlan: dndPlan,
      );
    } else {
      _reminderService.stopIntervalReminders();
    }

    // 处理定时提醒
    if (allReminders) {
      _reminderService.scheduleAllTimedReminders(timedReminders);
    } else {
      _reminderService.cancelAllTimedReminders(timedReminders);
    }
  }

  /// 显示时间间隔选择器
  Future<void> showIntervalPicker(BuildContext context) async {
    final result = await TimeIntervalModal.show(
      context,
      initialInterval: reminderInterval,
      leftButtonText: 'Cancel',
      rightButtonText: 'Confirm',
      intervals: [15, 30, 45, 60, 90, 120, 180, 240],
    );

    if (result != null) {
      reminderInterval = result;
      onStateChanged?.call();

      // 保存设置到数据库
      await _persistenceService.updateIntervalReminder(
        intervalRemind,
        reminderInterval,
      );

      // 如果当前开启了间隔提醒，重新启动定时器使用新的间隔
      if (allReminders && intervalRemind) {
        _reminderService.startIntervalReminders(
          reminderInterval,
          dndTime: dndTime,
          reminderStartHour: reminderStartHour,
          reminderStartMinute: reminderStartMinute,
          reminderEndHour: reminderEndHour,
          reminderEndMinute: reminderEndMinute,
          dndLunch: dndLunch,
          lunchStartHour: lunchStartHour,
          lunchStartMinute: lunchStartMinute,
          lunchEndHour: lunchEndHour,
          lunchEndMinute: lunchEndMinute,
          dndPlan: dndPlan,
        );

        // 显示提示信息
        ToastUtils.showSuccess(
          context,
          '✅ Reminder interval updated to ${reminderInterval} minutes',
        );
      }
    }
  }

  /// 切换定时提醒的开关状态
  void toggleTimedReminder(BuildContext context, TimedReminder reminder) {
    reminder.isEnabled = !reminder.isEnabled;
    onStateChanged?.call();

    if (allReminders && reminder.isEnabled) {
      _reminderService.scheduleTimedReminder(reminder);
    } else {
      _reminderService.cancelTimedReminder(reminder);
    }

    // 显示提示
    if (reminder.isEnabled) {
      ToastUtils.showSuccess(
        context,
        '✅ ${reminder.fullDisplayTime} reminder is enabled',
      );
    } else {
      ToastUtils.showInfo(
        context,
        '❌ ${reminder.fullDisplayTime} reminder is disabled',
      );
    }
  }

  /// 添加新的定时提醒
  Future<void> addTimedReminder(
    BuildContext context,
    int hour,
    int minute,
    bool isAM,
  ) async {
    // 检查时间是否已存在
    final exists = timedReminders.any(
      (r) => r.hour == hour && r.minute == minute && r.isAM == isAM,
    );
    if (exists) {
      ToastUtils.showWarning(
        context,
        '⚠️ Reminder already exists at ${hour}:${minute}',
      );
      return;
    }

    // 添加到数据库
    final success = await _persistenceService.addCustomReminder(
      hour,
      minute,
      isAM,
    );
    if (!success) {
      ToastUtils.showError(context, '❌ Failed to add reminder');
      return;
    }

    // 重新加载自定义提醒
    await _loadCustomReminders();
    onStateChanged?.call();

    // 找到刚添加的提醒
    final newReminder = timedReminders.firstWhere(
      (r) => r.hour == hour && r.minute == minute && r.isAM == isAM,
    );

    print('添加新提醒: ${newReminder.fullDisplayTime}');
    print('当前总开关状态: $allReminders');

    // 如果总开关开启，立即安排这个提醒
    if (allReminders) {
      _reminderService.scheduleTimedReminder(newReminder);
    }

    ToastUtils.showSuccess(
      context,
      '✅ New reminder added: ${newReminder.fullDisplayTime}',
      duration: const Duration(seconds: 3),
    );
  }

  /// 切换所有提醒开关
  Future<void> toggleAllReminders(BuildContext context, bool value) async {
    final oldValue = allReminders;

    try {
      // 先保存到数据库
      final success = await _persistenceService.updateAllReminders(value);
      if (!success) {
        ToastUtils.showError(context, '❌ Failed to save settings');
        return;
      }

      // 数据库保存成功后，更新状态
      allReminders = value;
      onStateChanged?.call();
      updateReminderState();

      // 显示提示信息
      if (value) {
        ToastUtils.showSuccess(context, '🔔 All reminders are enabled');
      } else {
        ToastUtils.showInfo(context, '🔕 All reminders are disabled');
      }
    } catch (e) {
      print('切换总开关失败: $e');
      // 恢复原始状态
      allReminders = oldValue;
      onStateChanged?.call();
      ToastUtils.showError(context, '❌ Failed to update reminders');
    }
  }

  /// 切换间隔提醒开关
  Future<void> toggleIntervalRemind(BuildContext context, bool value) async {
    intervalRemind = value;
    onStateChanged?.call();
    updateReminderState();

    // 保存设置到数据库
    await _persistenceService.updateIntervalReminder(value, reminderInterval);

    // 显示提示信息
    ToastUtils.showSuccess(
      context,
      value
          ? '⏰ Interval reminder is enabled, reminder every ${reminderInterval} minutes'
          : '⏰ Interval reminder is disabled',
      duration: const Duration(seconds: 3),
    );
  }

  /// 切换勿扰时间开关
  Future<void> toggleDndTime(bool value) async {
    dndTime = value;
    onStateChanged?.call();

    // 保存设置到数据库
    await _persistenceService.updateDndTime(value);
  }

  /// 切换勿扰午休开关
  Future<void> toggleDndLunch(bool value) async {
    dndLunch = value;
    onStateChanged?.call();

    // 保存设置到数据库
    await _persistenceService.updateDndLunch(value);
  }

  /// 切换勿扰计划开关
  Future<void> toggleDndPlan(bool value) async {
    dndPlan = value;
    onStateChanged?.call();

    // 保存设置到数据库
    await _persistenceService.updateDndPlan(value);
  }

  /// 显示提醒时间范围选择器
  Future<void> showReminderTimePicker(BuildContext context) async {
    final result = await TimeRangePickerModal.show(
      context,
      initialStartHour: reminderStartHour,
      initialStartMinute: reminderStartMinute,
      initialEndHour: reminderEndHour,
      initialEndMinute: reminderEndMinute,
      title: '',
      leftButtonText: 'Cancel',
      rightButtonText: 'Confirm',
    );

    if (result != null) {
      reminderStartHour = result['startHour']!;
      reminderStartMinute = result['startMinute']!;
      reminderEndHour = result['endHour']!;
      reminderEndMinute = result['endMinute']!;
      onStateChanged?.call();

      // 保存设置到数据库
      await _persistenceService.updateReminderTimeRange(
        reminderStartHour,
        reminderStartMinute,
        reminderEndHour,
        reminderEndMinute,
      );

      // 显示提示信息
      final startTime =
          '${reminderStartHour.toString().padLeft(2, '0')}:${reminderStartMinute.toString().padLeft(2, '0')}';
      final endTime =
          '${reminderEndHour.toString().padLeft(2, '0')}:${reminderEndMinute.toString().padLeft(2, '0')}';

      ToastUtils.showSuccess(
        context,
        '⏰ Reminder time updated to $startTime - $endTime',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// 显示午休时间范围选择器
  Future<void> showLunchTimePicker(BuildContext context) async {
    final result = await TimeRangePickerModal.show(
      context,
      initialStartHour: lunchStartHour,
      initialStartMinute: lunchStartMinute,
      initialEndHour: lunchEndHour,
      initialEndMinute: lunchEndMinute,
      title: '',
      leftButtonText: 'Cancel',
      rightButtonText: 'Confirm',
    );

    if (result != null) {
      lunchStartHour = result['startHour']!;
      lunchStartMinute = result['startMinute']!;
      lunchEndHour = result['endHour']!;
      lunchEndMinute = result['endMinute']!;
      onStateChanged?.call();

      // 保存设置到数据库
      await _persistenceService.updateLunchTimeRange(
        lunchStartHour,
        lunchStartMinute,
        lunchEndHour,
        lunchEndMinute,
      );

      // 显示提示信息
      final startTime =
          '${lunchStartHour.toString().padLeft(2, '0')}:${lunchStartMinute.toString().padLeft(2, '0')}';
      final endTime =
          '${lunchEndHour.toString().padLeft(2, '0')} : ${lunchEndMinute.toString().padLeft(2, '0')}';

      ToastUtils.showSuccess(
        context,
        '🍽️ Lunch time updated to $startTime - $endTime',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// 获取提醒时间范围显示文本
  String get reminderTimeRange {
    final startTime =
        '${reminderStartHour.toString().padLeft(2, '0')} : ${reminderStartMinute.toString().padLeft(2, '0')}';
    final endTime =
        '${reminderEndHour.toString().padLeft(2, '0')} : ${reminderEndMinute.toString().padLeft(2, '0')}';
    return 'Reminder Time $startTime - $endTime';
  }

  /// 获取午休时间范围显示文本
  String get lunchTimeRange {
    final startTime =
        '${lunchStartHour.toString().padLeft(2, '0')} : ${lunchStartMinute.toString().padLeft(2, '0')}';
    final endTime =
        '${lunchEndHour.toString().padLeft(2, '0')} : ${lunchEndMinute.toString().padLeft(2, '0')}';
    return 'No Reminder During Lunch Break $startTime - $endTime';
  }
}
