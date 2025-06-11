import 'package:floor/floor.dart';

/// 自定义定时提醒实体类
/// 用于存储用户自定义添加的提醒时间
@Entity()
class CustomTimedReminder {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int hour; // 小时 (1-12，12小时制)
  final int minute; // 分钟 (0-59)
  final bool isAM; // 上午/下午标识
  final bool isEnabled; // 是否启用该提醒
  final int createdAt; // 创建时间戳（毫秒）
  final int lastUpdated; // 最后更新时间戳（毫秒）

  CustomTimedReminder({
    this.id,
    required this.hour,
    required this.minute,
    required this.isAM,
    required this.isEnabled,
    required this.createdAt,
    required this.lastUpdated,
  });

  /// 从DateTime创建CustomTimedReminder
  factory CustomTimedReminder.fromDateTime({
    int? id,
    required int hour,
    required int minute,
    required bool isAM,
    required bool isEnabled,
    required DateTime createdDateTime,
    required DateTime lastUpdatedDateTime,
  }) {
    return CustomTimedReminder(
      id: id,
      hour: hour,
      minute: minute,
      isAM: isAM,
      isEnabled: isEnabled,
      createdAt: createdDateTime.millisecondsSinceEpoch,
      lastUpdated: lastUpdatedDateTime.millisecondsSinceEpoch,
    );
  }

  /// 获取创建时间的DateTime对象
  DateTime get createdDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);

  /// 获取最后更新时间的DateTime对象
  DateTime get lastUpdatedDateTime =>
      DateTime.fromMillisecondsSinceEpoch(lastUpdated);

  /// 转换为24小时制
  int get hour24 {
    if (hour == 12) {
      return isAM ? 0 : 12;
    } else {
      return isAM ? hour : hour + 12;
    }
  }

  /// 显示时间格式 "07 : 00"
  String get displayTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h : $m';
  }

  /// 完整显示格式 "07 : 00 AM"
  String get fullDisplayTime {
    return '$displayTime ${isAM ? 'AM' : 'PM'}';
  }

  /// 获取今天的具体时间
  DateTime get todayDateTime {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour24, minute);
  }

  /// 获取下次提醒时间（如果今天的时间已过，则为明天）
  DateTime get nextReminderDateTime {
    final today = todayDateTime;
    final now = DateTime.now();

    if (today.isAfter(now)) {
      return today;
    } else {
      return today.add(const Duration(days: 1));
    }
  }

  /// 复制并更新部分字段
  CustomTimedReminder copyWith({
    int? id,
    int? hour,
    int? minute,
    bool? isAM,
    bool? isEnabled,
    DateTime? createdDateTime,
    DateTime? lastUpdatedDateTime,
  }) {
    return CustomTimedReminder.fromDateTime(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isAM: isAM ?? this.isAM,
      isEnabled: isEnabled ?? this.isEnabled,
      createdDateTime: createdDateTime ?? this.createdDateTime,
      lastUpdatedDateTime: lastUpdatedDateTime ?? DateTime.now(),
    );
  }

  /// 切换启用状态
  CustomTimedReminder toggleEnabled() {
    return copyWith(isEnabled: !isEnabled);
  }
}
