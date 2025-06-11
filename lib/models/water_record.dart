import 'package:floor/floor.dart';

/// 饮水记录实体类
/// 用于存储用户每次饮水的详细记录
@Entity()
class WaterRecord {
  @PrimaryKey(autoGenerate: true)
  final int? id; // 主键：自增ID
  final String date; // 日期
  final String time; // 时间
  final String drinkType; // 饮品类型（如：water, milk_tea, coffee等）
  final String drinkName; // 饮品名称（显示用）
  final String iconPath; // 饮品图标路径
  final int amount; // 饮水量（毫升）
  final int createdAt; // 创建时间戳（毫秒）

  WaterRecord({
    this.id,
    required this.date,
    required this.time,
    required this.drinkType,
    required this.drinkName,
    required this.iconPath,
    required this.amount,
    required this.createdAt,
  });

  /// 从DateTime创建WaterRecord
  factory WaterRecord.fromDateTime({
    int? id,
    required DateTime dateTime,
    required String drinkType,
    required String drinkName,
    required String iconPath,
    required int amount,
  }) {
    final date =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return WaterRecord(
      id: id,
      date: date,
      time: time,
      drinkType: drinkType,
      drinkName: drinkName,
      iconPath: iconPath,
      amount: amount,
      createdAt: dateTime.millisecondsSinceEpoch,
    );
  }

  /// 获取创建时间的DateTime对象
  DateTime get createdDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);

  /// 获取格式化的时间显示（如：9:41 AM）
  String get formattedTime {
    final dateTime = DateTime.parse('2024-01-01 $time:00');
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// 获取格式化的饮水量显示
  String get formattedAmount => '${amount}ml';
}
