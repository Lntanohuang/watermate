import 'package:floor/floor.dart';

@Entity()
class User {
  @primaryKey
  final int id; // 固定为1，单用户应用
  final int age;
  final String gender;
  final double weight; // 体重 (kg)
  final String exerciseVolume; // 运动量
  final int targetWaterIntake; // 目标饮水量 (ml)
  final int checkInDays; // 打卡天数
  final int reminderStartTime; // 提醒开始时间（分钟，0-1440）
  final int reminderEndTime; // 提醒结束时间（分钟，0-1440）

  User({
    required this.id,
    required this.age,
    required this.gender,
    required this.weight,
    required this.exerciseVolume,
    required this.targetWaterIntake,
    required this.checkInDays,
    required this.reminderStartTime,
    required this.reminderEndTime,
  });
}
