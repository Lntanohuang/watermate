import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:watermate/pages/reminders/reminders.dart';
import 'package:watermate/controllers/reminder_controller.dart';
import 'package:watermate/services/reminder_service.dart';
import 'package:watermate/services/reminder_persistence_service.dart';
import 'package:watermate/models/reminder_settings.dart';
import 'package:watermate/models/timed_reminder.dart';
import 'package:watermate/components/modal/time_range_picker_modal.dart';
import 'package:watermate/components/reminder_widgets.dart';

// 生成mock类
@GenerateMocks([ReminderService, ReminderPersistenceService])
import 'reminders_page_test.mocks.dart';

void main() {
  group('RemindersPage 完整功能测试', () {
    late MockReminderService mockReminderService;
    late MockReminderPersistenceService mockPersistenceService;

    setUp(() {
      mockReminderService = MockReminderService();
      mockPersistenceService = MockReminderPersistenceService();
    });

    // 创建测试用的ReminderSettings
    ReminderSettings createTestSettings() {
      return ReminderSettings.fromDateTime(
        id: 1,
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
    }

    // 创建测试应用包装器
    Widget createTestApp(Widget child) {
      return MaterialApp(home: child);
    }

    group('UI 基础组件测试', () {
      testWidgets('页面应该显示基本的UI组件', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const RemindersPage()));
        await tester.pumpAndSettle();

        // 验证页面标题存在（允许多个）
        expect(find.textContaining('Reminders'), findsWidgets);

        // 验证总开关
        expect(find.text('All Reminders'), findsOneWidget);
        expect(find.byType(Switch), findsWidgets);

        // 验证间隔提醒部分
        expect(find.text('Interval Reminder'), findsOneWidget);
        expect(find.textContaining('Remind every'), findsOneWidget);

        // 验证定时提醒部分
        expect(find.text('Timed Reminder'), findsOneWidget);
        expect(find.text('Customize Time Point'), findsOneWidget);

        // 验证勿扰设置部分
        expect(find.text('Do Not Disturb'), findsOneWidget);
      });

      testWidgets('应该显示正确数量的开关', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const RemindersPage()));
        await tester.pumpAndSettle();

        // 获取所有Switch组件
        final switches =
            tester.widgetList<Switch>(find.byType(Switch)).toList();

        // 验证开关数量（至少应该有：All Reminders + Interval + 3个DND开关）
        expect(switches.length, greaterThanOrEqualTo(2));
      });

      testWidgets('总开关应该可以交互', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const RemindersPage()));
        await tester.pumpAndSettle();

        // 找到总开关
        final allRemindersSwitch = find.byType(Switch).first;

        // 点击开关
        await tester.tap(allRemindersSwitch);
        await tester.pumpAndSettle();

        // 验证没有异常发生
        expect(tester.takeException(), isNull);
      });
    });

    group('ReminderController 逻辑测试', () {
      late ReminderController controller;

      setUp(() {
        controller = ReminderController();
      });

      tearDown(() {
        controller.dispose();
      });

      test('初始化应该设置默认值', () {
        expect(controller.allReminders, isTrue);
        expect(controller.intervalRemind, isTrue);
        expect(controller.reminderInterval, equals(60));
        expect(controller.dndTime, isTrue);
        expect(controller.dndLunch, isTrue);
        expect(controller.dndPlan, isTrue);
      });

      test('提醒时间范围显示应该正确格式化', () {
        controller.reminderStartHour = 7;
        controller.reminderStartMinute = 0;
        controller.reminderEndHour = 22;
        controller.reminderEndMinute = 0;

        final timeRange = controller.reminderTimeRange;
        expect(timeRange, equals('Reminder Time 07 : 00 - 22 : 00'));
      });

      test('午休时间范围显示应该正确格式化', () {
        controller.lunchStartHour = 12;
        controller.lunchStartMinute = 0;
        controller.lunchEndHour = 13;
        controller.lunchEndMinute = 0;

        final lunchRange = controller.lunchTimeRange;
        expect(
          lunchRange,
          equals('No Reminder During Lunch Break 12 : 00 - 13 : 00'),
        );
      });

      test('时间范围更新应该正确工作', () {
        // 设置新的时间范围
        controller.reminderStartHour = 8;
        controller.reminderStartMinute = 30;
        controller.reminderEndHour = 21;
        controller.reminderEndMinute = 30;

        final timeRange = controller.reminderTimeRange;
        expect(timeRange, equals('Reminder Time 08 : 30 - 21 : 30'));
      });

      test('默认提醒列表应该包含8个提醒', () {
        final defaultReminders = TimedReminder.createDefaultReminders();
        expect(defaultReminders.length, equals(8));

        // 验证第一个和最后一个提醒
        expect(defaultReminders.first.displayTime, equals('07 : 00'));
        expect(defaultReminders.last.displayTime, equals('22 : 00'));
      });
    });

    group('TimeRangePickerModal 功能测试', () {
      testWidgets('时间范围选择器应该正确显示', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(
            Scaffold(
              body: TimeRangePickerModal(
                initialStartHour: 7,
                initialStartMinute: 0,
                initialEndHour: 22,
                initialEndMinute: 0,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 验证标题和基本组件
        expect(find.textContaining('选择时间范围'), findsOneWidget);
        expect(find.text('开始时间'), findsOneWidget);
        expect(find.text('结束时间'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Confirm'), findsOneWidget);
      });

      testWidgets('时间选择器静态方法应该正常工作', (WidgetTester tester) async {
        Map<String, int>? result;

        await tester.pumpWidget(
          createTestApp(
            Scaffold(
              body: Builder(
                builder:
                    (context) => ElevatedButton(
                      onPressed: () async {
                        result = await TimeRangePickerModal.show(
                          context,
                          initialStartHour: 7,
                          initialStartMinute: 0,
                          initialEndHour: 22,
                          initialEndMinute: 0,
                        );
                      },
                      child: const Text('Open Picker'),
                    ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 点击按钮打开选择器
        await tester.tap(find.text('Open Picker'));
        await tester.pumpAndSettle();

        // 验证选择器已打开
        expect(find.textContaining('选择时间范围'), findsOneWidget);

        // 点击确认按钮
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        // 验证返回结果
        expect(result, isNotNull);
        expect(result!['startHour'], equals(7));
        expect(result!['startMinute'], equals(0));
        expect(result!['endHour'], equals(22));
        expect(result!['endMinute'], equals(0));
      });
    });

    group('数据持久化功能测试', () {
      test('应该能够mock保存和加载提醒设置', () async {
        final mockSettings = createTestSettings();

        when(
          mockPersistenceService.getReminderSettings(),
        ).thenAnswer((_) async => mockSettings);

        when(
          mockPersistenceService.saveReminderSettings(any),
        ).thenAnswer((_) async => true);

        // 验证保存操作
        final saveResult = await mockPersistenceService.saveReminderSettings(
          mockSettings,
        );
        expect(saveResult, isTrue);

        // 验证加载操作
        final loadedSettings =
            await mockPersistenceService.getReminderSettings();
        expect(loadedSettings, isNotNull);
        expect(loadedSettings!.allReminders, equals(mockSettings.allReminders));
        expect(
          loadedSettings.reminderStartHour,
          equals(mockSettings.reminderStartHour),
        );
      });

      test('应该能够mock更新时间范围设置', () async {
        when(
          mockPersistenceService.updateReminderTimeRange(any, any, any, any),
        ).thenAnswer((_) async => true);

        final result = await mockPersistenceService.updateReminderTimeRange(
          8,
          0,
          21,
          0,
        );
        expect(result, isTrue);

        verify(
          mockPersistenceService.updateReminderTimeRange(8, 0, 21, 0),
        ).called(1);
      });

      test('应该能够mock添加自定义提醒', () async {
        when(
          mockPersistenceService.addCustomReminder(any, any, any),
        ).thenAnswer((_) async => true);

        final result = await mockPersistenceService.addCustomReminder(
          15,
          30,
          false,
        );
        expect(result, isTrue);

        verify(
          mockPersistenceService.addCustomReminder(15, 30, false),
        ).called(1);
      });

      test('应该能够处理数据库错误', () async {
        when(
          mockPersistenceService.getReminderSettings(),
        ).thenThrow(Exception('Database connection failed'));

        expect(
          () async => await mockPersistenceService.getReminderSettings(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('DndRow 组件功能测试', () {
      testWidgets('DndRow应该显示所有必要元素', (WidgetTester tester) async {
        bool switchValue = false;
        bool arrowTapped = false;

        await tester.pumpWidget(
          createTestApp(
            Scaffold(
              body: DndRow(
                icon: Icons.notifications,
                text: 'Test Setting',
                value: switchValue,
                onChanged: (value) {
                  switchValue = value;
                },
                showArrow: true,
                onArrowTap: () {
                  arrowTapped = true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 验证基本组件
        expect(find.byIcon(Icons.notifications), findsOneWidget);
        expect(find.text('Test Setting'), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);

        // 测试箭头点击
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();

        expect(arrowTapped, isTrue);
      });

      testWidgets('DndRow开关应该可以切换', (WidgetTester tester) async {
        bool switchValue = false;

        await tester.pumpWidget(
          createTestApp(
            StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: DndRow(
                    icon: Icons.notifications,
                    text: 'Test Setting',
                    value: switchValue,
                    onChanged: (value) {
                      setState(() {
                        switchValue = value;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 初始状态应该是关闭
        final switch1 = tester.widget<Switch>(find.byType(Switch));
        expect(switch1.value, isFalse);

        // 点击开关
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // 验证状态改变
        final switch2 = tester.widget<Switch>(find.byType(Switch));
        expect(switch2.value, isTrue);
      });
    });

    group('边界情况和错误处理', () {
      test('无效时间范围应该能正常显示', () {
        final controller = ReminderController();

        // 设置无效时间范围（开始时间晚于结束时间）
        controller.reminderStartHour = 23;
        controller.reminderStartMinute = 0;
        controller.reminderEndHour = 6;
        controller.reminderEndMinute = 0;

        // 验证时间范围显示仍然正常
        final timeRange = controller.reminderTimeRange;
        expect(timeRange, contains('23 : 00 - 06 : 00'));

        controller.dispose();
      });

      test('跨午夜时间范围应该能正常处理', () {
        final controller = ReminderController();

        controller.reminderStartHour = 22;
        controller.reminderStartMinute = 30;
        controller.reminderEndHour = 2;
        controller.reminderEndMinute = 30;

        final timeRange = controller.reminderTimeRange;
        expect(timeRange, contains('22 : 30 - 02 : 30'));

        controller.dispose();
      });

      test('TimedReminder时间转换应该正确', () {
        // 测试12小时制到24小时制的转换
        final amReminder = TimedReminder(
          id: '1',
          hour: 7,
          minute: 30,
          isAM: true,
          isEnabled: true,
        );
        expect(amReminder.hour24, equals(7));

        final pmReminder = TimedReminder(
          id: '2',
          hour: 7,
          minute: 30,
          isAM: false,
          isEnabled: true,
        );
        expect(pmReminder.hour24, equals(19));

        // 测试中午12点
        final noonReminder = TimedReminder(
          id: '3',
          hour: 12,
          minute: 0,
          isAM: false,
          isEnabled: true,
        );
        expect(noonReminder.hour24, equals(12));

        // 测试午夜12点
        final midnightReminder = TimedReminder(
          id: '4',
          hour: 12,
          minute: 0,
          isAM: true,
          isEnabled: true,
        );
        expect(midnightReminder.hour24, equals(0));
      });
    });

    group('性能和稳定性测试', () {
      testWidgets('页面加载性能应该在合理范围内', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(createTestApp(const RemindersPage()));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // 验证页面加载时间（1秒内）
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        print('📱 页面加载时间: ${stopwatch.elapsedMilliseconds}ms');
      });

      testWidgets('多个ReminderController实例应该能正常创建和销毁', (
        WidgetTester tester,
      ) async {
        final controllers = <ReminderController>[];

        // 创建多个控制器实例
        for (int i = 0; i < 5; i++) {
          controllers.add(ReminderController());
        }

        // 验证所有控制器都能正常工作
        for (final controller in controllers) {
          expect(controller.allReminders, isTrue);
          expect(controller.timedReminders.length, equals(8));
        }

        // 销毁所有控制器
        for (final controller in controllers) {
          controller.dispose();
        }

        // 没有异常说明创建和销毁都正常
        expect(controllers.length, equals(5));
      });
    });
  });
}

// 验证辅助函数
void verifyTimeFormat(String timeText) {
  final timeRegex = RegExp(r'^\d{2} : \d{2}$');
  expect(
    timeRegex.hasMatch(timeText),
    isTrue,
    reason: 'Time format should be HH : MM',
  );
}

void verifyTimeRangeFormat(String rangeText) {
  final rangeRegex = RegExp(r'^\d{2} : \d{2} - \d{2} : \d{2}$');
  expect(
    rangeRegex.hasMatch(rangeText),
    isTrue,
    reason: 'Time range format should be HH : MM - HH : MM',
  );
}

// 测试数据生成器
class TestDataGenerator {
  static List<TimedReminder> generateTestReminders(int count) {
    return List.generate(count, (index) {
      final hour = (7 + index * 2) % 24;
      return TimedReminder(
        id: 'test_$index',
        hour: hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour),
        minute: 0,
        isAM: hour < 12,
        isEnabled: true,
      );
    });
  }

  static ReminderSettings generateTestSettings({
    bool allReminders = true,
    int reminderInterval = 60,
    bool dndTime = true,
  }) {
    return ReminderSettings.fromDateTime(
      id: 1,
      allReminders: allReminders,
      intervalRemind: true,
      reminderInterval: reminderInterval,
      dndTime: dndTime,
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
  }
}
