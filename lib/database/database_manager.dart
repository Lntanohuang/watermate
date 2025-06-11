import 'package:watermate/database/app_database.dart';
import 'package:watermate/models/user.dart';
import 'package:watermate/models/daily_water_intake.dart';
import 'package:watermate/models/water_record.dart';
import 'package:watermate/models/reminder_settings.dart';
import 'package:watermate/utils/user_setup_manager.dart';

/// 数据库管理器
/// 负责数据库的懒加载初始化和提供全局访问
class DatabaseManager {
  static DatabaseManager? _instance;
  static AppDatabase? _database;

  // 私有构造函数
  DatabaseManager._();

  /// 获取单例实例
  static DatabaseManager get instance {
    _instance ??= DatabaseManager._();
    return _instance!;
  }

  /// 懒加载获取数据库实例
  /// 第一次调用时会自动初始化数据库
  Future<AppDatabase> get database async {
    if (_database == null) {
      await _initDatabase();
    }
    return _database!;
  }

  /// 私有的数据库初始化方法
  Future<void> _initDatabase() async {
    _database =
        await $FloorAppDatabase
            .databaseBuilder('watermate_database_v5.db')
            .build();

    // 检查是否需要创建默认用户
    await _createDefaultUserIfNeeded();

    // 检查是否需要创建默认提醒设置
    await _createDefaultReminderSettingsIfNeeded();
  }

  /// 创建默认用户（如果不存在）
  Future<void> _createDefaultUserIfNeeded() async {
    final user = await _database!.userDao.getUser();
    if (user == null) {
      // 获取用户在引导过程中设置的数据
      final userSetup = UserSetupManager();

      // 根据体重和运动量计算目标饮水量
      final targetWaterIntake = _calculateTargetWaterIntake(
        userSetup.weight,
        userSetup.exerciseVolume,
      );

      // 创建用户，使用引导过程中设置的数据
      final defaultUser = User(
        id: 1,
        age: 25, // 年龄暂时使用默认值，后续可以在引导中添加
        gender: userSetup.gender,
        weight: userSetup.weight,
        exerciseVolume: userSetup.exerciseVolume,
        targetWaterIntake: targetWaterIntake,
        checkInDays: 0,
        reminderStartTime: 420, // 默认7:00开始提醒
        reminderEndTime: 1020, // 默认17:00结束提醒
      );
      await _database!.userDao.insertUser(defaultUser);

      // 清空临时数据
      userSetup.clear();
    }
  }

  /// 创建默认提醒设置（如果不存在）
  Future<void> _createDefaultReminderSettingsIfNeeded() async {
    final settings = await _database!.reminderSettingsDao.getCurrentSettings();
    if (settings == null) {
      // 创建默认提醒设置
      final defaultSettings = ReminderSettings.fromDateTime(
        allReminders: true,
        intervalRemind: true,
        reminderInterval: 60,
        dndTime: true,
        reminderStartHour: 7,
        reminderStartMinute: 0,
        reminderEndHour: 22,
        reminderEndMinute: 0,
        dndLunch: true,
        lunchStartHour: 12,
        lunchStartMinute: 0,
        lunchEndHour: 13,
        lunchEndMinute: 0,
        dndPlan: true,
        lastUpdatedDateTime: DateTime.now(),
      );
      await _database!.reminderSettingsDao.insertSettings(defaultSettings);
      print('默认提醒设置已创建');
    }
  }

  /// 根据体重和运动量计算目标饮水量（私有方法，向后兼容）
  int _calculateTargetWaterIntake(double weight, String exerciseVolume) {
    return calculateTargetWaterIntake(
      weight: weight,
      gender: 'male', // 默认值，保持向后兼容
      exerciseVolume: exerciseVolume,
    );
  }

  /// 根据体重、性别和运动量计算目标饮水量（公共静态方法）
  static int calculateTargetWaterIntake({
    required double weight,
    required String gender,
    required String exerciseVolume,
  }) {
    // 基础饮水量：体重(kg) × 35ml
    double baseIntake = weight * 35;

    // 根据性别调整（女性新陈代谢略低）
    double genderMultiplier = switch (gender.toLowerCase()) {
      'female' => 0.95,
      'male' => 1.0,
      _ => 1.0,
    };

    // 根据运动量调整
    double exerciseMultiplier = switch (exerciseVolume.toLowerCase()) {
      'sedentary' => 1.0,
      'light exercise' => 1.2,
      'moderate exercise' => 1.4,
      'moderate intensity exercise' => 1.4, // 向后兼容
      'intense exercise' => 1.6,
      'high intensity exercise' => 1.6, // 向后兼容
      _ => 1.2,
    };

    // 计算最终目标饮水量
    return (baseIntake * genderMultiplier * exerciseMultiplier).round();
  }

