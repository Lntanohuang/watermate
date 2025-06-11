import 'package:floor/floor.dart';
import 'package:watermate/models/daily_water_intake.dart';

/// 提供对每日饮水记录的数据库操作方法
@dao
abstract class DailyWaterIntakeDao {
  /// 插入新的每日饮水记录
  /// [intake] 要插入的饮水记录
  @insert
  Future<void> insertDailyIntake(DailyWaterIntake intake);

  /// 更新已存在的每日饮水记录
  /// [intake] 要更新的饮水记录
  @update
  Future<void> updateDailyIntake(DailyWaterIntake intake);

  /// 根据日期获取特定日期的饮水记录
  /// [date] 日期字符串，格式：'yyyy-MM-dd'
  /// 返回该日期的饮水记录，如果不存在则返回null
  @Query('SELECT * FROM DailyWaterIntake WHERE date = :date')
  Future<DailyWaterIntake?> getDailyIntake(String date);

  /// 获取最近几天的饮水记录
  /// [limit] 要获取的记录数量
  /// 返回按日期降序排列的最近记录列表
  @Query('SELECT * FROM DailyWaterIntake ORDER BY date DESC LIMIT :limit')
  Future<List<DailyWaterIntake>> getRecentIntakes(int limit);

  /// 增加指定日期的饮水量
  /// [date] 日期字符串
  /// [amount] 要增加的饮水量(ml)
  /// [lastUpdated] 更新时间戳（毫秒）
  /// 注意：如果该日期记录不存在，此方法不会创建新记录
  @Query(
    'UPDATE DailyWaterIntake SET totalIntake = totalIntake + :amount, lastUpdated = :lastUpdated WHERE date = :date',
  )
  Future<void> addWaterIntake(String date, int amount, int lastUpdated);

  /// 获取所有饮水记录
  /// 返回所有记录，按日期升序排列
  @Query('SELECT * FROM DailyWaterIntake ORDER BY date ASC')
  Future<List<DailyWaterIntake>> getAllIntakes();

  /// 删除指定日期的饮水记录
  /// [date] 要删除记录的日期
  @Query('DELETE FROM DailyWaterIntake WHERE date = :date')
  Future<void> deleteDailyIntake(String date);

  /// 获取指定日期范围内的饮水记录
  /// [startDate] 开始日期
  /// [endDate] 结束日期
  /// 返回该时间段内的所有记录
  @Query(
    'SELECT * FROM DailyWaterIntake WHERE date BETWEEN :startDate AND :endDate ORDER BY date ASC',
  )
  Future<List<DailyWaterIntake>> getIntakesBetweenDates(
    String startDate,
    String endDate,
  );
}
