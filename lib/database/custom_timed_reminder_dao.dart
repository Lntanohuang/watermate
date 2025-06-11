import 'package:floor/floor.dart';
import 'package:watermate/models/custom_timed_reminder.dart';

/// 自定义定时提醒数据访问对象
@dao
abstract class CustomTimedReminderDao {
  /// 插入新的自定义提醒
  @insert
  Future<int> insertReminder(CustomTimedReminder reminder);

  /// 更新已存在的自定义提醒
  @update
  Future<void> updateReminder(CustomTimedReminder reminder);

  /// 删除自定义提醒
  @delete
  Future<void> deleteReminder(CustomTimedReminder reminder);

  /// 根据ID删除提醒
  @Query('DELETE FROM CustomTimedReminder WHERE id = :id')
  Future<void> deleteReminderById(int id);

  /// 获取所有自定义提醒，按时间排序
  @Query(
    'SELECT * FROM CustomTimedReminder ORDER BY isAM DESC, hour ASC, minute ASC',
  )
  Future<List<CustomTimedReminder>> getAllReminders();

  /// 获取所有启用的自定义提醒
  @Query(
    'SELECT * FROM CustomTimedReminder WHERE isEnabled = 1 ORDER BY isAM DESC, hour ASC, minute ASC',
  )
  Future<List<CustomTimedReminder>> getEnabledReminders();

  /// 获取所有禁用的自定义提醒
  @Query(
    'SELECT * FROM CustomTimedReminder WHERE isEnabled = 0 ORDER BY isAM DESC, hour ASC, minute ASC',
  )
  Future<List<CustomTimedReminder>> getDisabledReminders();

  /// 根据ID获取提醒
  @Query('SELECT * FROM CustomTimedReminder WHERE id = :id')
  Future<CustomTimedReminder?> getReminderById(int id);

  /// 根据时间查找提醒
  @Query(
    'SELECT * FROM CustomTimedReminder WHERE hour = :hour AND minute = :minute AND isAM = :isAM',
  )
  Future<CustomTimedReminder?> getReminderByTime(
    int hour,
    int minute,
    bool isAM,
  );

  /// 更新提醒启用状态
  @Query(
    'UPDATE CustomTimedReminder SET isEnabled = :enabled, lastUpdated = :lastUpdated WHERE id = :id',
  )
  Future<void> updateReminderEnabled(int id, bool enabled, int lastUpdated);

  /// 批量更新提醒启用状态
  @Query(
    'UPDATE CustomTimedReminder SET isEnabled = :enabled, lastUpdated = :lastUpdated',
  )
  Future<void> updateAllRemindersEnabled(bool enabled, int lastUpdated);

  /// 获取启用的提醒数量
  @Query('SELECT COUNT(*) FROM CustomTimedReminder WHERE isEnabled = 1')
  Future<int?> getEnabledReminderCount();

  /// 获取提醒总数
  @Query('SELECT COUNT(*) FROM CustomTimedReminder')
  Future<int?> getTotalReminderCount();

  /// 检查指定时间是否已存在提醒
  @Query(
    'SELECT COUNT(*) FROM CustomTimedReminder WHERE hour = :hour AND minute = :minute AND isAM = :isAM',
  )
  Future<int?> checkReminderExists(int hour, int minute, bool isAM);

  /// 清空所有自定义提醒
  @Query('DELETE FROM CustomTimedReminder')
  Future<void> clearAllReminders();

  /// 获取最近创建的提醒
  @Query(
    'SELECT * FROM CustomTimedReminder ORDER BY createdAt DESC LIMIT :limit',
  )
  Future<List<CustomTimedReminder>> getRecentReminders(int limit);

  /// 获取指定日期创建的提醒
  @Query(
    'SELECT * FROM CustomTimedReminder WHERE createdAt >= :startTimestamp AND createdAt <= :endTimestamp ORDER BY createdAt DESC',
  )
  Future<List<CustomTimedReminder>> getRemindersByDateRange(
    int startTimestamp,
    int endTimestamp,
  );
}
