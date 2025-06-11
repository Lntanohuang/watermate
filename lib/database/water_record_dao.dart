import 'package:floor/floor.dart';
import 'package:watermate/models/water_record.dart';

/// 饮水记录数据访问对象
@dao
abstract class WaterRecordDao {
  /// 插入新的饮水记录
  @insert
  Future<int> insertRecord(WaterRecord record);

  /// 更新饮水记录
  @update
  Future<void> updateRecord(WaterRecord record);

  /// 删除饮水记录
  @delete
  Future<void> deleteRecord(WaterRecord record);

  /// 根据ID删除记录
  @Query('DELETE FROM WaterRecord WHERE id = :id')
  Future<void> deleteRecordById(int id);

  /// 获取指定日期的所有饮水记录，按时间倒序排列
  @Query('SELECT * FROM WaterRecord WHERE date = :date ORDER BY createdAt DESC')
  Future<List<WaterRecord>> getRecordsByDate(String date);

  /// 获取今日的所有饮水记录
  @Query(
    'SELECT * FROM WaterRecord WHERE date = :today ORDER BY createdAt DESC',
  )
  Future<List<WaterRecord>> getTodayRecords(String today);

  /// 获取最近几天的饮水记录
  @Query(
    'SELECT * FROM WaterRecord WHERE date >= :startDate ORDER BY date DESC, createdAt DESC LIMIT :limit',
  )
  Future<List<WaterRecord>> getRecentRecords(String startDate, int limit);

  /// 获取指定日期范围内的记录
  @Query(
    'SELECT * FROM WaterRecord WHERE date BETWEEN :startDate AND :endDate ORDER BY date DESC, createdAt DESC',
  )
  Future<List<WaterRecord>> getRecordsBetweenDates(
    String startDate,
    String endDate,
  );

  /// 获取指定日期的总饮水量
  @Query('SELECT SUM(amount) FROM WaterRecord WHERE date = :date')
  Future<int?> getTotalAmountByDate(String date);

  /// 获取所有记录
  @Query('SELECT * FROM WaterRecord ORDER BY date DESC, createdAt DESC')
  Future<List<WaterRecord>> getAllRecords();

  /// 根据ID获取记录
  @Query('SELECT * FROM WaterRecord WHERE id = :id')
  Future<WaterRecord?> getRecordById(int id);

  /// 清空所有记录
  @Query('DELETE FROM WaterRecord')
  Future<void> clearAllRecords();

  /// 获取记录总数
  @Query('SELECT COUNT(*) FROM WaterRecord')
  Future<int?> getRecordCount();

  /// 获取指定饮品类型的记录数量
  @Query('SELECT COUNT(*) FROM WaterRecord WHERE drinkType = :drinkType')
  Future<int?> getRecordCountByDrinkType(String drinkType);
}