  /// 获取今日饮水记录，如果不存在则创建
  Future<DailyWaterIntake> getTodayWaterIntake() async {
    final db = await database;
    final today = DateTime.now();
    final dateString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    var todayIntake = await db.dailyWaterIntakeDao.getDailyIntake(dateString);

    if (todayIntake == null) {
      // 创建今日记录
      todayIntake = DailyWaterIntake.fromDateTime(
        date: dateString,
        totalIntake: 0,
        lastUpdatedDateTime: DateTime.now(),
      );
      await db.dailyWaterIntakeDao.insertDailyIntake(todayIntake);
    }

    return todayIntake;
  }

  /// 添加饮水量
  Future<void> addWaterIntake(int amount) async {
    final db = await database;
    final today = DateTime.now();
    final dateString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // 确保今日记录存在
    await getTodayWaterIntake();

    // 更新饮水量
    await db.dailyWaterIntakeDao.addWaterIntake(
      dateString,
      amount,
      DateTime.now().millisecondsSinceEpoch, // 转换为时间戳
    );
  }

  /// 添加详细饮水记录
  Future<int> addWaterRecord({
    required String drinkType,
    required String drinkName,
    required String iconPath,
    required int amount,
    DateTime? dateTime,
  }) async {
    final db = await database;
    final recordTime = dateTime ?? DateTime.now();

    // 创建饮水记录
    final record = WaterRecord.fromDateTime(
      dateTime: recordTime,
      drinkType: drinkType,
      drinkName: drinkName,
      iconPath: iconPath,
      amount: amount,
    );

    // 插入记录并获取ID
    final recordId = await db.waterRecordDao.insertRecord(record);

    // 同时更新每日总量（使用记录的日期）
    await addWaterIntakeForDate(amount, recordTime);

    // 自动更新签到天数
    await calculateAndUpdateCheckInDays();

    return recordId;
  }

  /// 为指定日期添加饮水量
  Future<void> addWaterIntakeForDate(int amount, DateTime date) async {
    final db = await database;
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // 确保该日期的记录存在
    var dayIntake = await db.dailyWaterIntakeDao.getDailyIntake(dateString);
    if (dayIntake == null) {
      // 创建该日期的记录
      dayIntake = DailyWaterIntake.fromDateTime(
        date: dateString,
        totalIntake: 0,
        lastUpdatedDateTime: DateTime.now(),
      );
      await db.dailyWaterIntakeDao.insertDailyIntake(dayIntake);
    }

    // 更新饮水量
    await db.dailyWaterIntakeDao.addWaterIntake(
      dateString,
      amount,
      DateTime.now().millisecondsSinceEpoch, // 转换为时间戳
    );
  }

  /// 获取今日的详细饮水记录
  Future<List<WaterRecord>> getTodayWaterRecords() async {
    final db = await database;
    final today = DateTime.now();
    final dateString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return await db.waterRecordDao.getTodayRecords(dateString);
  }

  /// 删除饮水记录
  Future<void> deleteWaterRecord(WaterRecord record) async {
    final db = await database;

    // 删除记录
    await db.waterRecordDao.deleteRecord(record);

    // 更新每日总量（减去删除的量）
    final today = DateTime.now();
    final dateString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // 如果是今天的记录，需要更新总量
    if (record.date == dateString) {
      await db.dailyWaterIntakeDao.addWaterIntake(
        dateString,
        -record.amount, // 负数表示减少
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    // 自动更新签到天数
    await calculateAndUpdateCheckInDays();
  }

  /// 关闭数据库
  Future<void> closeDatabase() async {
    await _database?.close();
    _database = null;
  }

  /// 计算并更新签到天数（有饮水数据的天数）
  Future<int> calculateAndUpdateCheckInDays() async {
    final db = await database;

    // 获取所有有饮水数据的记录
    final allIntakes = await db.dailyWaterIntakeDao.getAllIntakes();

    // 过滤出有饮水量的天数（totalIntake > 0）
    final checkInDays =
        allIntakes.where((intake) => intake.totalIntake > 0).length;

    // 更新用户的签到天数
    await db.userDao.updateCheckInDays(checkInDays);

    return checkInDays;
  }

  /// 获取有饮水数据的天数
  Future<int> getCheckInDays() async {
    final db = await database;

    // 获取所有有饮水数据的记录
    final allIntakes = await db.dailyWaterIntakeDao.getAllIntakes();

    // 过滤出有饮水量的天数（totalIntake > 0）
    return allIntakes.where((intake) => intake.totalIntake > 0).length;
  }

  /// 重新计算并更新目标饮水量
  Future<int> recalculateAndUpdateTargetWaterIntake() async {
    final db = await database;

    // 获取当前用户信息
    final user = await db.userDao.getUser();
    if (user == null) {
      throw Exception('User not found');
    }

    // 重新计算目标饮水量
    final newTargetIntake = calculateTargetWaterIntake(
      weight: user.weight,
      gender: user.gender,
      exerciseVolume: user.exerciseVolume,
    );

    // 更新数据库中的目标饮水量
    await db.userDao.updateTargetWaterIntake(newTargetIntake);

    return newTargetIntake;
  }
}
