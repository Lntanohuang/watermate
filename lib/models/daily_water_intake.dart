import 'package:floor/floor.dart';

/// 每日饮水量记录实体类
@Entity()
class DailyWaterIntake {
  /// 主键：日期字符串，格式为 'yyyy-MM-dd'
  @primaryKey
  final String date;

  final int totalIntake;
  final int lastUpdated;//最后更新时间（时间戳，毫秒）用于记录该记录最后一次修改的时间戳

  /// 构造函数
  /// [date] 日期字符串
  /// [totalIntake] 总饮水量(ml)
  /// [lastUpdated] 最后更新时间戳（毫秒）
  DailyWaterIntake({
    required this.date,
    required this.totalIntake,
    required this.lastUpdated,
  });

  /// 获取 DateTime 格式的最后更新时间
  DateTime get lastUpdatedDateTime =>
      DateTime.fromMillisecondsSinceEpoch(lastUpdated);

  /// 从 DateTime 创建 DailyWaterIntake
  factory DailyWaterIntake.fromDateTime({
    required String date,
    required int totalIntake,
    required DateTime lastUpdatedDateTime,
  }) {
    return DailyWaterIntake(
      date: date,
      totalIntake: totalIntake,
      lastUpdated: lastUpdatedDateTime.millisecondsSinceEpoch,
    );
  }
}
