import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:watermate/components/bar.dart';
import 'package:watermate/pages/personal/personal_information.dart';
import 'package:watermate/components/basic.dart';
import 'package:watermate/database/database_manager.dart';
import 'package:watermate/pages/water/add_water.dart';
import 'package:watermate/utils/toast_utils.dart' hide themeColor3;
import 'package:watermate/components/day_with_progress.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, double> _waterProgressMap = {}; // 存储每日饮水完成比例
  int _targetWaterIntake = 2000; // 目标饮水量

  @override
  void initState() {
    super.initState();
    _loadWaterData();
  }

  /// 加载饮水数据
  Future<void> _loadWaterData() async {
    try {
      final db = await DatabaseManager.instance.database;

      // 获取用户目标饮水量
      final user = await db.userDao.getUser();
      _targetWaterIntake = user?.targetWaterIntake ?? 2000;

      // 获取当前月份的所有饮水记录
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      final startDate =
          '${firstDayOfMonth.year}-${firstDayOfMonth.month.toString().padLeft(2, '0')}-${firstDayOfMonth.day.toString().padLeft(2, '0')}';
      final endDate =
          '${lastDayOfMonth.year}-${lastDayOfMonth.month.toString().padLeft(2, '0')}-${lastDayOfMonth.day.toString().padLeft(2, '0')}';

      final intakes = await db.dailyWaterIntakeDao.getIntakesBetweenDates(
        startDate,
        endDate,
      );

      // 计算每日完成比例
      Map<String, double> progressMap = {};
      for (var intake in intakes) {
        double progress = intake.totalIntake / _targetWaterIntake;
        progressMap[intake.date] = progress.clamp(0.0, 1.0);
      }

      setState(() {
        _waterProgressMap = progressMap;
      });
    } catch (e) {
      print('Failed to load water data: $e');
    }
  }

  /// 获取指定日期的饮水完成比例
  double _getWaterProgress(DateTime date) {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _waterProgressMap[dateString] ?? 0.0;
  }

  /// 处理补签功能
  Future<void> _handleMakeUpCheckIn() async {
    // 检查是否选择了日期
    if (_selectedDay == null) {
      ToastUtils.showWarning(context, 'Please select a date first');
      return;
    }

    // 检查选择的日期是否是未来日期
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    if (selectedDate.isAfter(today)) {
      ToastUtils.showWarning(context, 'Can\'t make up for future dates');
      return;
    }

    // 跳转到添加饮水页面，并传递选中的日期
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => DrinkSelectPage(targetDate: _selectedDay),
      ),
    );

    // 如果成功添加了饮水记录，刷新数据
    if (result == true) {
      await _loadWaterData();
      final dateString =
          '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}';
      if (mounted) {
        ToastUtils.showSuccess(
          context,
          ' Successfully added water intake for $dateString',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            CommonTopBar(
              title: 'My check-in',
              onBack: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const PersonalInformationPage(),
                  ),
                  (route) => false,
                );
              },
            ),
            // 日历卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                    // 当月份改变时重新加载数据
                    _loadWaterData();
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: false,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Color(0xFFB0C4D6),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Color(0xFFB0C4D6),
                    ),
                    titleTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Color(0xFF3A4D5C),
                      fontWeight: FontWeight.bold,
                    ),
                    todayTextStyle: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendTextStyle: const TextStyle(color: Colors.black),
                    defaultTextStyle: const TextStyle(color: Colors.black),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Color(0xFFB0B8C1),
                      fontWeight: FontWeight.w500,
                    ),
                    weekendStyle: TextStyle(
                      color: Color(0xFFB0B8C1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  calendarFormat: CalendarFormat.month,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  // 自定义日期构建器，添加饮水进度圆圈
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return DayWithProgress(
                        day: day,
                        isToday: false,
                        isSelected: false,
                        progress: _getWaterProgress(day),
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return DayWithProgress(
                        day: day,
                        isToday: true,
                        isSelected: false,
                        progress: _getWaterProgress(day),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return DayWithProgress(
                        day: day,
                        isToday: false,
                        isSelected: true,
                        progress: _getWaterProgress(day),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 选中日期信息显示
            if (_selectedDay != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeColor3.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Selected day: ${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Color(0xFF3A4D5C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Water intake: ${(_getWaterProgress(_selectedDay!) * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: themeColor3,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 补签按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      _selectedDay != null ? themeColor3 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton(
                  onPressed: _selectedDay != null ? _handleMakeUpCheckIn : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _selectedDay != null
                          ? 'make up the check-in'
                          : 'please select a date first',
                      style: TextStyle(
                        color:
                            _selectedDay != null
                                ? Colors.white
                                : const Color(0xFF3A4D5C),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    foregroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
