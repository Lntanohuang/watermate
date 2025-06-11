/// 定时提醒数据模型
class TimedReminder {
  final String id;
  final int hour;
  final int minute;
  final bool isAM;
  bool isEnabled;

  TimedReminder({
    required this.id,
    required this.hour,
    required this.minute,
    required this.isAM,
    this.isEnabled = true,
  });

  /// 获取24小时制的小时
  int get hour24 {
    if (isAM) {
      return hour == 12 ? 0 : hour;
    } else {
      return hour == 12 ? 12 : hour + 12;
    }
  }

  /// 获取显示用的时间字符串（24小时制）
  String get displayTime {
    return '${hour24.toString().padLeft(2, '0')} : ${minute.toString().padLeft(2, '0')}';
  }

  /// 获取完整的时间字符串（包含AM/PM）
  String get fullDisplayTime {
    return '$displayTime ${isAM ? 'AM' : 'PM'}';
  }

  /// 获取今天的DateTime对象
  DateTime get todayDateTime {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour24, minute);
  }

  /// 获取下次提醒的DateTime对象
  DateTime get nextReminderDateTime {
    final today = todayDateTime;
    final now = DateTime.now();

    // 如果今天的时间已经过了，则安排到明天
    if (today.isBefore(now)) {
      return today.add(const Duration(days: 1));
    }
    return today;
  }

  /// 创建默认的提醒时间列表
  static List<TimedReminder> createDefaultReminders() {
    return [
      TimedReminder(id: '1', hour: 7, minute: 0, isAM: true),
      TimedReminder(id: '2', hour: 9, minute: 30, isAM: true),
      TimedReminder(id: '3', hour: 10, minute: 30, isAM: true),
      TimedReminder(id: '4', hour: 12, minute: 0, isAM: false),
      TimedReminder(id: '5', hour: 3, minute: 0, isAM: false),
      TimedReminder(id: '6', hour: 5, minute: 30, isAM: false),
      TimedReminder(id: '7', hour: 8, minute: 0, isAM: false),
      TimedReminder(id: '8', hour: 10, minute: 0, isAM: false),
    ];
  }
}
