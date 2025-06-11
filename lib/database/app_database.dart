import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:watermate/models/user.dart';
import 'package:watermate/models/daily_water_intake.dart';
import 'package:watermate/models/water_record.dart';
import 'package:watermate/models/reminder_settings.dart';
import 'package:watermate/models/custom_timed_reminder.dart';
import 'user_dao.dart';
import 'daily_water_intake_dao.dart';
import 'water_record_dao.dart';
import 'reminder_settings_dao.dart';
import 'custom_timed_reminder_dao.dart';

// 这行是必需的，Floor 会生成对应的实现文件
part 'app_database.g.dart';

/// 应用数据库配置
/// 包含用户信息、每日饮水记录、详细饮水记录、提醒设置和自定义提醒五个表
@Database(
  version: 4,
  entities: [
    User,
    DailyWaterIntake,
    WaterRecord,
    ReminderSettings,
    CustomTimedReminder,
  ],
)
abstract class AppDatabase extends FloorDatabase {
  /// 用户数据访问对象
  UserDao get userDao;

  /// 每日饮水记录数据访问对象
  DailyWaterIntakeDao get dailyWaterIntakeDao;

  /// 饮水记录数据访问对象
  WaterRecordDao get waterRecordDao;

  /// 提醒设置数据访问对象
  ReminderSettingsDao get reminderSettingsDao;

  /// 自定义定时提醒数据访问对象
  CustomTimedReminderDao get customTimedReminderDao;
}
