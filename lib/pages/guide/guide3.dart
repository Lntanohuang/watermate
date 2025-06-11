import 'package:flutter/material.dart';
import 'package:watermate/pages/startup/start1.dart';
import 'package:watermate/pages/home/home.dart';
import 'package:watermate/utils/navigation_helper.dart';
import 'package:watermate/utils/user_setup_manager.dart';
import 'package:watermate/database/database_manager.dart';
import 'package:watermate/utils/toast_utils.dart';

class GuidePage3 extends StatelessWidget {
  final bool fromPersonalInfo;

  const GuidePage3({super.key, this.fromPersonalInfo = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 223, 238, 245),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/png/guide3.png', fit: BoxFit.cover),
          // skip按钮，右上角
          if (!fromPersonalInfo) // 只有不是从个人信息页面跳转时才显示skip按钮
            Positioned(
              top: 45,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  // 使用导航工具类跳转到首页并初始化数据库
                  NavigationHelper.navigateToHomeWithDatabase(context);
                },
                child: Image.asset(
                  'assets/images/png/skip.png',
                  width: 55,
                  height: 55,
                ),
              ),
            ),

          // 返回按钮，左上角（仅从个人信息页面跳转时显示）
          if (fromPersonalInfo)
            Positioned(
              top: 45,
              left: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context, false);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF8CA0B3),
                    size: 20,
                  ),
                ),
              ),
            ),
          // 四个半圆角按钮，垂直居中
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRoundButton(context, 'Sedentary'),
                const SizedBox(height: 24),
                _buildRoundButton(context, 'Light exercise'),
                const SizedBox(height: 24),
                _buildRoundButton(context, 'Moderate exercise'),
                const SizedBox(height: 24),
                _buildRoundButton(context, 'Intense exercise'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton(BuildContext context, String text) {
    // 添加状态变量
    bool isPressed = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox(
          width: 260,
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              // 更新状态
              setState(() {
                isPressed = true;
              });
              // 延迟一段时间后恢复状态
              Future.delayed(const Duration(milliseconds: 200), () {
                setState(() {
                  isPressed = false;
                });
              });

              if (fromPersonalInfo) {
                // 从个人信息页面跳转，直接保存到数据库
                try {
                  final db = await DatabaseManager.instance.database;
                  await db.userDao.updateExerciseVolume(text);

                  // 重新计算目标饮水量
                  final newTargetIntake =
                      await DatabaseManager.instance
                          .recalculateAndUpdateTargetWaterIntake();

                  if (context.mounted) {
                    ToastUtils.showSuccess(
                      context,
                      'Exercise volume updated, new target: ${newTargetIntake}ml',
                    );
                    Navigator.pop(context, true); // 返回true表示数据已更新
                  }
                } catch (e) {
                  if (context.mounted) {
                    ToastUtils.showError(context, 'Update failed: $e');
                  }
                }
              } else {
                // 保存用户选择的运动量
                UserSetupManager().setExerciseVolume(text);

                // 使用导航工具类跳转到StartupPage1并初始化数据库
                NavigationHelper.navigateWithDatabase(
                  context,
                  const StartupPage1(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24), // 半圆角
              ),
              backgroundColor:
                  isPressed
                      ? const Color.fromARGB(255, 121, 193, 222)
                      : Colors.white.withOpacity(0.85),
              elevation: 2,
              textStyle: const TextStyle(fontSize: 20),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w400, // 粗体
                color: const Color.fromARGB(255, 115, 212, 247),
              ),
            ),
          ),
        );
      },
    );
  }
}
