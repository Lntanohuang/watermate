import 'package:floor/floor.dart';
import 'package:watermate/models/reminder_settings.dart';

/// 提醒设置数据访问对象
@dao
abstract class ReminderSettingsDao {
  /// 插入新的提醒设置
  @insert
  Future<int> insertSettings(ReminderSettings settings);

  /// 更新已存在的提醒设置
  @update
  Future<void> updateSettings(ReminderSettings settings);

  /// 删除提醒设置
  @delete
  Future<void> deleteSettings(ReminderSettings settings);

  /// 获取当前的提醒设置（只有一条记录）
  @Query('SELECT * FROM ReminderSettings ORDER BY lastUpdated DESC LIMIT 1')
  Future<ReminderSettings?> getCurrentSettings();

  /// 更新总开关状态
  @Query(
    'UPDATE ReminderSettings SET allReminders = :enabled, lastUpdated = :lastUpdated WHERE id = :id',
  )
  Future<void> updateAllReminders(int id, bool enabled, int lastUpdated);

  /// 更新间隔提醒设置
  @Query(
    'UPDATE ReminderSettings SET intervalRemind = :enabled, reminderInterval = :interval, lastUpdated = :lastUpdated WHERE id = :id',
  )
  Future<void> updateIntervalReminder(
    int id,
    bool enabled,
    int interval,
    int lastUpdated,
  );

  /// 更新勿扰时间设置
  @Query(
    'UPDATE ReminderSettings SET dndTime = :enabled, lastUpdated = :lastUpdated WHERE id = :id',
  )
  Future<void> updateDndTime(int id, bool enabled, int lastUpdated);

  /// 更新提醒时间范围
  @Query(
    'UPDATE ReminderSettings SET reminderStartHour = :startHour, reminderStartMinute = :startMinute, reminderEndHour = :endHour, reminderEndMinute = :endMinute, lastUpdated = :lastUpdated WHERE id = :id',
  )
  Future<void> updateReminderTimeRange(
    int id,
    int startHour,
    int startMinute,
    int endHour,
    int endMinute,
    int lastUpdated,
  );

  /// 更新午休勿扰设置
  @Query(
    'UPDATE ReminderSettings SET dndLunch = :enabled, lastUpdated = :lastUpdated WHERE id = :id',
  )
  Future<void> updateDndLunch(int id, bool enabled, int lastUpdated);

  /// 更新午休时间范围
  @Query(
    'UPDATE ReminderSettings SET lunchStartHour = :startHour, lunchStartMinute = :startMinute, lunchEndHour = :endHour, lunchEndMinute = :endMinute, lastUpdated = :lastUpdated WHERE id = :id',
  )
  Future<void> updateLunchTimeRange(
    int id,
    int startHour,
    int startMinute,
    int endHour,
    int endMinute,
    int lastUpdated,
  );

  /// 更新计划完成勿扰设置
  @Query(
    'UPDATE ReminderSettings SET dndPlan = :enabled, lastUpdated = :lastUpdated WHERE id = :id',
  )
  Future<void> updateDndPlan(int id, bool enabled, int lastUpdated);

  /// 获取所有设置记录
  @Query('SELECT * FROM ReminderSettings ORDER BY lastUpdated DESC')
  Future<List<ReminderSettings>> getAllSettings();

  /// 清空所有设置
  @Query('DELETE FROM ReminderSettings')
  Future<void> clearAllSettings();

  /// 获取设置记录数量
  @Query('SELECT COUNT(*) FROM ReminderSettings')
  Future<int?> getSettingsCount();
}
