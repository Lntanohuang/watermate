import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermate/models/reminder_settings.dart';
import 'package:watermate/models/custom_timed_reminder.dart';
import 'package:watermate/models/timed_reminder.dart';
import 'package:watermate/services/reminder_persistence_service.dart';
import 'package:watermate/controllers/reminder_controller.dart';
import 'package:watermate/database/database_manager.dart';

void main() {
  group('🔥 Reminders 完整集成测试', () {
    late ReminderPersistenceService persistenceService;

    setUpAll(() async {
      // 初始化持久化服务
      persistenceService = ReminderPersistenceService();

      // 确保数据库已初始化
      await DatabaseManager.instance.database;
    });

    group('📊 数据库基础操作测试', () {
      test('应该能够创建和获取默认提醒设置', () async {
        // 获取当前设置（应该创建默认设置如果不存在）
        final settings = await persistenceService.getReminderSettings();

        expect(settings, isNotNull);
        expect(settings!.allReminders, isTrue);
        expect(settings.intervalRemind, isTrue);
        expect(settings.reminderInterval, equals(60));
        expect(settings.dndTime, isTrue);
        expect(settings.reminderStartHour, equals(7));
        expect(settings.reminderEndHour, equals(22));
        expect(settings.dndLunch, isTrue);
        expect(settings.lunchStartHour, equals(12));
        expect(settings.lunchEndHour, equals(13));
        expect(settings.dndPlan, isTrue);

        print('✅ 默认设置创建成功: ${settings.toString()}');
      });

      test('应该能够更新提醒设置', () async {
        // 获取当前设置
        final currentSettings = await persistenceService.getReminderSettings();
        expect(currentSettings, isNotNull);

        // 更新设置
        final updatedSettings = currentSettings!.copyWith(
          allReminders: false,
          reminderInterval: 30,
          dndTime: false,
        );

        final success = await persistenceService.saveReminderSettings(
          updatedSettings,
        );
        expect(success, isTrue);

        // 验证更新后的设置
        final savedSettings = await persistenceService.getReminderSettings();
        expect(savedSettings, isNotNull);
        expect(savedSettings!.allReminders, isFalse);
        expect(savedSettings.reminderInterval, equals(30));
        expect(savedSettings.dndTime, isFalse);

        print(
          '✅ 设置更新成功: allReminders=${savedSettings.allReminders}, interval=${savedSettings.reminderInterval}',
        );
      });

      test('应该能够更新时间范围设置', () async {
        // 更新提醒时间范围
        final success1 = await persistenceService.updateReminderTimeRange(
          8,
          30,
          21,
          30,
        );
        expect(success1, isTrue);

        // 验证更新
        final settings1 = await persistenceService.getReminderSettings();
        expect(settings1!.reminderStartHour, equals(8));
        expect(settings1.reminderStartMinute, equals(30));
        expect(settings1.reminderEndHour, equals(21));
        expect(settings1.reminderEndMinute, equals(30));

        // 更新午休时间范围
        final success2 = await persistenceService.updateLunchTimeRange(
          11,
          45,
          14,
          15,
        );
        expect(success2, isTrue);

        // 验证更新
        final settings2 = await persistenceService.getReminderSettings();
        expect(settings2!.lunchStartHour, equals(11));
        expect(settings2.lunchStartMinute, equals(45));
        expect(settings2.lunchEndHour, equals(14));
        expect(settings2.lunchEndMinute, equals(15));

        print('✅ 时间范围更新成功: 提醒时间 08:30-21:30, 午休时间 11:45-14:15');
      });
    });

    group('⏰ 自定义提醒管理测试', () {
      test('应该能够添加自定义提醒', () async {
        // 添加几个自定义提醒
        final success1 = await persistenceService.addCustomReminder(
          9,
          15,
          true,
        );
        expect(success1, isTrue);

        final success2 = await persistenceService.addCustomReminder(
          15,
          45,
          false,
        );
        expect(success2, isTrue);

        final success3 = await persistenceService.addCustomReminder(
          21,
          30,
          false,
        );
        expect(success3, isTrue);

        // 获取所有自定义提醒
        final customReminders = await persistenceService.getCustomReminders();
        expect(customReminders.length, greaterThanOrEqualTo(3));

        print('✅ 自定义提醒添加成功: ${customReminders.length} 个提醒');
        for (final reminder in customReminders) {
          print(
            '   - ${reminder.hour}:${reminder.minute.toString().padLeft(2, '0')} ${reminder.isAM ? 'AM' : 'PM'}',
          );
        }
      });

      test('应该能够切换自定义提醒状态', () async {
        // 获取现有的自定义提醒
        final customReminders = await persistenceService.getCustomReminders();
        expect(customReminders.isNotEmpty, isTrue);

        // 切换第一个提醒的状态
        final firstReminder = customReminders.first;
        final originalState = firstReminder.isEnabled;

        final success = await persistenceService.toggleCustomReminderEnabled(
          firstReminder.id!,
          !originalState,
        );
        expect(success, isTrue);

        // 验证状态变化
        final updatedReminders = await persistenceService.getCustomReminders();
        final updatedReminder = updatedReminders.firstWhere(
          (r) => r.id == firstReminder.id,
        );
        expect(updatedReminder.isEnabled, equals(!originalState));

        print(
          '✅ 提醒状态切换成功: ${firstReminder.hour}:${firstReminder.minute.toString().padLeft(2, '0')} ${originalState ? 'ON' : 'OFF'} -> ${!originalState ? 'ON' : 'OFF'}',
        );
      });

      test('应该能够删除自定义提醒', () async {
        // 获取现有的自定义提醒
        final customReminders = await persistenceService.getCustomReminders();
        final initialCount = customReminders.length;
        expect(initialCount, greaterThan(0));

        // 删除第一个提醒
        final firstReminder = customReminders.first;
        final success = await persistenceService.deleteCustomReminder(
          firstReminder.id!,
        );
        expect(success, isTrue);

        // 验证删除
        final remainingReminders =
            await persistenceService.getCustomReminders();
        expect(remainingReminders.length, equals(initialCount - 1));

        // 确保删除的提醒不再存在
        final deletedReminderExists = remainingReminders.any(
          (r) => r.id == firstReminder.id,
        );
        expect(deletedReminderExists, isFalse);

        print('✅ 提醒删除成功: 剩余 ${remainingReminders.length} 个提醒');
      });
    });

    group('🎮 ReminderController 完整流程测试', () {
      test('应该能够初始化并加载数据库设置', () async {
        final controller = ReminderController();

        // 手动初始化（模拟实际使用场景）
        await controller.initialize();

        // 验证设置已从数据库加载
        expect(controller.allReminders, isNotNull);
        expect(controller.timedReminders, isNotEmpty);

        print('✅ 控制器初始化成功: 加载了 ${controller.timedReminders.length} 个提醒');

        controller.dispose();
      });

      test('应该能够直接通过持久化服务添加提醒', () async {
        final controller = ReminderController();
        await controller.initialize();

        final initialCount = controller.timedReminders.length;

        // 直接使用持久化服务添加新提醒（绕过UI层）
        final success = await persistenceService.addCustomReminder(
          4,
          20,
          false,
        );
        expect(success, isTrue);

        // 重新初始化控制器以加载最新数据
        controller.dispose();
        final newController = ReminderController();
        await newController.initialize();

        // 验证内存中的变化
        expect(newController.timedReminders.length, equals(initialCount + 1));

        // 验证数据库中的持久化
        final customReminders = await persistenceService.getCustomReminders();
        final dbReminder = customReminders.firstWhere(
          (r) => r.hour == 4 && r.minute == 20 && !r.isAM,
          orElse: () => throw Exception('Reminder not found in database'),
        );
        expect(dbReminder, isNotNull);

        print('✅ 新提醒添加成功: 4:20 PM, 数据库ID: ${dbReminder.id}');

        newController.dispose();
      });

      test('应该能够更新勿扰设置', () async {
        final controller = ReminderController();
        await controller.initialize();

        // 获取初始状态
        final initialDndTime = controller.dndTime;
        final initialDndLunch = controller.dndLunch;
        final initialDndPlan = controller.dndPlan;

        // 切换各种勿扰设置
        await controller.toggleDndTime(!initialDndTime);
        await controller.toggleDndLunch(!initialDndLunch);
        await controller.toggleDndPlan(!initialDndPlan);

        // 验证内存中的变化
        expect(controller.dndTime, equals(!initialDndTime));
        expect(controller.dndLunch, equals(!initialDndLunch));
        expect(controller.dndPlan, equals(!initialDndPlan));

        // 验证数据库中的持久化
        final settings = await persistenceService.getReminderSettings();
        expect(settings!.dndTime, equals(!initialDndTime));
        expect(settings.dndLunch, equals(!initialDndLunch));
        expect(settings.dndPlan, equals(!initialDndPlan));

        print(
          '✅ 勿扰设置更新成功: DndTime=${!initialDndTime}, DndLunch=${!initialDndLunch}, DndPlan=${!initialDndPlan}',
        );

        controller.dispose();
      });
    });

    group('🔗 数据转换和兼容性测试', () {
      test('自定义提醒和定时提醒之间的转换应该正确', () async {
        // 创建自定义提醒
        await persistenceService.addCustomReminder(10, 45, true);

        // 通过持久化服务加载为定时提醒
        final customReminders = await persistenceService.getCustomReminders();
        final lastCustom = customReminders.last;

        // 转换为TimedReminder
        final timedReminder = TimedReminder(
          id: lastCustom.id.toString(),
          hour: lastCustom.hour,
          minute: lastCustom.minute,
          isAM: lastCustom.isAM,
          isEnabled: lastCustom.isEnabled,
        );

        // 验证转换正确性
        expect(timedReminder.hour, equals(10));
        expect(timedReminder.minute, equals(45));
        expect(timedReminder.isAM, isTrue);
        expect(
          timedReminder.hour24,
          equals(10),
        ); // 10 AM = 10 in 24-hour format
        expect(timedReminder.displayTime, equals('10 : 45'));
        expect(timedReminder.fullDisplayTime, equals('10 : 45 AM'));

        print('✅ 数据转换成功: CustomReminder -> TimedReminder');
        print('   - 12小时制: ${timedReminder.fullDisplayTime}');
        print('   - 24小时制: ${timedReminder.hour24}:${timedReminder.minute}');
      });

      test('时间计算功能应该正确', () {
        // 测试今天的时间计算
        final morningReminder = TimedReminder(
          id: 'test1',
          hour: 8,
          minute: 30,
          isAM: true,
          isEnabled: true,
        );

        final todayDateTime = morningReminder.todayDateTime;
        expect(todayDateTime.hour, equals(8));
        expect(todayDateTime.minute, equals(30));

        // 测试下次提醒时间计算
        final nextReminder = morningReminder.nextReminderDateTime;
        expect(nextReminder.hour, equals(8));
        expect(nextReminder.minute, equals(30));

        // 如果当前时间已过8:30，下次提醒应该是明天
        final now = DateTime.now();
        if (now.hour > 8 || (now.hour == 8 && now.minute > 30)) {
          expect(nextReminder.day, equals(now.day + 1));
        } else {
          expect(nextReminder.day, equals(now.day));
        }

        print(
          '✅ 时间计算正确: 今天=${todayDateTime.toString()}, 下次=${nextReminder.toString()}',
        );
      });

      test('批量转换功能应该正确', () async {
        // 获取所有自定义提醒
        final customReminders = await persistenceService.getCustomReminders();

        // 使用持久化服务的转换方法
        final timedReminders = persistenceService.convertToTimedReminders(
          customReminders,
        );

        expect(timedReminders.length, equals(customReminders.length));

        // 验证转换正确性
        for (int i = 0; i < customReminders.length; i++) {
          final custom = customReminders[i];
          final timed = timedReminders[i];

          expect(timed.hour, equals(custom.hour));
          expect(timed.minute, equals(custom.minute));
          expect(timed.isAM, equals(custom.isAM));
          expect(timed.isEnabled, equals(custom.isEnabled));
          expect(timed.id, equals(custom.id.toString()));
        }

        print('✅ 批量转换正确: ${timedReminders.length} 个提醒已转换');
      });
    });

    group('🛡️ 错误处理和边界情况测试', () {
      test('应该能够处理数据库重复插入', () async {
        // 尝试添加相同的自定义提醒
        final success1 = await persistenceService.addCustomReminder(
          12,
          0,
          false,
        );
        expect(success1, isTrue);

        final success2 = await persistenceService.addCustomReminder(
          12,
          0,
          false,
        );
        // 第二次添加应该失败（不允许重复时间）
        expect(success2, isFalse);

        print('✅ 重复插入处理正确: 第二次插入被拒绝');
      });

      test('应该能够处理无效的删除和切换操作', () async {
        // 尝试切换不存在的提醒
        final toggleResult = await persistenceService
            .toggleCustomReminderEnabled(99999, true);
        expect(toggleResult, isFalse);

        // 尝试删除不存在的提醒
        final deleteResult = await persistenceService.deleteCustomReminder(
          99999,
        );
        expect(deleteResult, isFalse);

        print('✅ 无效操作处理正确');
      });

      test('应该能够处理空数据库查询', () async {
        // 查询获取的提醒（至少应该有一些）
        final reminders = await persistenceService.getCustomReminders();
        expect(reminders, isNotNull);

        // 查询仅启用的提醒
        final enabledReminders =
            await persistenceService.getEnabledCustomReminders();
        expect(enabledReminders, isNotNull);

        print(
          '✅ 数据库查询处理正确: 总计${reminders.length}个，启用${enabledReminders.length}个',
        );
      });
    });

    group('📈 性能和压力测试', () {
      test('多次创建和销毁控制器应该稳定', () async {
        final controllers = <ReminderController>[];

        // 创建5个控制器实例（减少数量以提高测试速度）
        for (int i = 0; i < 5; i++) {
          final controller = ReminderController();
          await controller.initialize();
          controllers.add(controller);
        }

        // 验证所有控制器都正常工作
        for (final controller in controllers) {
          expect(controller.timedReminders, isNotEmpty);
          expect(controller.allReminders, isNotNull);
        }

        // 销毁所有控制器
        for (final controller in controllers) {
          controller.dispose();
        }

        print('✅ 多实例稳定性测试通过: 创建和销毁了${controllers.length}个控制器');
      });

      test('数据库查询性能应该在合理范围内', () async {
        final stopwatch = Stopwatch()..start();

        // 执行一系列数据库操作
        await persistenceService.getReminderSettings();
        await persistenceService.getCustomReminders();
        await persistenceService.getEnabledCustomReminders();

        stopwatch.stop();
        final queryTime = stopwatch.elapsedMilliseconds;

        expect(queryTime, lessThan(1000)); // 查询应该在1秒内完成

        print('✅ 性能测试通过: 多个查询完成时间 ${queryTime}ms');
      });
    });
  });
}

// Simplified mock for testing - using a simple empty widget context
class MockBuildContext {
  // 这是一个简化的mock类，不继承BuildContext以避免复杂的接口实现
}
