import 'package:floor/floor.dart';

/// 提醒设置实体类
/// 用于存储用户的提醒相关偏好设置
@Entity()
class ReminderSettings {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final bool allReminders; // 总开关
  final bool intervalRemind; // 间隔提醒开关
  final int reminderInterval; // 提醒间隔(分钟)
  final bool dndTime; // 勿扰时间开关
  final int reminderStartHour; // 提醒开始时间（小时，24小时制）
  final int reminderStartMinute; // 提醒开始时间（分钟）
  final int reminderEndHour; // 提醒结束时间（小时，24小时制）
  final int reminderEndMinute; // 提醒结束时间（分钟）
  final bool dndLunch; // 午休勿扰开关
  final int lunchStartHour; // 午休开始时间（小时，24小时制）
  final int lunchStartMinute; // 午休开始时间（分钟）
  final int lunchEndHour; // 午休结束时间（小时，24小时制）
  final int lunchEndMinute; // 午休结束时间（分钟）
  final bool dndPlan; // 计划完成勿扰开关
  final int lastUpdated; // 最后更新时间戳（毫秒）

  ReminderSettings({
    this.id,
    required this.allReminders,
    required this.intervalRemind,
    required this.reminderInterval,
    required this.dndTime,
    required this.reminderStartHour,
    required this.reminderStartMinute,
    required this.reminderEndHour,
    required this.reminderEndMinute,
    required this.dndLunch,
    required this.lunchStartHour,
    required this.lunchStartMinute,
    required this.lunchEndHour,
    required this.lunchEndMinute,
    required this.dndPlan,
    required this.lastUpdated,
  });

  /// 从DateTime创建ReminderSettings
  factory ReminderSettings.fromDateTime({
    int? id,
    required bool allReminders,
    required bool intervalRemind,
    required int reminderInterval,
    required bool dndTime,
    int reminderStartHour = 7,
    int reminderStartMinute = 0,
    int reminderEndHour = 22,
    int reminderEndMinute = 0,
    required bool dndLunch,
    int lunchStartHour = 12,
    int lunchStartMinute = 0,
    int lunchEndHour = 13,
    int lunchEndMinute = 0,
    required bool dndPlan,
    required DateTime lastUpdatedDateTime,
  }) {
    return ReminderSettings(
      id: id,
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
      lastUpdated: lastUpdatedDateTime.millisecondsSinceEpoch,
    );
  }

  /// 获取最后更新时间的DateTime对象
  DateTime get lastUpdatedDateTime =>
      DateTime.fromMillisecondsSinceEpoch(lastUpdated);

  /// 获取提醒时间范围显示文本
  String get reminderTimeRange {
    final startHour = reminderStartHour.toString().padLeft(2, '0');
    final startMinute = reminderStartMinute.toString().padLeft(2, '0');
    final endHour = reminderEndHour.toString().padLeft(2, '0');
    final endMinute = reminderEndMinute.toString().padLeft(2, '0');
    return 'Reminder Time $startHour : $startMinute - $endHour : $endMinute';
  }

  /// 获取午休时间范围显示文本
  String get lunchTimeRange {
    final startHour = lunchStartHour.toString().padLeft(2, '0');
    final startMinute = lunchStartMinute.toString().padLeft(2, '0');
    final endHour = lunchEndHour.toString().padLeft(2, '0');
    final endMinute = lunchEndMinute.toString().padLeft(2, '0');
    return 'No Reminder During Lunch Break $startHour : $startMinute - $endHour : $endMinute';
  }

  /// 创建默认设置
  factory ReminderSettings.defaultSettings() {
    return ReminderSettings.fromDateTime(
      allReminders: true,
      intervalRemind: true,
      reminderInterval: 60,
      dndTime: true,
      dndLunch: true,
      dndPlan: true,
      lastUpdatedDateTime: DateTime.now(),
    );
  }

  /// 复制并更新部分字段
  ReminderSettings copyWith({
    int? id,
    bool? allReminders,
    bool? intervalRemind,
    int? reminderInterval,
    bool? dndTime,
    int? reminderStartHour,
    int? reminderStartMinute,
    int? reminderEndHour,
    int? reminderEndMinute,
    bool? dndLunch,
    int? lunchStartHour,
    int? lunchStartMinute,
    int? lunchEndHour,
    int? lunchEndMinute,
    bool? dndPlan,
    DateTime? lastUpdatedDateTime,
  }) {
    return ReminderSettings.fromDateTime(
      id: id ?? this.id,
      allReminders: allReminders ?? this.allReminders,
      intervalRemind: intervalRemind ?? this.intervalRemind,
      reminderInterval: reminderInterval ?? this.reminderInterval,
      dndTime: dndTime ?? this.dndTime,
      reminderStartHour: reminderStartHour ?? this.reminderStartHour,
      reminderStartMinute: reminderStartMinute ?? this.reminderStartMinute,
      reminderEndHour: reminderEndHour ?? this.reminderEndHour,
      reminderEndMinute: reminderEndMinute ?? this.reminderEndMinute,
      dndLunch: dndLunch ?? this.dndLunch,
      lunchStartHour: lunchStartHour ?? this.lunchStartHour,
      lunchStartMinute: lunchStartMinute ?? this.lunchStartMinute,
      lunchEndHour: lunchEndHour ?? this.lunchEndHour,
      lunchEndMinute: lunchEndMinute ?? this.lunchEndMinute,
      dndPlan: dndPlan ?? this.dndPlan,
      lastUpdatedDateTime: lastUpdatedDateTime ?? this.lastUpdatedDateTime,
    );
  }
}
